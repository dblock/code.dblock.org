---
layout: post
title: "Standardizing Exception Message Style in Ruby"
date: 2026-09-05
tags: [ruby, grape, open-source]
comments: true
---
While reviewing [dozens of PRs from ericproulx](https://github.com/ruby-grape/grape/pulls?q=is%3Apr+author%3Aericproulx) optimizing [Grape](https://github.com/ruby-grape/grape)'s internals recently, I noticed that the bare `raise ArgumentError, "..."` calls scattered across the codebase were inconsistent: some messages were capitalized, some ended in a period, most were not. Longtime readers know [where this is going](/2025/04/04/apologizing-for-my-obsessiveness-over-punctuation.html).

Ruby's own core and standard library exceptions don't do this - `TypeError: no implicit conversion from nil to integer`, `ArgumentError: wrong number of arguments`, and so on all read lowercase and unpunctuated, because the message is meant to be read after the exception class name and a colon, not as a standalone sentence.

Grape's own `Grape::Exceptions::*` classes already follow this convention. The bare `raise ArgumentError, "..."` calls in `dsl/entity.rb`, `dsl/inside_route.rb`, `dsl/validations.rb`, and `validations/types/dry_type_coercer.rb` didn't, so I fixed those seven sites and documented the convention in `CONTRIBUTING.md`, in [#2909](https://github.com/ruby-grape/grape/pull/2909).

To avoid regressions, I wrote [rubocop-exception_messages](https://github.com/dblock/rubocop-exception_messages), a RuboCop plugin gem with two cops:

- `ExceptionMessages/Casing` flags (and autocorrects) messages that don't start with a lowercase letter.
- `ExceptionMessages/Punctuation` flags (and autocorrects) messages with a trailing period, with an exception for a literal ellipsis (`"still processing.."`), which is stylistic rather than a sentence ending.

Both cops recognize `raise Class, "message"` and `raise Class.new("message")` forms, and handle interpolated (`dstr`) messages by only checking the literal string segments (the first segment for casing, the last for punctuation), since interpolated values in the middle are out of the cop's control.

```ruby
# bad
raise ArgumentError, 'Missing required option.'

# good
raise ArgumentError, 'missing required option'
```

The gem ships as a modern RuboCop plugin (via [lint_roller](https://github.com/standardrb/lint_roller)), so it's a one-line addition to a consuming project's `.rubocop.yml`:

```yaml
plugins:
  - rubocop-exception_messages
```

`rubocop-exception_messages` [0.2.0](https://rubygems.org/gems/rubocop-exception_messages) is out now, and I've added it back to Grape's own `Gemfile` and `.rubocop.yml` in [#2909](https://github.com/ruby-grape/grape/pull/2909), so the convention it started from is now enforced by CI going forward. Not everyone will agree with my choice of lowercase and unpunctuated, of course, so `EnforcedStyle` support to configure the opposite convention is available, along with `ExceptionMessages/RedundantExceptionName`, which flags messages that redundantly repeat the exception class name, and `ExceptionMessages/QuoteStyle`, enabled by default, which checks that interpolated values in exception messages are consistently marked, e.g. `` "unknown type: `#{type}`" `` — the same PR fixed the 16 messages across Grape's codebase that weren't.
