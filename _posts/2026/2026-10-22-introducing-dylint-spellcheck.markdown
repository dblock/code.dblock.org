---
layout: post
title: Introducing Dylint Spellcheck (Rust)
date: 2026-10-22
tags: [rust, open-source, testing]
---

After [adding spelling checks to RuboCop](/2026/10/21/introducing-rubocop-spellcheck.html), I wanted the same thing for Rust.

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

## Implementation in excalc-rs

I added spell-checking to [excalc-rs](https://github.com/dblock/excalc-rs) in [PR #4](https://github.com/dblock/excalc-rs/pull/4).

Technical comments contain perfectly legitimate words that are not in an English dictionary: `Kronrod`, `Mascheroni`, `MCP`, and `excalc`, for example. I added a workspace-root `dylint.toml` to combine bundled English with a project vocabulary:

```toml
[dylint-spellcheck]
dictionaries = ["crate:dylint-spellcheck/data/en", ".spellcheck.txt"]
```

The `crate:` reference selects dictionary resources, not another application dependency. Bundled English is available without downloading a separate dictionary.

With `.spellcheck.txt` absent, I ran the full intended feature scope:

```sh
cargo +stable dylint --all -- --all-targets --all-features
cargo +stable dylint --all -- --all-targets --no-default-features
```

I checked both feature configurations because excalc-rs supports building with and without its optional MCP server, which is enabled by default. Unknown words accumulated in a sorted, deduplicated `.spellcheck.tmp` across compiler processes and runs.

After reviewing the list for genuine typos, I promoted it to the project vocabulary:

```sh
mv .spellcheck.tmp .spellcheck.txt
```

I committed `.spellcheck.txt` and `dylint.toml` and added `.spellcheck.tmp` and `.spellcheck.tmp.lock` to `.gitignore`. The regenerated excalc-rs vocabulary contained 136 case-sensitive entries. Subsequent checks used that vocabulary without modifying it.

Finally, I made warnings fail CI:

```sh
RUSTFLAGS="-D warnings" cargo +stable dylint --all -- --all-targets --all-features
RUSTFLAGS="-D warnings" cargo +stable dylint --all -- --all-targets --no-default-features
```

See the [excalc-rs integration](https://github.com/dblock/excalc-rs/pull/4) for the configuration, vocabulary, and CI setup.
