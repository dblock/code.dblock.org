---
layout: post
title: To Wrap or Not to Wrap in Markdown?
date: 2021-06-07
tags: [markdown, open-source]
pinned: true
---
I keep antagonizing OSS contributors trying to wrap text in Markdown files, e.g. [here](https://github.com/opensearch-project/OpenSearch/pull/689#issuecomment-839241016) and [here](https://github.com/opensearch-project/OpenSearch/pull/712#issuecomment-855271225).

Should one wrap text in .markdown files at 80 columns or should one not?

First, let me say that I don't care. Except that I do. Wrapped text in markdown really feeds my OCD in the worst possible way, right behind missing periods at the end of sentences, and two spaces. Oddly, I don't care about tabs vs. spaces.

Here's a logical argument for _not wrapping_ text in markdown.

Markdown doesn't use line breaks: whether you include a line break in your markdown or not the rendered result is the same, unless you use 2 line breaks.

For example, consider the following text wrapped at 23 characters for illustration purposes.

```
A quick brown fox jumps
over the lazy dog.
```

We swap "a" and "the", producing the following new text.

```
The quick brown fox
jumps over a lazy dog.
```

Because of a line wrap, this 2-word change is now a 2-line change. It hurts.

Without the wrap the diff would have been super clean.

```
>A quick brown fox jumps over the lazy dog.
<The quick brown fox jumps over a lazy dog.
```

Furthermore, GitHub [does an even better job at the 1-line diff](https://github.com/dblock/code.dblock.org/commit/99a4948a737ef21bf4025f3faa5b6167410e3de8).

![diff]({{ site.url }}/images/posts/2021/2021-06-07-to-wrap-or-not-to-wrap-in-markdown/diff.png)

Notice how the word "jumps" was highlighted, even though it wasn't actually changed.

For an argument _for_ wrapping text, see [this comment](https://github.com/opensearch-project/OpenSearch/pull/712#issuecomment-855271225).

## Enforce It

You can enforce one source line per paragraph with a linter, or run a formatter in check mode to reject wrapped paragraphs in CI. Here are configurations for Ruby, JavaScript, and Python projects. Pick the tool you already use.

### RuboCop

For Ruby projects, [rubocop-prose](https://github.com/dblock/rubocop-prose) provides `Prose/MaxLength`. I added it to this Jekyll blog alongside spelling and Ruby code-example checks in [code.dblock.org#176](https://github.com/dblock/code.dblock.org/pull/176); see [Linting Both Prose and Embedded Code with RuboCop](/2026/11/06/linting-both-prose-and-embedded-code-with-rubocop.html). Add it to your `Gemfile` and run `bundle install`:

```ruby
gem 'rubocop-prose', '~> 0.2.0', require: false
```

Add to `.rubocop.yml`:

```yaml
plugins:
  - rubocop-prose

Prose/MaxLength:
  Enabled: true
  Max: false
```

Here, `Max: false` means "one source line per paragraph", not "disable the cop". It's also the default. A positive number asks the same cop to wrap paragraphs to that width instead.

Check and fix paragraph wrapping with:

```sh
bundle exec rubocop --only Prose/MaxLength README.md
bundle exec rubocop --only Prose/MaxLength -a README.md
```

This works inside lists and blockquotes, preserves hard breaks and `<br>`, and leaves headings, tables, and code blocks alone.

### Prettier

[Prettier](https://prettier.io/docs/options#prose-wrap) knows how to unwrap paragraphs with `proseWrap`.

```sh
npm install --save-dev prettier
```

Set `proseWrap` in `.prettierrc.json`:

```json
{
  "proseWrap": "never"
}
```

Check formatting in CI, or rewrite files locally:

```sh
npx prettier --check "**/*.md" "**/*.markdown"
npx prettier --write "**/*.md" "**/*.markdown"
```

Use `"never"`, not the default `"preserve"`: preserving existing wrapping would leave already-wrapped paragraphs alone. You don't need to inflate `printWidth` to some enormous number. This checks all formatting choices enforced by Prettier, not just paragraph wrapping, and the write command applies them too.

### ESLint

[eslint-plugin-markdown-preferences-paragraph](https://github.com/dblock/eslint-plugin-markdown-preferences-paragraph) checks and safely fixes paragraph wrapping with ESLint's native Markdown support.

Install it alongside ESLint and its Markdown language plugin:

```sh
npm install --save-dev eslint @eslint/markdown eslint-plugin-markdown-preferences-paragraph
```

In `eslint.config.js`:

```js
import markdown from "@eslint/markdown";
import paragraph from "eslint-plugin-markdown-preferences-paragraph";

export default [{
  files: ["**/*.md", "**/*.markdown"],
  plugins: { markdown, paragraph },
  language: "markdown/gfm",
  rules: {
    "paragraph/wrap": ["error", { width: "nowrap" }],
  },
}];
```

Check and fix paragraph wrapping:

```sh
npx eslint "**/*.md" "**/*.markdown"
npx eslint "**/*.md" "**/*.markdown" --fix
```

`"nowrap"` joins soft line breaks without a width limit, including paragraphs in lists, blockquotes, and footnotes. Intentional hard breaks remain separate, and unsafe corrections report without a fix.

### markdownlint

[markdownlint-rule-single-line-paragraphs](https://github.com/dblock/markdownlint-rule-single-line-paragraphs) is a custom `markdownlint` rule.

```sh
npm install --save-dev markdownlint-cli2 markdownlint-rule-single-line-paragraphs
```

Create `.markdownlint-cli2.jsonc`:

```json
{
  "customRules": ["markdownlint-rule-single-line-paragraphs"],
  "config": {
    "default": true,
    "MD013": false,
    "single-line-paragraphs": {
      "enabled": true
    }
  }
}
```

This disables `MD013`, the line-length rule, so it doesn't complain about the long paragraphs you just asked for.

```sh
npx markdownlint-cli2 "**/*.md" "**/*.markdown"
```

Add `--fix` to join continuation lines automatically:

```sh
npx markdownlint-cli2 --fix "**/*.md" "**/*.markdown"
```

The rule checks prose at the document root and inside lists and blockquotes. It preserves intentional Markdown hard breaks and `<br>` boundaries. See [code.dblock.org#173](https://github.com/dblock/code.dblock.org/pull/173) for a working example.

I would have preferred this to be built as a new `style: single` in `MD013` as discussed in [markdownlint#298](https://github.com/DavidAnson/markdownlint/issues/298), but the repository doesn't accept AI-generated code and I don't remember how to write code anymore.

### mdformat

For Python projects, [mdformat](https://github.com/executablebooks/mdformat) supports `--wrap no`:

```sh
pipx install mdformat
mdformat --check --wrap no README.md
mdformat --wrap no README.md
```

The check command fails if the file needs formatting; the second command rewrites it. To make this the project default, add `.mdformat.toml`:

```toml
wrap = "no"
```

The default is `"keep"`, which preserves existing line wrapping. Like Prettier, mdformat also enforces its other formatting choices. It parses CommonMark by default; for GitHub Flavored Markdown, install its extension with `pipx inject mdformat mdformat-gfm`.
