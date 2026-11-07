---
layout: post
title: "Linting Both Prose and Embedded Code with RuboCop"
date: 2026-11-06
tags: [ruby, open-source, linting, testing]
---

My [father](https://fr.wikipedia.org/wiki/Roman_Doubrovkine) is a poetry translator, so perhaps my obsession with prose runs in the family. This started before Markdown: I wrote [rubocop-exception_messages](/2026/09/05/standardizing-exception-message-style-in-ruby.html) after noticing inconsistent exception messages in Grape.

After I [replaced this blog's Python spell checker with a RuboCop plugin](/2026/10/21/introducing-rubocop-spellcheck.html) I still had a Node installation to check Markdown. Since it's a Jekyll blog, and the build is Ruby, the spelling checker is Ruby, and my default set of code examples are also Ruby, why was formatting the README Node.js?

I first tried extending [rubocop-md](https://github.com/rubocop/rubocop-md), proposing [prose checks and parser diagnostics](https://github.com/rubocop/rubocop-md/pull/50), [a reusable Markdown parser](https://github.com/rubocop/rubocop-md/pull/51), [hidden cop-directive fixes](https://github.com/rubocop/rubocop-md/pull/52), [front-matter handling](https://github.com/rubocop/rubocop-md/pull/53), and [preserving prose alongside Ruby corrections](https://github.com/rubocop/rubocop-md/pull/55). The parser and interoperability work were merged in [#57](https://github.com/rubocop/rubocop-md/pull/57), but [the proposed markdownlint rules](https://github.com/rubocop/rubocop-md/issues/54) were rejected out of scope because `rubocop-md` lints Ruby within Markdown, not Markdown itself.

Introducing [rubocop-prose](https://github.com/dblock/rubocop-prose), a RuboCop plugin for Markdown and plain text. I also [replaced this blog's Markdown linter with it](https://github.com/dblock/code.dblock.org/pull/176).

It's an AI-assisted port from [JavaScript markdownlint](https://github.com/DavidAnson/markdownlint) and [Ruby markdownlint](https://github.com/markdownlint/markdownlint), [my custom single-line-paragraphs rule](https://github.com/dblock/markdownlint-rule-single-line-paragraphs), [rubocop-md](https://github.com/rubocop/rubocop-md), and [rubocop-spellcheck](https://github.com/dblock/rubocop-spellcheck), plus ideas from upstream issues, pull requests, and forks.

I burnt 11.4 million input and 2.4 million output non-cached tokens for development, publishing [the initial release](https://github.com/dblock/rubocop-prose/releases/tag/v0.1.0) in 16 hours, and iterating to [0.2.0](https://github.com/dblock/rubocop-prose/releases/tag/v0.2.0) over the next 2 days. My workflow was to start from scratch, then have AI write the PRs, and always steer: reviewing behavior, questioning defaults, and simplifying the user-facing settings by reading PR descriptions and generated documentation. I barely read code as I mostly cared about usability of the linter. For example, I asked to merge `EnforcedStyle` and `Style`. That meant consolidating overlapping options, considering a breaking change, and aligning names across cops.

### Adding Prose to RuboCop

Add to your `Gemfile`:

```ruby
gem 'rubocop-md', '~> 3.0', require: false
gem 'rubocop-prose', '~> 0.2.0', require: false
gem 'rubocop-spellcheck', '~> 0.2.0', require: false
```

Run `bundle install`, then enable the plugins in `.rubocop.yml`:

```yaml
plugins:
  - rubocop-md
  - rubocop-prose
  - rubocop-spellcheck

Markdown:
  Autodetect: false

Prose/MaxLength:
  Max: false

Spellcheck/Spelling:
  Ruby:
    Identifiers: true
```

`rubocop-prose` discovers Markdown and plain-text files. It checks headings, lists, links, tables, code-block structure, whitespace, and YAML front matter. Editorial choices such as title capitalization and proper-name spelling are configurable. `rubocop-spellcheck` checks spelling with a bundled American English dictionary and supports project-specific vocabulary. Together with `rubocop-md`, these plugins check the document's structure, its words, and its embedded Ruby.

I included three examples above. The first, `Markdown/Autodetect: false` tells `rubocop-md` not to guess whether code blocks without a language tag contain Ruby. Only explicitly Ruby-tagged blocks are inspected as Ruby, leaving examples in other languages alone. The second, `Prose/MaxLength` with `Max: false` enforces one source line per paragraph. I explain why in [To Wrap or Not to Wrap in Markdown?](/2021/06/07/to-wrap-or-not-to-wrap-in-markdown.html). Autocorrection joins wrapped paragraphs while preserving intentional Markdown hard breaks. The third, `Spellcheck/Spelling` with `Ruby/Identifiers: true`, opts into spelling checks for Ruby identifiers, such as method and variable names, in addition to the default checks for prose, comments, and strings.

Run the same command you already use for Ruby:

```sh
bundle exec rubocop
```

For safe corrections for the first two cops with `bundle exec rubocop -a`. Fix genuine typos first, then generate an initial project dictionary for names and technical vocabulary:

```sh
bundle exec rubocop --auto-gen-config --only Spellcheck/Spelling
```

This creates `.spellcheck.txt` and configures it alongside the bundled dictionary. Review the generated words before committing: any remaining typos will be accepted too.

With this, a single `bundle exec rubocop` checks entire markdown files!
