- [Contributing to code.dblock.org](#contributing-to-codedblockorg)
  - [Fork the Project](#fork-the-project)
  - [Install Ruby](#install-ruby)
- [Contribute Content](#contribute-content)
  - [Create a Topic Branch](#create-a-topic-branch)
  - [Add or Edit a Post](#add-or-edit-a-post)
  - [Commit Changes](#commit-changes)
  - [Push](#push)
  - [Make a Pull Request](#make-a-pull-request)
  - [Make Changes](#make-changes)
  - [Rebase](#rebase)
  - [Check on Your Pull Request](#check-on-your-pull-request)
  - [Be Patient](#be-patient)
- [Misc](#misc)
  - [Markdown Linter](#markdown-linter)
  - [Spell Checker](#spell-checker)
  - [Style Checker](#style-checker)
  - [Pre-Commit Hooks](#pre-commit-hooks)
- [Thank You](#thank-you)

## Contributing to code.dblock.org

Other than millions of readers, this blog occasionally has [contributors](https://github.com/dblock/code.dblock.org/graphs/contributors).

You're encouraged to submit [pull requests](https://github.com/dblock/code.dblock.org/pulls), [or at least open issues](https://github.com/dblock/code.dblock.org/issues).

In the examples below, substitute your Github username for `contributor` in URLs.

### Fork the Project

Fork the [project on Github](https://github.com/dblock/code.dblock.org) and check out your copy.

```
git clone https://github.com/contributor/code.dblock.org.git
cd code.dblock.org
git remote add upstream https://github.com/dblock/code.dblock.org.git
```

### Install Ruby

Install Ruby. We recommend [rvm](https://rvm.io/). Use Ruby 2.7+.

```bash
rvm use 2.7.7
```

Install bundler.

```bash
gem install bundler
```

Install dependencies.

```bash
bundle install
```

Start a local Jekyll server.

```bash
bundle exec jekyll serve
```

Navigate to http://localhost:4000 to see the blog.

## Contribute Content

### Create a Topic Branch

Make sure your fork is up-to-date and create a topic branch for your feature or bug fix.

```bash
git checkout gh-pages
git pull upstream gh-pages
git checkout -b my-feature-branch
```

### Add or Edit a Post

Add or edit a post.

Make sure that it displays correctly locally at http://localhost:4000.

### Commit Changes

Make sure git knows your name and email address:

```bash
git config --global user.name "Your Name"
git config --global user.email "contributor@example.com"
```

Writing good commit logs is important. A commit log should describe what changed and why.

```bash
git add ...
git commit
```

### Push

```bash
git push origin my-feature-branch
```

### Make a Pull Request

Go to https://github.com/contributor/code.dblock.org and select your feature branch. Click the 'Pull Request' button and fill out the form. Pull requests are usually reviewed within a few days.

### Make Changes

Make changes as/if requested.

You can amend your previous commit and force push the changes or commit a new change.

```bash
git add .
git commit --amend
git push origin my-feature-branch -f
```

### Rebase

If you've been working on a change for a while, rebase with upstream/gh-pages.

```bash
git fetch upstream
git rebase upstream/gh-pages
git push origin my-feature-branch -f
```

### Check on Your Pull Request

Go back to your pull request after a few minutes and see whether it passed muster. Everything should look green, otherwise fix issues and amend your commit as described above.

### Be Patient

It's likely that your change will not be merged and that the nitpicky maintainer will ask you to do more, or fix seemingly benign problems. Hang on there!

## Misc

### Markdown Linter

```bash
bundle install
npm ci
bundle exec rake lint
```

This runs markdownlint for Markdown structure and rubocop-md for single-line prose paragraphs and parser diagnostics. rubocop-md currently uses the `configurable-front-matter` branch stacked on [PR 50](https://github.com/rubocop/rubocop-md/pull/50), preserving the blog's YAML metadata; `Gemfile.lock` pins the revision. `.rubocop.yml` enables `Markdown/MaxLength`, with `Max: false` to unwrap paragraphs rather than enforce a maximum line length, and `Markdown/Syntax` to report parser warnings with filenames and line numbers. Syntax diagnostics are normal warning-severity offenses and can cause lint to fail; they cannot be corrected automatically. Ruby snippet style checks are not enabled.

To develop rubocop-md locally, check out its `configurable-front-matter` branch and run `bundle config set --local local.rubocop-md /path/to/rubocop-md` from this repository. This local override is ignored by Git; CI uses the revision in `Gemfile.lock`.

To correct paragraph wrapping automatically, run `bundle exec rubocop --only Markdown/MaxLength -a`. Review the resulting changes before committing; intentional Markdown hard breaks and `<br>` boundaries are preserved.

### Spell Checker

Install [pyspelling](https://facelessuser.github.io/pyspelling/).

```bash
pyspelling --config .pyspelling.yml
```

Modify [pyspelling.words](.pyspelling.words) as needed.

For an incremental check, run `bundle exec rake spell:staged`. It checks the staged versions of added or modified Markdown files, not edits outside the index. Changing the spelling configuration or dictionary triggers a full check of tracked Markdown files. Generated files and third-party directories remain excluded; CI continues to check the full archive.

### Style Checker

```bash
vale .
```

### Pre-Commit Hooks

Install tools.

```bash
python3 -m pip install pyspelling
npm ci
```

Add a pre-commit hook, `.git/hooks/pre-commit`.

```bash
#!/bin/bash

exec bundle exec rake precommit
```

`bundle exec rake lint` runs both Markdown linters independently of spelling; `npm run lint:markdown` invokes the same checks. The existing `bundle exec rake check` remains the full site build and link check. Ruby orchestrates these commands; Node and Python are still required by markdownlint and PySpelling respectively.

## Thank You

Please do know that we really appreciate and value your time and work. We love you, really.
