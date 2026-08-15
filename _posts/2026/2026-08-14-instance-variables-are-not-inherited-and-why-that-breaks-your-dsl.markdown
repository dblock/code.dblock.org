---
layout: post
title: "Ruby Instance Variables Are Not Inherited (and Why That Breaks Your DSL)"
date: 2026-08-14
tags: [ruby, open-source]
comments: true
---
The [ruby-enum](https://github.com/dblock/ruby-enum) gem is a small library I maintain that adds enum-like behavior to a class via `include Ruby::Enum` and `define :KEY, value`. Four pull requests landed against it recently, each fixing a different symptom, and all four turned out to be the same underlying bug: class-level instance variables set in a module's `included` hook are not inherited by subclasses the way you might expect. All of these fixes shipped in [ruby-enum 1.2.0](https://github.com/dblock/ruby-enum/blob/master/CHANGELOG.md).

`Ruby::Enum` stores its keys and values in instance variables on the class itself, set up when the module is included.

```ruby
def self.included(base)
  base.extend ClassMethods
  base.instance_variable_set(:@_enum_hash, {})
  base.instance_variable_set(:@_enums_by_value, {})
end
```

This works fine for a single class. It gets interesting the moment subclasses or class reloading show up.

A user opened [#56](https://github.com/dblock/ruby-enum/pull/56), reporting `DuplicateKeyError` from a Rails console after a class that had already `define`d its enums got reloaded. It reproduces without Rails.

```ruby
class_body = proc do
  include Ruby::Enum

  define :RED, 'red'
end

Colors = Class.new(&class_body)
Colors.class_eval(&class_body) # raises DuplicateKeyError
```

Rails' development-mode autoloader re-evaluates a class body, and the second `define :RED` sees `@_enum_hash` still holding `RED` from the first load, so the duplicate-key check fires. The [fix](https://github.com/dblock/ruby-enum/pull/56/files) clears the hash whenever `Ruby::Enum` is included, rather than assuming it's always a fresh class. The contributor that reported the problem and submitted the fix also caught a sneakier variant: a subclass that redundantly re-includes `Ruby::Enum` (`include` is supposed to be idempotent, right?) was wiping out enums inherited from its parent, because `included` unconditionally reset the instance variables:

```ruby
class OtherSecondSubclass < FirstSubclass
  include Ruby::Enum # redundant, but shouldn't lose FirstSubclass's enums

  define :MAGENTA, 'magenta'
end
```

Thanks, [Nazar](https://github.com/flvrone), for tracking both of these down with tests.

Months later, [#49](https://github.com/dblock/ruby-enum/issues/49) surfaced a related crash: a subclass that never calls `define` itself, just inheriting from a parent that does, blew up on `.values`.

```ruby
class Colors
  include Ruby::Enum

  define :RED, 'red'
end

class SubclassWithNoOwnDefines < Colors
end

SubclassWithNoOwnDefines.values # NoMethodError: undefined method `values' for nil
```

This is because `@_enum_hash` is only ever set in two places: the `included` hook, and redundantly again in `define`. A subclass that inherits `Ruby::Enum` transitively and never calls `define` runs neither, so its own `@_enum_hash` is `nil`. This is the crux of it: `SubclassWithNoOwnDefines.instance_variable_get(:@_enum_hash)` and `Colors.instance_variable_get(:@_enum_hash)` are two completely separate variables, even though one class is a subclass of the other. Instance variables, unlike methods, don't look up the ancestor chain.

Eight methods (`keys`, `key?`, `value?`, `key`, `value`, `to_h`, `parse`, `each`) had this bug, just with less obvious failure modes. The fix in [#58](https://github.com/dblock/ruby-enum/pull/58) was to stop reading the raw `@ivar` directly and go through a private reader that lazily defaults to an empty hash.

```ruby
def _enum_hash
  @_enum_hash ||= {}
end
```

Once a subclass with no enums of its own correctly returned an empty list instead of crashing, the obvious next question was whether it should instead see its parent's enums, the same way it sees inherited methods. Thus, [#59](https://github.com/dblock/ruby-enum/pull/59) extended all eight methods to walk up `superclass` and merge in inherited enums, with a subclass's own definitions taking precedence when they overlap.

```ruby
def _enum_hash
  if superclass < Ruby::Enum
    superclass.send(:_enum_hash).merge(_own_enum_hash)
  else
    _own_enum_hash
  end
end
```

Same lesson, opposite direction: since `@_enum_hash` isn't automatically inherited, subclass-aware behavior has to be built by hand, walking `superclass` and merging state explicitly.

Recomputing that merge on every single call is correct but wasteful - `O(depth)` work per lookup with no caching. I benchmarked it (more on that in a follow-up post) and found a one-level subclass paid a 5x tax on `.value` lookups versus the base class. [#60](https://github.com/dblock/ruby-enum/pull/60) memoized the merged hash, invalidating it only when `define` adds a new entry.

Class-instance-variables in Ruby - `@ivar` set on a class object, as opposed to instance-level `@ivar`s on regular objects - are per-class. They aren't inherited, and reloading a class doesn't reset them for you. If a gem's DSL needs subclass-aware or reload-safe behavior, that has to be built in explicitly: clear state on `include`, default lazily instead of assuming initialization already ran, and walk `superclass` yourself if you want inheritance-like semantics.
