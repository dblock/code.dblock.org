---
layout: post
title: Introducing RuboCop Spellcheck
date: 2026-10-21
tags: [ruby, open-source, testing, blog]
---

I replaced this blog's Python spell checker that took more than three minutes to run with the new [rubocop-spellcheck](https://github.com/dblock/rubocop-spellcheck).

I really love [RuboCop](https://github.com/rubocop/rubocop) for its standard approach to linting and auto-correction, which solves the difficult problem of deciding between tabs and spaces (use defaults). My typical implementation in Ruby projects is to add a standard `.rubocop.yml`, run `rubocop -a`, ask an AI to fix easy fixable violations, then run `rubocop --auto-gen-config` to mark all remaining ones as an exception. Why should spelling be any different?

Introducing [rubocop-spellcheck](https://github.com/dblock/rubocop-spellcheck), a RuboCop plugin for checking spelling in Ruby comments, strings, identifiers, Markdown, RDoc, AsciiDoc, and plain text. It uses [Kotoshu](https://github.com/kotoshu/kotoshu) with its pure Ruby backend and ships an American English dictionary. No separate dictionary download, environment, or system spelling package is required.

## Getting Started

The examples below use released [0.2.0](https://github.com/dblock/rubocop-spellcheck/releases/tag/v0.2.0). Add this to your `Gemfile`:

```ruby
group :development do
  gem 'rubocop-spellcheck', '~> 0.2.0', require: false
end
```

Enable the plugin in `.rubocop.yml`:

```yaml
plugins:
  - rubocop-spellcheck
```

Run it:

```sh
bundle install
bundle exec rubocop --only Spellcheck/Spelling
```

Given this Ruby comment:

```ruby
# The red brown fox jumsp over the lazy dog.
```

RuboCop reports:

```text
example.rb:1:21: C: [Correctable] Spellcheck/Spelling: Misspelled word: jumsp. Did you mean jumps, jump, jumpy?
# The red brown fox jumsp over the lazy dog.
                    ^^^^^
```

Try auto-correct when the first suggestion is one edit away:

```sh
bundle exec rubocop -A --only Spellcheck/Spelling
```

This changes `jumsp` to `jumps`, an adjacent transposition, even though there are three suggestions. Corrections accept lowercase and title-case words, but leave ALL CAPS, mixed-case words, and dotted technical tokens alone. `-A` opts into unsafe changes: even a correctly spelled replacement can change the meaning of a comment or document, including people's names. Review the diff.

Examine spelling mistakes and fix them. Then generate a `.spellcheck.txt` for remaining false positives such as constants or terms common in technical documentation.

For a file containing `# RuboCop uses Kotoshu.`, run:

```sh
bundle exec rubocop --auto-gen-config --only Spellcheck/Spelling
cat .spellcheck.txt
```

```text
kotoshu
rubocop
```

The command also adds `.spellcheck.txt` to `Spellcheck.DictionaryFiles`, retaining the bundled English dictionary. Running it again rewrites `.spellcheck.txt`, clearing unused entries. Review the generated list: this accepts every remaining spelling error, including real typos.

It is a normal cop. You can exclude files, use `rubocop:disable Spellcheck/Spelling` in Ruby, run it in CI, and get diagnostics in the same place as your other lint failures.

## Implementation in this Blog

For this blog, I narrowed front matter checks to the `title` field because layout names and other site metadata are not prose. Project vocabulary lives in `.spellcheck.txt`, alongside the bundled dictionary:

```yaml
Spellcheck:
  DictionaryFiles:
    en:
      - gem:rubocop-spellcheck/data/en/en.dic
      - .spellcheck.txt

Spellcheck/Spelling:
  Markdown:
    FrontMatter:
      Include:
        - title
```

With released 0.2.0, checking all 618 tracked Markdown files on the benchmark branch averaged 3.69 seconds across three runs with caching disabled, including titles and Ruby strings. The benchmark harness and historical results are [here](https://github.com/dblock/code.dblock.org/tree/spelling-benchmarks/benchmarks/spelling).

See the [initial spelling integration](https://github.com/dblock/code.dblock.org/commit/e93cf0bef16b186e4d9afc0c9cc7892ae5117369) and the [update to 0.2.0](https://github.com/dblock/code.dblock.org/commit/8905f45e5fb26374f4fb6009d16f1e1f40a3fe2c) for implementation details.
