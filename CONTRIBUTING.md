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
  - [Link Checker](#link-checker)
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

Install Ruby. We recommend [rvm](https://rvm.io/). Use Ruby 3.4, as in CI.

```bash
rvm use 3.4
```

Install bundler.

```bash
gem install bundler
```

Install dependencies.

```bash
bundle install
```

Install libvips, which renders the posts' social cards.

```bash
brew install vips
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

### Link Checker

Links are checked by [jekyll-ruby-link-checker](https://github.com/dblock/jekyll-ruby-link-checker), configured under `link_checker` in `_config.yml`: excluded domains, URLs, and paths, headers for sites that need them, and a cache in `.cache/link-checker.json` that remembers working links for 30 days and links it couldn't verify for 7. Links that bot protection blocks, for example with a 403 or a Cloudflare challenge, are reported as unverified and don't fail the build; only dead links do. Run `bundle exec rake links` to build the site with future posts and check links using the same command as CI: `LINK_CHECKER=1 bundle exec jekyll build --future`. `bundle exec rake check` is an alias for the same task. Post dates have no time zone and CI builds in UTC, so run `TZ=UTC bundle exec rake links` when a link to a post that exists is reported as not found.

The `Check Links` workflow runs on pushes to `gh-pages`, twice a week, and on pull requests. Pull requests only check the pages they change, and report dead links without failing. Runs that check every page also forget links that are no longer on the site. The `Publish Link Checker Report` workflow then comments with the dead links on the pull request, and on `gh-pages` keeps issue #181 up to date, closing it when all links work. The `Gemfile` and both reusable workflows use the same version of jekyll-ruby-link-checker; update them together.

### Markdown Linter

Markdown lint uses released [rubocop-prose](https://github.com/dblock/rubocop-prose) 0.2.x, and released [rubocop-md](https://github.com/rubocop/rubocop-md) 3.x applies Ruby checks to explicitly Ruby-tagged code fences. Dependency versions are pinned in `Gemfile.lock`. Update them with `bundle update rubocop-prose rubocop-md`. Unlabeled and non-Ruby code blocks are not interpreted as Ruby.

```bash
bundle exec rake lint
```

Configuration is in `.rubocop.yml`. Prose paragraphs stay on one source line by default (`Prose/MaxLength`, with `Max: false`), preserving intentional hard breaks. The configuration retains the archive's existing Markdown style choices while adding table checks, sequential ordered-list numbering, and Ruby snippet linting. For safe autocorrection, run `bundle exec rubocop -a --except Spellcheck/Spelling` and review the changes, especially historical code examples.

CI runs `bundle exec rake test` before building the blog in the deployment workflow, not in the Markdown lint workflow.

### Spell Checker

Spelling uses [rubocop-spellcheck](https://github.com/dblock/rubocop-spellcheck), installed through Bundler, with its bundled English dictionary and the project's vocabulary:

```bash
bundle exec rake spell:check
```

Add legitimate project words to [.spellcheck.txt](.spellcheck.txt), one word per line in alphabetical order. No Python or system spelling dictionary is required.

Spelling shares `.rubocop.yml` with prose and Ruby lint and runs as part of `bundle exec rubocop`. Markdown code, destinations, and Liquid template expressions are skipped, except that Ruby snippets have their comments and string literals checked with the same settings as Ruby files; Ruby identifiers are not checked. Front matter spelling checks the `title` field. Raw HTML blocks and their attributes are not inspected.

For an incremental check, run `bundle exec rake spell:staged`. It checks the staged versions of added or modified Markdown files, not edits outside the index. Changing the spelling configuration, dictionary, or dependency manifests triggers a full check of tracked Markdown files. Generated files and third-party directories remain excluded; CI checks the full archive.

### Style Checker

Ruby lint uses RuboCop and `rubocop-rake`, with new cops enabled in `.rubocop.yml`. Ruby code fences are also checked through `rubocop-md`. Metrics checks are disabled for the existing scripts and plugins.

Posts can contain independent examples, so Markdown is excluded from file-wide class-count, constant-reassignment, and unreachable-code checks. Scoped RuboCop directives preserve intentionally historical or broken examples.

```bash
bundle exec rubocop
```

For prose style, run:

```bash
vale .
```

### Pre-Commit Hooks

Install tools.

```bash
bundle install
```

Add a pre-commit hook, `.git/hooks/pre-commit`.

```bash
#!/bin/bash

exec bundle exec rake precommit
```

`bundle exec rake lint` runs prose and Ruby lint independently of spelling. The existing `bundle exec rake check` remains the full site build and link check. Node is not required.

## Thank You

Please do know that we really appreciate and value your time and work. We love you, really.
