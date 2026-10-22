---
layout: post
title: Introducing Dylint Spellcheck
date: 2026-10-22
published: false
tags: [rust, open-source, testing]
---

After [adding spelling checks to RuboCop]({% post_url 2026/2026-10-21-introducing-rubocop-spellcheck %}), I wanted the same thing for Rust. Not another spell checker to configure and run separately. A lint.

Introducing [dylint-spellcheck](https://github.com/dblock/dylint-spellcheck), a [Dylint](https://github.com/trailofbits/dylint) library for checking spelling in Rust comments, Rustdoc attributes, Markdown, and plain text. It uses the [Rust implementation of Kotoshu](https://github.com/kotoshu/kotoshu-rs) and ships an American English dictionary. The idea is the same as the Ruby version: fix actual typos, accept project-specific vocabulary, and run spelling alongside the other lint checks.

## Getting Started

The examples below use released [0.1.0](https://github.com/dblock/dylint-spellcheck/releases/tag/v0.1.0). Install Rust through [rustup](https://rustup.rs/), then install Dylint:

```sh
cargo +stable install cargo-dylint dylint-link --version 6.2.0 --locked
```

Add the library to your project's `Cargo.toml`:

```toml
[workspace.metadata.dylint]
libraries = [
    { git = "https://github.com/dblock/dylint-spellcheck", tag = "v0.1.0" },
]
```

Dylint libraries are distributed through Git. Dylint downloads and builds this one with its pinned nightly compiler without changing the application's normal toolchain. There is no crate to add to your application's dependencies.

Run it:

```sh
cargo +stable dylint --all
```

Given this Rust comment:

```rust
// The red brown fox jumsp over the lazy dog.
fn main() {}
```

Dylint reports:

```text
warning: misspelled word: `jumsp`
 --> src/main.rs:1:22
  |
1 | // The red brown fox jumsp over the lazy dog.
  |                      ^^^^^
  |
  = help: did you mean `jump`, `jumps`, `lump`?
  = note: `#[warn(spellcheck)]` on by default
```

Unlike the RuboCop plugin, this version does not auto-correct. Fix the typo yourself. Suggestions are not instructions.

Comments are parsed as Markdown, so inline code, fenced code blocks, and link destinations are skipped. Rustdoc attributes such as `#[doc = "..."]` and `#![doc = include_str!("../README.md")]` are checked too. Ordinary strings and identifiers are not.

## Implementation in excalc-rs

The example is [excalc-rs](https://github.com/dblock/excalc-rs), an expression calculator CLI and MCP server. [PR #4](https://github.com/dblock/excalc-rs/pull/4) adds spelling to its existing Dylint checks. The application builds on stable Rust; Dylint manages the compiler needed by the lint libraries.

The project already runs the upstream general-purpose Dylint collection. Adding spelling means adding one more library to the same list, not replacing the existing lints.

Technical comments contain perfectly legitimate words that are not in an English dictionary: `Kronrod`, `Mascheroni`, `MCP`, and `excalc`, for example. Add a workspace-root `dylint.toml` to combine bundled English with a project vocabulary:

```toml
[dylint-spellcheck]
dictionaries = ["crate:dylint-spellcheck/data/en", ".spellcheck.txt"]
```

The `crate:` reference selects dictionary resources, not another application dependency. Bundled English is available without downloading a separate dictionary.

With `.spellcheck.txt` absent, run the full intended feature scope:

```sh
cargo +stable dylint --all -- --all-targets --all-features
cargo +stable dylint --all -- --all-targets --no-default-features
```

These are the two configurations used by excalc-rs, where the MCP server is an optional default feature. Unknown words accumulate in a sorted, deduplicated `.spellcheck.tmp` across compiler processes and runs. Warnings remain visible, but suggestions are skipped during collection.

Review that list. Fix genuine typos in source and remove them from the candidates before promoting the vocabulary:

```sh
mv .spellcheck.tmp .spellcheck.txt
```

Commit `.spellcheck.txt` and `dylint.toml`; ignore `.spellcheck.tmp` and `.spellcheck.tmp.lock`. The regenerated excalc-rs vocabulary contains 136 case-sensitive entries. Subsequent checks read that vocabulary without modifying it. Newly introduced unknown words are warnings, not silently accepted additions.

This differs from `rubocop --auto-gen-config`: candidates accumulate rather than being pruned to match the current source. To regenerate from scratch, move the accepted vocabulary aside and delete any old candidate file before collecting again. Do not turn every typo into a permanent exception.

Finally, make warnings fail CI:

```sh
RUSTFLAGS="-D warnings" cargo +stable dylint --all -- --all-targets --all-features
RUSTFLAGS="-D warnings" cargo +stable dylint --all -- --all-targets --no-default-features
```

## Documents and Exceptions

The excalc-rs integration checks Rust comments and Rustdoc; it does not select standalone documents. To check those too, add `include` and `exclude` to your configuration:

```toml
[dylint-spellcheck]
include = ["README.md", "docs/**/*.md", "docs/**/*.txt"]
exclude = ["docs/generated/**"]
dictionaries = ["crate:dylint-spellcheck/data/en", ".spellcheck.txt"]
```

Markdown prose is checked without code or link destinations; plain text is literal. YAML front matter string values are checked by default. Liquid expressions and tags are skipped without evaluating templates.

It is a Rust lint, so Rust's normal suppression rules apply:

```rust
#[allow(spellcheck)]
/// An intentionally misspelled example.
fn example() {}
```

Markdown also supports `<!-- spellcheck:disable -->`, `<!-- spellcheck:enable -->`, and a line-local `<!-- spellcheck:todo -->`. Suppressed words do not become vocabulary candidates.

See the [excalc-rs integration](https://github.com/dblock/excalc-rs/pull/4) for the configuration, vocabulary, and CI setup. Same idea as Ruby. Different compiler.
