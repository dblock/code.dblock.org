---
layout: post
title: Triggering CI from Pull Requests and Force Pushes in GitHub Actions
date: 2023-04-29
tags: [github, gha]
comments: true
---
The [slack-ruby-client](https://github.com/slack-ruby/slack-ruby-client/) generates code from an [API reference](https://github.com/slack-ruby/slack-api-ref) scraped from the Slack documentation website. Until now, the update process was a manual operation involving checking out the code, running a `rake` task, updating a `CHANGELOG.md`, and making a pull request, e.g. [slack-ruby-client#455](https://github.com/slack-ruby/slack-ruby-client/pull/455).

Let's automate this using GitHub Actions (GHA)! We'll need some advanced token-fu to auto-trigger CI. 

A basic job that runs on cron, daily at 11:15PM.

{% highlight yaml %}
{% raw %}
name: Update API
on:
  workflow_dispatch:
  schedule:
    - cron: "15 23 * * *"
jobs:
  update-api:
    runs-on: ubuntu-latest
{% endraw %}
{% endhighlight %}

Scope permissions to r/w access to repo contents and pull requests.

{% highlight yaml %}
{% raw %}
permissions:
  contents: write
  pull-requests: write
{% endraw %}
{% endhighlight %}

Check-out the code, and run the `rake` task that updates the API.

{% highlight yaml %}
{% raw %}
steps:
  - uses: actions/checkout@v3
    with:
      submodules: recursive
  - name: Set up Ruby
    uses: ruby/setup-ruby@v1
    with:
      ruby-version: "3.2"
      bundler-cache: true
  - name: Update API from slack-api-ref
    run: bundle exec rake slack:api:update
{% endraw %}
{% endhighlight %}

Create a pull request with the changes.

{% highlight yaml %}
{% raw %}
- name: Create pull request
  id: cpr
  uses: peter-evans/create-pull-request@v4
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    commit-message: Update API from slack-api-ref
    title: Update API from slack-api-ref
    body: |
      Update API from slack-api-ref.
    branch: automated-api-update
    base: master
{% endraw %}
{% endhighlight %}

This works, but does not trigger CI. This is by design, because `GITHUB_TOKEN` is [not allowed to](https://github.com/peter-evans/create-pull-request/issues/48).

To trigger CI we need a different token. You can create a personal access token (PAT), but that would run CI under your account, which may exclude you from approving PRs because of branch protection rules. A better solution is to use a token from [an org-owned GitHub app](https://docs.github.com/en/apps/creating-github-apps). I created one called "Slack Ruby CI Bot", and gave it r/w permissions for "Contents" and "Pull Requests", then installed it in the [slack-ruby GitHub org](https://github.com/slack-ruby) and noted the installation ID. I also generated a new private key from the bottom of the [app settings page](https://github.com/organizations/slack-ruby/settings/apps/slack-ruby-ci-bot) and set two repo secrets: `CI_APP_ID` to the value of the app ID, and `CI_APP_PRIVATE_KEY` for the contents of the private key from the `.pem` file downloaded from GitHub.

Get the the app token in GHA.

{% highlight yaml %}
{% raw %}
- name: GitHub App token
  id: github_app_token
  uses: tibdex/github-app-token@v1.6.0
  with:
    app_id: ${{ secrets.CI_APP_ID }}
    private_key: ${{ secrets.CI_APP_PRIVATE_KEY }}
    installation_id: 36985419
{% endraw %}
{% endhighlight %}

Use it in the pull request GHA, with a fallback to `GITHUB_TOKEN` for testing the GHA in my fork.

{% highlight yaml %}
{% raw %}
- name: Create pull request
  id: cpr
  uses: peter-evans/create-pull-request@v4
  with:
    token: ${{ steps.github_app_token.outputs.token || secrets.GITHUB_TOKEN }}
{% endraw %}
{% endhighlight %}

Now that PRs trigger CI, and commits are made by `slack-ruby-ci-bot`, let's update `CHANGELOG.md` with the PR number output by the `create-pull-request` action. A text search-and-replace will do.

{% highlight yaml %}
{% raw %}
- uses: jacobtomlinson/gha-find-replace@v3
  if: ${{ steps.cpr.outputs.pull-request-number != '' }}
  with:
    include: CHANGELOG.md
    find: "\\* Your contribution here."
    replace: "* [#${{steps.cpr.outputs.pull-request-number}}] ...\n* Your contribution here."
{% endraw %}
{% endhighlight %}

We can amend the previous pull request and force-push the change back to GitHub. To authenticate to GitHub using the above-mentioned token we generate a base64-encoded BASIC auth `x-access-token:token` header, then stuff it into all HTTP requests made by `git`. This is what the `create-pull-request` action actually does in code, too.

{% highlight yaml %}
{% raw %}
- name: Commit and Push
  run: |
    git config --local user.name 'slack-ruby-ci-bot'
    git config --local user.email 'noreply@github.com'
    git config --local --unset-all http.https://github.com/.extraheader || true
    AUTH=$(echo -n "x-access-token:${{ steps.github_app_token.outputs.token || secrets.GITHUB_TOKEN }}" | base64)
    echo "::add-mask::${AUTH}"
    git config --local http.https://github.com/.extraheader "AUTHORIZATION: basic ${AUTH}"
    git add CHANGELOG.md
    git commit --amend --no-edit
    git push origin automated-api-update -f
{% endraw %}
{% endhighlight %}

Bonus features include getting the current date and the git commit of the updated submodule that contains the API reference to make the CHANGELOG and the commit messages pretty.

{% highlight yaml %}
{% raw %}
- name: Get current date
  id: date
  run: echo "::set-output name=date::$(date +'%Y-%m-%d')"
{% endraw %}
{% endhighlight %}

{% highlight yaml %}
{% raw %}
- name: Get slack-api-ref ref
  id: api-ref
  run: echo "::set-output name=api-ref::$(git rev-parse --short HEAD:lib/slack/web/api/slack-api-ref)"
{% endraw %}
{% endhighlight %}

The final result is [here](https://github.com/slack-ruby/slack-ruby-client/blob/master/.github/workflows/update_api.yml) and you can see it in action in [slack-ruby-client#465](https://github.com/slack-ruby/slack-ruby-client/pull/465).
