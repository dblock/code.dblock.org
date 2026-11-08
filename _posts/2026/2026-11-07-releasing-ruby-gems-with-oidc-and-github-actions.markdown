---
layout: post
title: "Releasing Ruby Gems with OIDC and GitHub Actions"
date: 2026-11-07
tags: [ruby, open-source, github-actions]
---

The traditional approach for automating Ruby gem releases is to use [release-gem](https://github.com/rubygems/release-gem). It's super simple. You can also build upon it when you need something beyond the plain `rake release`, such as updating a `CHANGELOG.md`, by rolling miles of brittle GitHub Actions YAML and shell script AI slop.

Instead, I've been asking AI to follow a hand-crafted `RELEASING.md`. It can run tests, date `CHANGELOG.md`, ask me for a RubyGems OTP, make the release, increment the version of the next developer iteration. This works well.

Still, AI is a very blunt tool for something that should be mechanized. Therefore, I built [ruby-gem-release](https://github.com/dblock/ruby-gem-release) to automate all release bookkeeping in Ruby in an extensible workflow.

The release runs in GitHub Actions. [RubyGems Trusted Publishing](https://guides.rubygems.org/trusted-publishing/) supplies short-lived credentials, so there is no RubyGems API key to store in GitHub secrets or share with other maintainers. After setup, collaborators with write access can dispatch releases too.

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

Add `.github/workflows/release.yml` to call the reusable release workflow. The optional `rubygems-owner` input accepts your numeric RubyGems account ID when publishing a new gem for the first time:

{% raw %}

```yaml
name: Release

on:
  workflow_dispatch:
    inputs:
      rubygems-owner:
        description: RubyGems account ID for first publication; omit for an existing gem.
        required: false
        type: string

permissions:
  contents: write
  id-token: write

jobs:
  release:
    uses: dblock/ruby-gem-release/.github/workflows/release.yml@v0.3.1
    with:
      ruby-version: '3.3'
      rubygems-owner: ${{ inputs.rubygems-owner }}
```

{% endraw %}

There's a bit of work to configure the trusted publisher for the first release. The [setup instructions](https://github.com/dblock/ruby-gem-release#usage) cover that.

After validating and reviewing the changes, publish a new gem with the numeric RubyGems account ID shown on the pending trusted publisher page:

```sh
gh workflow run release.yml --repo dblock/ruby-link-checker --ref main -f rubygems-owner=YOUR_ACCOUNT_ID
```

For subsequent releases, omit `rubygems-owner`:

```sh
gh workflow run release.yml --repo dblock/ruby-link-checker --ref main
```

## Advanced: Custom Callbacks

For more control, replace the standard workflow installation in the Rakefile with [custom callbacks](https://github.com/dblock/ruby-gem-release/blob/master/docs/usage.md#custom-callbacks). Here's the full equivalent of the standard workflow:

```ruby
require 'ruby-gem-release/tasks'
require 'ruby-gem-release/changelog'
require 'ruby-gem-release/hosting/github_release'
require 'ruby-gem-release/package/ruby_gem'
require 'ruby-gem-release/source_control/git'

RubyGemRelease::Tasks.install do |tasks|
  version = RubyGemRelease::Version::RubyConstant.new(path: 'lib/example/version.rb', constant: 'VERSION')
  changelog = RubyGemRelease::Changelog::KeepAChangelog.new
  package = RubyGemRelease::Package::RubyGem.new
  git = RubyGemRelease::SourceControl::Git.new
  github = RubyGemRelease::Hosting::GitHubRelease.new
  tasks.before_release do |release|
    changelog.release!(release.with_version(version.read))
  end
  tasks.publish do |release|
    git.commit!(release)
    package.build!(release)
    git.tag!(release)
    package.publish!(release)
    git.push!(release)
    github.publish!(release, package: package)
  end
  tasks.after_release do |release|
    next_release = release.with_next_version(version.increment!)
    changelog.prepare_next!(next_release)
    git.commit_next!(next_release)
    git.push!
  end
end
```

The architectural distinction of [ruby-gem-release](https://github.com/dblock/ruby-gem-release) with similar projects is that this sequence is exposed as ordinary Ruby objects and callbacks, so project-specific changes can be tested without accumulating YAML/shell glue. Keeping the release logic in pure Ruby is a less brittle approach than spreading it across shell scripts. Version changes, changelog updates, and publication are ordinary objects and method calls that you can test and customize without another layer of shell quoting or GitHub expression interpolation.

For an advanced example, see [ruby-gem-release#18](https://github.com/dblock/ruby-gem-release/pull/18), which customizes the version strategy to update the action and workflow references in the README to the version just released. It makes that edit after publication, as part of the next development iteration commit, so the README never points at an unpublished tag. It's implemented in Ruby and has tests, so it won't break silently when the `README.md` changes.
