---
layout: post
title: Automating Code Changes via GitHub Actions Making Pull Requests
date: 2021-08-13
tags: [github, github actions]
comments: true
---
You've probably been depending on automated pull requests from [Dependabot](https://dependabot.com/), but how about making your own pull requests from GitHub actions? This capability can be used for automation that looks for changes, then updates files in your own repository with little to no additional setup needed.

* In [dblock/lost-robbies](https://github.com/dblock/lost-robbies/blob/master/.github/workflows/check-sales.yml) the workflow checks for new sales and raises a PR after updating the JSON data and the `README.md`.
* In [opensearch-project/project-meta](https://github.com/opensearch-project/project-meta/blob/main/.github/workflows/check-repos.yml) the workflow enumerates public repositories in the opensearch-project organization and adds new repos to a `.meta` file.

Below are some implementation details from [opensearch-project/project-meta](https://github.com/opensearch-project/project-meta/blob/main/.github/workflows/check-repos.yml).

### GitHub Action Setup

The job is executed on all changes to `main` and daily at midnight.

{% highlight yaml %}
name: Check for new Project Repos
on:
  push:
    branches:
      - main  
  schedule:
    - cron: "0 0 * * *"
{% endhighlight %}

### Permissions and Tokens

The job checks out code, and needs a `GITHUB_TOKEN` in `env.` to make pull requests.

{% highlight yaml %}
{% raw %}
jobs:
  check-project-repos:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Update project repositories
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}      
{% endraw %}
{% endhighlight %}

### Generating a PR Title and Body

At first I was hard-coding PR titles and commit messages. That's not ideal. Compare the following PRs. The second version is much more specific!

![](https://user-images.githubusercontent.com/542335/129234923-42116ea8-dee6-4247-a904-35862d67919a.png)

![](https://user-images.githubusercontent.com/542335/129370221-380b84a1-e65d-4da5-8bb3-83a9277b946f.png)

This can be achieved by setting an environment variable during the workflow execution by piping it into `$GITHUB_ENV`, and reusing it in the PR.


{% highlight bash %}
echo REPOS_ADDED=$(git diff --unified=0 .gitignore | grep '+/' | cut -f2 -d'/' | paste -sd ',' - | sed "s/,/, /g" | sed 's/\(.*\),/\1 and/') >> $GITHUB_ENV
{% endhighlight %}

1. The workflow modifies `.gitignore` by adding lines to it, such as `/cross-cluster-replication/`.
2. Find all additions that start with `+/` using `| grep '+/'`.
3. Extract the name of each addition with `| cut -f2 -d'/'`, e.g. `cross-cluster-replication`.
4. Combine all additions into a comma-separated list with `| paste -sd ',' -`.
5. Add a space after each comma with `| sed "s/,/, /g" |`.
6. Replace the last comma by an `and` with `| sed 's/\(.*\),/\1 and/'`.
7. Pipe everything into `REPOS_ADDED=` with `echo REPOS_ADDED=$(...) >> $GITHUB_ENV`.

### Make a Pull Request

{% highlight yaml %}
{% raw %}
- name: Create Pull Request
  uses: peter-evans/create-pull-request@v3
  with:
    commit-message: Added ${{ env.REPOS_ADDED }}.
    delete-branch: true
    title: 'Added ${{ env.REPOS_ADDED }}.'
    body: |
      Added ${{ env.REPOS_ADDED }}.
- name: Check outputs
  run: |
    echo "Pull Request Number - ${{ steps.cpr.outputs.pull-request-number }}"
    echo "Pull Request URL - ${{ steps.cpr.outputs.pull-request-url }}"
{% endraw %}
{% endhighlight %}

### Profit

See [opensearch-project/project-meta#7](https://github.com/opensearch-project/project-meta/pull/7) for an example.