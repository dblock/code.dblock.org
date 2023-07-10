---
layout: post
title: Generating a Task Matrix by Looping over Repo Files with GitHub Actions
date: 2021-09-03
tags: [github, github actions]
comments: true
---
I've been having more fun with GitHub actions after [Automating Code Changes via GitHub Actions Making Pull Requests](/2021/08/13/automating-code-changes-with-github-actions-making-pull-requests.html). Let's generate a job matrix from a list of files.

Why would I need that? In [opensearch-project/opensearch-build](https://github.com/opensearch-project/opensearch-build/pull/386) we create manifest files that are used to produce an OpenSearch distribution. These files are created manually, one for every version. Each needs to be sanity-checked when created or changed. 

These checks can be executed in parallel, so we can create a GitHub Actions matrix like so.

{% highlight yaml %}
name: manifests
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    strategy:
        matrix:
            manifest:
                - manifests/opensearch-1.1.0.yml
                - manifests/opensearch-1.0.0.yml
    steps:
      - uses: actions/checkout@v2   
      - run: |
        ./check-manifest ${{ martix.manifest }}
{% endhighlight %}

We'll definitely forget to update the matrix when a new file is created, so let's just list those files dynamically, and generate a matrix from the list.


{% highlight yaml %}
{% raw %}
name: manifests
on: [push, pull_request]
jobs:
  list-manifests:
    runs-on: ubuntu-latest
    outputs:
      matrix: ${{ steps.set-matrix.outputs.matrix }}
    steps:
      - uses: actions/checkout@v2
      - id: set-matrix
        run: echo "::set-output name=matrix::$(ls manifests/*.yml | jq -R -s -c 'split("\n")[:-1]')"
  check:
    needs: list-manifests
    runs-on: ubuntu-latest
    strategy:
        matrix:
            manifest: ${{ fromJson(needs.list-manifests.outputs.matrix) }}
    steps:
      - uses: actions/checkout@v2   
      - run: |
        ./check-manifest ${{ martix.manifest }}
{% endraw %}
{% endhighlight %}

Here's how this works.

1. A shell command `ls manifests/*.yml` lists all .yml files.
2. A pipe to `| jq -R -s -c 'split("\n")[:-1]'` transforms the file list into a JSON array (from [StackOverflow#10234327](https://stackoverflow.com/questions/10234327/convert-bash-ls-output-to-json-array)). Note that [jq is installed on all GHA Linux images](https://github.com/actions/runner-images/blob/main/images/linux/Ubuntu2004-Readme.md). 
3. The `matrix` output is set to the JSON array of files using [set-output](https://docs.github.com/en/actions/reference/workflow-commands-for-github-actions#setting-an-output-parameter) with `echo "::set-output name=matrix::value`.
4. The `manifest` values are loaded from the JSON array using [fromJson](https://docs.github.com/en/actions/reference/context-and-expression-syntax-for-github-actions#fromjson) and become part of the updated workflow.
 
This is so awesome that it generates the matrix during the build!

![](https://user-images.githubusercontent.com/542335/132070992-4e9ba64f-a8f4-4459-9102-95684de2cda7.png)

### Profit

See [opensearch-project/opensearch-build#386](https://github.com/opensearch-project/opensearch-build/pull/386) for a working example.