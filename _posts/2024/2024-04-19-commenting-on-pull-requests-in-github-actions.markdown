---
layout: post
title: Commenting on Pull Requests in GitHub Actions
date: 2024-04-19
tags: [opensearch, gha]
comments: true
---
The [OpenSearch API specification](https://github.com/opensearch-project/opensearch-api-specification) is authored in OpenAPI and used to auto-generate OpenSearch language clients. I wanted to know how much of the API was described in it vs. the actual API implemented in the [default distribution of OpenSearch](https://opensearch.org/downloads.html) that includes all plugins. To do so, I have [exposed an iterator over REST handlers in OpenSearch core](https://github.com/opensearch-project/OpenSearch/pull/11876), and [wrote a plugin](https://github.com/dblock/opensearch-api) that rendered a very minimal OpenAPI spec at runtime. All that was left was to compare the manually authored OpenAPI spec in opensearch-api-specification to the runtime one, added in [opensearch-api-specification#179](https://github.com/opensearch-project/opensearch-api-specification/pull/179). The comparison workflow output a total and relative number of APIs described.

To surface this information in pull requests I wanted to add a comment in the API coverage workflow. This required a PAT token, so I initially authored that workflow with `pull_request_target` in [opensearch-api-specification#196](https://github.com/opensearch-project/opensearch-api-specification/pull/196).

{% highlight yaml %}
{% raw %}
- name: Gather Coverage
  id: coverage
  shell: bash
  run: |
    ...
    cat >>"$GITHUB_OUTPUT" <<EOL
    current=$current
    total=$total
    percent=$percent
    EOL
- uses: peter-evans/create-or-update-comment@v4
  if: github.event_name == 'pull_request_target'
  with:
    issue-number: ${{ github.event.number }}
    body: |
        API specs implemented for ${{ steps.coverage.outputs.current }}/${{ steps.coverage.outputs.total }} (${{ steps.coverage.outputs.percent }}%) APIs.
{% endraw %}
{% endhighlight %}

This is actually insecure because we run a JavaScript tool to generate the API spec with source code coming from the pull request, and a user can execute arbitrary code this way and gain access to the secure token. One solution is to run the tool from `main`, but we can [do better](https://securitylab.github.com/research/github-actions-preventing-pwn-requests/).

In [opensearch-api-specification#251](https://github.com/opensearch-project/opensearch-api-specification/pull/251) I split the coverage workflow in one that gathered information into a JSON file and uploaded it as an artifact of the pull request workflow, and another that downloaded the artifact and commented on the pull request.

{% highlight yaml %}
{% raw %}
name: Gather API Coverage
on: [push, pull_request]

- name: Gather Coverage
  id: coverage
  shell: bash
  run: |
    ...
    cat >>"coverage.json" <<EOL
    {
      "pull_request":${{ github.event.number }},
      "current":$current,
      "total":$total,
      "percent":$percent
    }
    EOL
- uses: actions/upload-artifact@v4
  with:
    name: coverage
    path: coverage.json
{% endraw %}
{% endhighlight %}

{% highlight yaml %}
{% raw %}
name: Comment with API Coverage

on:
  workflow_run:
    workflows: ["Gather API Coverage"]
    types:
      - completed

jobs:
  comment:
    runs-on: ubuntu-latest
    if: >
      github.event.workflow_run.event == 'pull_request' &&
      github.event.workflow_run.conclusion == 'success'
    steps:
      - name: Download Coverage Report
        uses: actions/download-artifact@v4
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          name: coverage
          run-id: ${{ github.event.workflow_run.id }}

      - name: 'Comment on PR'
        uses: actions/github-script@v3
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const fs = require('fs');
            var data = JSON.parse(fs.readFileSync('./coverage.json'));
            console.log(data);
            await github.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: data.pull_request,
              body: `API specs implemented for ${data.current}/${data.total} (${data.percent}%) APIs.`
            });
{% endraw %}
{% endhighlight %}

This is a very convenient pattern of passing structured data from a pull request workflow to one that has access to write data in a GitHub repository. Check out the [latest versions of the coverage workflows](https://github.com/opensearch-project/opensearch-api-specification/tree/main/.github/workflows) if you are going to use them.
