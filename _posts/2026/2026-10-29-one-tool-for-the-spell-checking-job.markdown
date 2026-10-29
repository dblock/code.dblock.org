---
layout: post
title: One Tool for the (Spell Checking) Job
date: 2026-10-29
tags: [ai, open-source, testing]
---

I've built four spell-checking plugins in the last week. This is not an unhealthy interest in spelling. The cost of rolling tools out is the cost of tokens + my time supervising AI. So, before adding another language runtime, package manager, configuration file, and CI job to your project, consider spending an hour vibe coding the missing plugin.

This blog used to run a Python spell checker that took more than three minutes. It's a Jekyll blog, which is Ruby. Why was I maintaining a Python environment to tell me that I misspelled "hello"? I [replaced it with a RuboCop plugin](/2026/10/21/introducing-rubocop-spellcheck.html). Spelling became another cop, with the same configuration, exclusions, command, and CI integration as the rest of the checks.

A Rust project shouldn't need my Ruby setup to check its comments. A JavaScript project that already runs Prettier shouldn't need an additional Markdown linter just to check spelling.

You can either keep assembling a Frankenstein collection of tools, roll out a custom script, or you can ask AI to build the missing feature.

AI loves simplicity and consistent patterns. This approach pays forward.

Here's my recent zoo.

- [rubocop-spellcheck](https://github.com/dblock/rubocop-spellcheck) adds spelling to RuboCop for Ruby comments, strings, identifiers, Markdown, RDoc, AsciiDoc, and plain text.
- [dylint-spellcheck](https://github.com/dblock/dylint-spellcheck) adds spelling to Dylint for Rust comments, Rustdoc attributes, Markdown, and plain text.
- [markdownlint-rule-spellcheck](https://github.com/dblock/markdownlint-rule-spellcheck) adds spelling to the Markdown linter you might already be running.
- [prettier-plugin-spellcheck](https://github.com/dblock/prettier-plugin-spellcheck) adds spelling to Prettier for Markdown, HTML, plain text, and JavaScript/TypeScript prose.
- [markdownlint-rule-single-line-paragraphs](https://github.com/dblock/markdownlint-rule-single-line-paragraphs) keeps Markdown paragraphs on one source line.

Everything builds on top of simple and powerful platforms. The Prettier version is a good example. Prettier already parses Markdown, HTML, JavaScript, and TypeScript. I used its syntax trees to distinguish prose from program structure instead of inventing another parser. Comments and visible text are reasonable things to spellcheck, too.

Install the released plugin:

```sh
npm install --save-dev prettier prettier-plugin-spellcheck@0.1.0
```

Run it without a Prettier configuration:

```sh
printf '# helo\n' | npx prettier --plugin prettier-plugin-spellcheck --no-config --stdin-filepath example.md
```

```text
[error] example.md: Spelling check failed.
[error] example.md:1:3 Misspelled word: "helo". Suggestions: hello, helio, halo.
```

It's just another plugin in your existing Prettier setup.

A word of caution. Initially, Copilot built [prettier-plugin-spellcheck](https://github.com/dblock/prettier-plugin-spellcheck) as a wrapper on top of [markdownlint-rule-spellcheck](https://github.com/dblock/markdownlint-rule-spellcheck). Be careful out there.
