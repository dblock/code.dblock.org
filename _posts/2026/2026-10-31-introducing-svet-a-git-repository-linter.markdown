---
layout: post
title: "Introducing Svet: A Git Repository Linter"
date: 2026-10-31
tags: [open-source, nodejs, testing]
---

The idea for [Svet](https://github.com/dblock/svet) came from a private repository at work, where checking filename case helps catch portability problems like `Logo.svg` and `logo.svg` colliding on a case-insensitive Windows filesystem. These checks are implemented in pure JavaScript. That seemed like a useful job for a reusable repository linter.

I went looking for an existing tool.

| Tool                                                                              | Why it isn't enough here                                                                        |
| ---                                                                               | ---                                                                                             |
| [ESLint](https://eslint.org/docs/latest/use/configure/configuration-files)        | Can check filenames with a processor; byte-level checks and Git snapshots need custom plumbing. |
| [Oxlint](https://oxc.rs/docs/guide/usage/linter/js-plugins.html)                  | Arbitrary non-JS/TS files don't reach its lint rules.                                           |
| [Biome](https://biomejs.dev/reference/configuration/)                             | Checks supported languages, not arbitrary repository files.                                     |
| [Stylelint](https://stylelint.io/user-guide/configure/)                           | Built for stylesheet rules; repository-wide checks need custom code.                            |
| [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2#command-line) | Can check filenames, but Markdown parsing isn't a byte-level checking API.                      |
| [HTML-validate](https://html-validate.org/usage/index.html)                       | Requires HTML or template transformations, not a general file-checking API.                     |
| [Prettier](https://prettier.io/docs/cli#file-patterns)                            | Skips or rejects unsupported formats; doesn't check repository-wide path rules.                 |
| [lint-staged](https://github.com/lint-staged/lint-staged#--all)                   | Can run the checks, but doesn't supply rules or Git-index snapshots itself.                     |

Prettier is a formatter, and lint-staged is a task runner. They're in this list because they also appear in development and CI workflows.

The important distinction is selecting a path, checking its name, understanding its contents, and choosing which version of those contents to inspect. Those are four different things.

I built [Svet](https://github.com/dblock/svet) for that job.

Then I doubted myself and took a detour extending ESLint with [eslint-plugin-portable-paths](https://github.com/dblock/eslint-plugin-portable-paths). It checks four portability problems: case-insensitive file and directory collisions, Unicode-normalization collisions, Windows-invalid names such as `NUL.txt`, and paths or individual names exceeding configurable lengths. It's almost everything. The remaining limitations of the eslint approach are about which files and bytes we're checking. This plugin sees the current filesystem, including untracked paths, and is not Git-aware, so a pre-commit hook would check the working tree, not the staged snapshot. ESLint already checks line endings and trailing whitespace in source files, but doesn't supply raw-byte snapshots of arbitrary Git files. ESLint's native fixes edit source text and cannot update filesystem names, preventing us from implementing `--fix` for file paths.

Svet is built different. First, it separates file selection from checking. A selector supplies paths, captured contents, metadata, and any capabilities it supports. Checks declare what they need. The runner loads the configured plugins, preserves selection context, and reports findings, skips, unavailable inputs, and failures. There is no JavaScript parser between a selected file and a line-ending check. The default Git selector uses a text heuristic. Empty files, dotfiles, and files without extensions can all participate. Binary files remain in the Git provider's full path inventory, which is what the filename and collision checks consume.

Try it.

```sh
npm install --save-dev svet-cli@0.1.0
npx --no-install svet
```

No configuration is required. The default selects Git-tracked text and checks its working-tree contents for LF line endings. Add new files to Git before expecting that default to check them.

The plugins are separate npm packages. To add trailing-whitespace and path checks:

```sh
npm install --save-dev svet-check-file-trailing-whitespace@0.1.0 svet-check-path-case@0.1.0 svet-check-path-case-collision@0.1.0
```

Create `svet.config.mjs`:

```js
export default {
  files: "@svet-files-git",
  checks: [
    "@svet-check-file-eol",
    "@svet-check-file-trailing-whitespace",
    "@svet-check-path-case",
    "@svet-check-path-case-collision",
  ],
};
```

In my test repository, `README` contained CRLF and `sample.data` had a trailing space. This is an excerpt of the actual output:

```text
README:1: error [file/eol/eol]: Selected text contains CRLF line endings; expected LF. Convert the intended source to LF and run the check again.
sample.data:1: error [file/trailing-whitespace/trailing-whitespace]: Selected text contains trailing whitespace. Remove it from the intended source and run the check again.
README: error [path/case/case]: Filename must be lowercase.
Wrong.webp: error [path/case/case]: Filename must be lowercase.
Selected 4; checked 4; findings 4; skipped 0; failed 0; unavailable 0.
```

Checking a working-tree file isn't the same as checking a commit.

```sh
npx --no-install svet --precommit
```

This selects staged/index snapshots without staging, stashing, or fixing anything, which helps shift linting left. The Git provider can also compare explicit local revisions using target-commit contents. It doesn't fetch a branch or substitute working-tree bytes for a missing snapshot.

Svet won't replace ESLint, Oxlint, or your formatter. It's a new tool that could host the rules that belong to the repository and its files, rather than one source-language parser. Let's see if anyone finds it useful.
