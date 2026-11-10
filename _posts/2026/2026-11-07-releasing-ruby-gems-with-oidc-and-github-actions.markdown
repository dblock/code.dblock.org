---
layout: post
title: "Releasing Ruby Gems with OIDC and GitHub Actions"
date: 2026-11-07
tags: [ruby, open-source, github-actions]
---
Releasing Ruby gems manually typically involves incrementing a version in a file, creating a tag, pushing a gem to Rubygems and making a GitHub release. These tasks can be automated in many ways, including [release-gem](https://github.com/rubygems/release-gem) or GHA with [`rubygems/configure-rubygems-credentials`](https://github.com/rubygems/configure-rubygems-credentials) and trusted publishing. Moreover, you can build upon these approaches when you need something beyond the plain `rake release`, such as updating a `CHANGELOG.md`, by rolling miles of brittle GitHub Actions YAML and shell script AI slop.

As an alternative to both the manual process and scripts, I've been asking AI to follow a hand-crafted `RELEASING.md`. AI can run tests, date `CHANGELOG.md`, ask me for a RubyGems OTP, make the release, increment the version of the next developer iteration. This worked quite well!

Still, AI is a very blunt tool for something that should be mechanized. Therefore, I built [ruby-gem-release](https://github.com/dblock/ruby-gem-release) to automate all release bookkeeping in Ruby in an extensible workflow with near-zero code. While simple to use, it's a completely customizable system that lets you automate a release in Ruby and supports advanced workflows such as semantic releases, allows to [retry and recover failed publications](https://github.com/dblock/ruby-gem-release/blob/v0.5.0/RELEASING.md#verify-and-recover) and preserves artifacts on failure.

The release itself runs in GitHub Actions. [RubyGems Trusted Publishing](https://guides.rubygems.org/trusted-publishing/) supplies short-lived credentials, so there is no RubyGems API key to store in GitHub secrets or share with other maintainers. After setup, collaborators with write access can dispatch releases too.

As an example, I [added it to ruby-link-checker](https://github.com/dblock/ruby-link-checker).

Here's the Rakefile addition:

```ruby
require 'ruby-gem-release/workflow/ruby_gem'
require 'ruby-gem-release/changelog'

RubyGemRelease::Workflow::RubyGem.new(
  version: RubyGemRelease::Version::RubyConstant.new(path: 'lib/ruby-link-checker/version.rb', constant: 'VERSION'),
  changelog: RubyGemRelease::Changelog::Intridea.new(placeholder: '* Your contribution here.')
).install_tasks
```

The version strategy reads a constant from `lib/ruby-link-checker/version.rb`:

```ruby
module LinkChecker
  VERSION = '0.5.0'.freeze
end
```

The `CHANGELOG.md` in this project is in the Intridea style. The gem also supports [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Before publishing `0.5.0` the `CHANGELOG.md` is updated with a date. After publishing, the `VERSION` constant is incremented to `0.5.1`, and `CHANGELOG.md` is updated with a `Next` section.

Add `.github/workflows/release.yml` to call the reusable release workflow. The optional `version` input selects a different release version, and `rubygems-owner` accepts your numeric RubyGems account ID when publishing a new gem for the first time:

{% raw %}

```yaml
name: Release

on:
  workflow_dispatch:
    inputs:
      version:
        description: Optional release version overriding the checked-in version.
        required: false
        type: string
      rubygems-owner:
        description: RubyGems account ID for first publication; omit for an existing gem.
        required: false
        type: string

permissions:
  contents: write
  id-token: write

jobs:
  release:
    uses: dblock/ruby-gem-release/.github/workflows/release.yml@v0.5.0
    with:
      ruby-version: '3.3'
      version: ${{ inputs.version }}
      rubygems-owner: ${{ inputs.rubygems-owner }}
```

{% endraw %}

There's a bit of work to configure the trusted publisher for the first release. The [setup instructions](https://github.com/dblock/ruby-gem-release#usage) cover that.

You can configure the `release` environment to require [maintainer approval](https://github.com/dblock/ruby-gem-release/blob/master/RELEASING.md#maintainer-approved-publication). Repository writers can still dispatch a release, but the job waits for an approved maintainer before it runs. Creating an environment without protection rules doesn't restrict releases; availability of those rules depends on the repository and GitHub plan.

After validating and reviewing the changes, publish a new gem with the numeric RubyGems account ID shown on the pending trusted publisher page:

```sh
gh workflow run release.yml --repo dblock/ruby-link-checker --ref main -f rubygems-owner=YOUR_ACCOUNT_ID
```

For subsequent releases, omit `rubygems-owner`:

```sh
gh workflow run release.yml --repo dblock/ruby-link-checker --ref main
```

By default, the workflow releases the checked-in version. To select a different version, pass `-f version=0.6.0`; the standard workflow updates the version file before preparing the changelog and increments from that version for the next development iteration.

There's also a [composite action](https://github.com/dblock/ruby-gem-release/blob/v0.5.0/docs/actions/action.md) for projects that need to own the surrounding job, runner, permissions, and environment. Both interfaces use the same Ruby tasks. Authentication happens during publication through the configured registry destination; custom destinations can supply their own authentication and upload behavior without replacing Git or GitHub Releases.

## Advanced: Custom Callbacks

For notifications, keep the standard workflow and add success and failure callbacks:

```ruby
require 'ruby-gem-release/workflow/ruby_gem'
require 'ruby-gem-release/changelog'

RubyGemRelease::Workflow::RubyGem.new(
  version: RubyGemRelease::Version::RubyConstant.new(path: 'lib/example/version.rb', constant: 'VERSION'),
  changelog: RubyGemRelease::Changelog::KeepAChangelog.new,
  success: ->(ctx) { puts "Published #{ctx.release.version}; next version is #{ctx.release.next_version}" },
  failure: ->(failure) { warn "Release failed during #{failure.phase}: #{failure.error&.message}" }
).install_tasks
```

Callbacks receive an execution context: `ctx.release` contains the version, original gemspec version, date, and next development version; `ctx.workflow` exposes the configured components. On Actions, the context also includes observed step outcomes and run metadata. Failure callbacks receive the failed phase, captured Ruby exception details when available, and a context whose release can be absent if capture failed.

For complete control, register [custom callbacks](https://github.com/dblock/ruby-gem-release/blob/v0.5.0/docs/usage.md#custom-callbacks) with `Tasks.install`: `validate`, `prepare`, `publish`, `bump`, `success`, and `failure`. Validation raises on invalid state; returning `false` also fails. Wrap trusted file edits in `git.stage_changes!`, publish the verified package before pushing its commit and tag, and record the next version with `ctx.record_next_version!` only after its commit and push succeed.

The architectural distinction of [ruby-gem-release](https://github.com/dblock/ruby-gem-release) with similar projects is that this sequence is exposed as ordinary Ruby objects and callbacks, so project-specific changes can be tested without accumulating YAML/shell glue. Keeping the release logic in pure Ruby is a less brittle approach than spreading it across shell scripts. Version changes, changelog updates, and publication are ordinary objects and method calls that you can test and customize without another layer of shell quoting or GitHub expression interpolation.

For an advanced example, see the [self-release configuration](https://github.com/dblock/ruby-gem-release/blob/v0.5.0/examples/self_release/README.md), which customizes the version strategy to update action and workflow references in README and every Markdown file under `docs/` to the version just released. It makes those edits after publication, as part of the next development iteration commit, so the documentation never points at an unpublished tag. It's implemented in Ruby and has tests.

## Conventional Commits

If you prefer [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) to handwritten pending changelog entries, replace the manual workflow configuration with:

```ruby
require 'ruby-gem-release/workflow/semantic_ruby_gem'

RubyGemRelease::Workflow::SemanticRubyGem.new(
  version: RubyGemRelease::Version::RubyConstant.new(path: 'lib/example/version.rb', constant: 'VERSION')
).install_tasks
```

This keeps the same manually dispatched Actions workflow. It selects a version from commits after the highest reachable stable release tag, generates notes and a changelog section, and persists the decision once for later tasks. Breaking changes select major, `feat` selects minor, and `fix` or `perf` selects patch. The first release defaults to `1.0.0`; no eligible changes fails validation rather than quietly skipping.

Semantic releases don't bump the development version by default; add `bump: true` if you want that. The [semantic release guide](https://github.com/dblock/ruby-gem-release/blob/v0.5.0/docs/workflow/semantic_ruby_gem.md) covers custom rules, explicit versions, and replacing the history, analysis, version-selection, or notes providers. Install either the manual or semantic configuration, not both.

I also [migrated the custom release workflow in danger-pr-comment](https://github.com/numbata/danger-pr-comment/pull/15). The release YAML went from 172 lines to 42, a 76% reduction, retaining the project's custom checks and updates to references in the README during release.
