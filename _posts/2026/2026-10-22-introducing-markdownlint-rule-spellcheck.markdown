---
layout: post
title: Introducing Markdownlint Spellcheck
date: 2026-10-22
tags: [javascript, open-source, testing, blog]
---

After [RuboCop spelling checks for Ruby](/2026/10/21/introducing-rubocop-spellcheck.html) and [Dylint spelling checks for Rust](/2026/10/22/introducing-dylint-spellcheck.html), here's the version that doesn't require either language's toolchain.

Introducing [markdownlint-rule-spellcheck](https://github.com/dblock/markdownlint-rule-spellcheck), a custom [markdownlint](https://github.com/DavidAnson/markdownlint) rule powered by [CSpell](https://github.com/streetsidesoftware/cspell). Released [0.1.0](https://github.com/dblock/markdownlint-rule-spellcheck/releases/tag/v0.1.0) checks Markdown prose, suggests corrections, and ships American English through its dependencies. No separate dictionary download or system spelling package is required.

## Getting Started

Requires Node.js 22.18 or later. Install the rule and the command-line runner:

```sh
npm install --save-dev markdownlint-cli2 markdownlint-rule-spellcheck@0.1.0
```

Add `.markdownlint-cli2.jsonc`:

```json
{
  "customRules": ["markdownlint-rule-spellcheck"]
}
```

Given `example.md`:

```markdown
# Say helo to the world
```

Run:

```sh
npx markdownlint-cli2 example.md
```

The spelling diagnostic includes the original line and column:

```text
example.md:1:7 error spellcheck Prose words should be spelled correctly [Misspelled word: "helo". Suggestions: hello, helio, halo.]
```

Headings, paragraphs, lists, tables, link labels, and image descriptions are checked. Code, link destinations, URLs, and email addresses are skipped. Liquid expressions and tags are skipped too, which matters for Jekyll sites like this one.

## Accepting Project Vocabulary

Technical documentation contains legitimate words that aren't in an English dictionary. Collect candidates, review them, and add the accepted words:

```sh
npx markdownlint-rule-spellcheck collect "**/*.md" --output .spellcheck.txt
# Edit .spellcheck.txt: remove actual typos.
npx markdownlint-rule-spellcheck add ./.spellcheck.txt
npx markdownlint-cli2 "**/*.md"
```

The `add` command updates `.markdownlint.json`, preserving existing settings. Its dictionary configuration looks like this:

```json
{
  "spellcheck": {
    "dictionaries": {
      "en": ["@cspell/dict-en_us", "./.spellcheck.txt"]
    }
  }
}
```

## Corrections and Front Matter

Corrections are opt-in. Set `"autocorrect": true` inside `spellcheck`, then run:

```sh
npx markdownlint-cli2 --fix "**/*.md"
```

The first suggestion must be one edit away: an insertion, deletion, substitution, or adjacent transposition. Lowercase and title case can be corrected; ALL CAPS, mixed case, and components of technical tokens remain alone. Review the diff. A correctly spelled word can still be the wrong word.

YAML front matter strings are checked by default, with nested field selection in `.markdownlint.json`:

```json
{
  "spellcheck": {
    "markdown": {
      "frontMatter": {
        "include": ["title", "description", "authors.name"],
        "exclude": ["authors.url"]
      }
    }
  }
}
```

There's a setup wrinkle. Markdownlint normally removes front matter before custom rules see the document. To check it, add `"frontMatter": "a^"` to `.markdownlint-cli2.jsonc`. That's a regular expression that never matches, leaving the header available to the rule. Other Markdown rules will see it too and may need configuration. Alternatively, set `spellcheck.markdown.frontMatter` to `false` and keep the normal header handling.

I also use [markdownlint-rule-single-line-paragraphs](https://github.com/dblock/markdownlint-rule-single-line-paragraphs) to keep each prose paragraph on one source line. Let the editor wrap the display instead of inserting arbitrary line breaks into the file.

Install it:

```sh
npm install --save-dev markdownlint-rule-single-line-paragraphs
```

Register both rules in `.markdownlint-cli2.jsonc`:

```json
{
  "customRules": [
    "markdownlint-rule-spellcheck",
    "markdownlint-rule-single-line-paragraphs"
  ],
  "config": {
    "MD013": false
  }
}
```

Disabling `MD013` removes the line-length limit; the custom rule enforces single-line paragraphs. It isn't a rule for wrapping at 80 characters. It's the opposite. This blog already uses it, and the spelling rule's own documentation uses both.
