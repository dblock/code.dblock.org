---
layout: post
title: Benchmarks Are Free Now
date: 2026-08-15
tags: [ruby, open-source, ai]
comments: true
---
My [previous post](/2026/08/14/ruby-instance-variables-are-not-inherited-and-why-that-breaks-your-dsl) walked through four bugs in [ruby-enum](https://github.com/dblock/ruby-enum), a gem I maintain, all stemming from the fact that class-level instance variables aren't inherited by subclasses. The third fix, [#59](https://github.com/dblock/ruby-enum/pull/59), made `keys`, `key?`, `value?`, `key`, `value`, `to_h`, `parse` and `each` walk up `superclass` and merge in a parent's enums, so a subclass would see everything its ancestors defined. It was correct, fully tested, and shipped. It also made every one of those methods roughly 5x slower on any subclass.

```ruby
def _enum_hash
  if superclass < Ruby::Enum
    superclass.send(:_enum_hash).merge(_own_enum_hash)
  else
    _own_enum_hash
  end
end
```

This recomputes the merged hash, walking the entire ancestor chain, on every single call. There's no caching. A one-level subclass calling `.value` pays for building a brand new hash, on top of the superclass doing the same, every time. The test suite didn't notice because tests check correctness, not speed, and correctness was fine.

I only found this because I asked Copilot CLI to add a benchmark script comparing lookups at different inheritance depths, mostly out of curiosity about how the "Benchmarks" section of the README would read next to the new feature. It took one prompt and about a minute to get a working script:

```ruby
class Colors
  include Ruby::Enum
  define :RED, 'red'
  define :GREEN, 'green'
end

class SubColors < Colors
  define :BLUE, 'blue'
end

class SubSubColors < SubColors
  define :YELLOW, 'yellow'
end

benchmark('base class (no inheritance)', n) { Colors.value(:RED) }
benchmark('subclass (1 level)', n) { SubColors.value(:RED) }
benchmark('sub-subclass (2 levels)', n) { SubSubColors.value(:RED) }
```

The first run told the story immediately: a 1-level subclass's `.value` calls took roughly 5x as long as the base class, and a 2-level subclass was worse still. Nobody had written this benchmark before merging #59 because writing a throwaway benchmark script used to feel like more ceremony than it was worth for a one-off performance check. Now it's a single sentence to an agent, and the script stays in the repo afterward as a `rake benchmark:inheritance` task anyone can rerun.

The fix was small: memoize the merged hash and invalidate the cache only when `define` adds a new entry.

```ruby
def _enum_hash
  @_enum_hash ||= if superclass < Ruby::Enum
                    superclass.send(:_enum_hash).merge(_own_enum_hash)
                  else
                    _own_enum_hash
                  end
end
```

Re-running the same benchmark after the fix ([#60](https://github.com/dblock/ruby-enum/pull/60)):

```
--- .value lookups, by depth of inheritance ---
base class (no inheritance): 0.0627
subclass (1 level): 0.0608
sub-subclass (2 levels): 0.0606
```

Subclass lookups are now indistinguishable from the base class, regardless of depth. I also had Copilot CLI write a second benchmark ([#61](https://github.com/dblock/ruby-enum/pull/61)) comparing basic `Ruby::Enum` operations against plain Ruby equivalents, since I was about to write a README claim about the gem's overhead and didn't want to write "negligible" without a number to back it up. Constant access turned out to be free (`Colors::RED` is exactly as fast as a plain Ruby constant), but hash-backed lookups like `.value` and `.key?` carry a real, if small, 3-5x cost versus calling `Hash#[]` directly - the price of the extra method dispatch and object wrapping `Ruby::Enum` does. Worth knowing, not worth avoiding the gem over. That number, along with the exhaustive `Ruby::Enum::Case` matcher's much larger 50-100x overhead versus a native `case` statement, is now spelled out in a dedicated [Performance section](https://github.com/dblock/ruby-enum#performance) in the README, so nobody has to ask or guess.

None of this changes the underlying lesson that a performance regression is easy to introduce and easy to miss when your tests only check correctness. What's changed is the cost of catching it. Writing a benchmark script used to be the kind of thing you'd skip on a Friday afternoon for a "just a getter method" change. Now, benchmarks are free.
