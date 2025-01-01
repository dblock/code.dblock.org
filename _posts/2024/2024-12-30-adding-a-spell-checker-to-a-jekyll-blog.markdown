---
layout: post
title: Adding a Spell Checker to a Jekyll Blog
date: 2024-12-30 01:00:00
tags: [blog, jekyll]
comments: true
---
I found it annoyingly non-trivial to add a spell checker to this blog.

For now, I settled on [GitHub Spellcheck Action](https://github.com/marketplace/actions/github-spellcheck-action#extra-configuration-for-markdown) that uses [PySpelling](https://facelessuser.github.io/pyspelling) on files changed in the commit or pull request as described in [this blog post](https://swild.dev/self-hosting/github-spellcheck-lint-action/).

{% raw %}

```yaml
name: Check Spelling
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: tj-actions/changed-files@v45
        id: changed_files
        with:
          files: |
            **/**.md
            **/**.markdown
      - name: Check Spelling
        uses: rojopolis/spellcheck-github-actions@0.45.0
        with:
          task_name: Markdown
          config_path: .pyspelling.yml
          source_files: ${{ steps.changed_files.outputs.all_changed_files }}
```

{% endraw %}

To run PySpelling locally ensure you have a working version of Python, install PySpelling with `pip install pyspelling`, and [aspell](http://aspell.net/) with `brew install aspell` on a Mac. In [my configuration]() I also use `pymdownx` from [pymdown-extensions](https://facelessuser.github.io/pymdown-extensions) which is installed with `pip install pymdown-extensions`.

You need a [.pyspelling.yml](https://github.com/dblock/code.dblock.org/blob/gh-pages/.pyspelling.yml) and you can run it as follows.

```bash
pyspelling --config .pyspelling.yml
```

This is a Jekyll blog in which we want to ignore code, wrapped between Jekyll magic commands for syntax highlighting. This can be accomplished with a PySpelling pipeline in the above-mentioned configuration file.

{% raw %}

```yaml
pipeline:
  - pyspelling.filters.context:
      context_visible_first: true
      delimiters:
        # ignore jekyll multiline magic highlights {% ... %}
        - open: '(?s)^\{\% highlight .* \%\}$'
          close: '^\{\% endhighlight \%\}$'
        # ignore the rest of jekyll magic commands
        - open: '{%'
          close: '%}'
```

{% endraw %}

Finally, we can collect the initial set of words to potentially exclude from existing posts into [.pyspelling.words](https://github.com/dblock/code.dblock.org/blob/gh-pages/.pyspelling.words).

```bash
pyspelling --config .pyspelling.yml | \
  sed -n '/^Misspelled words:$/,/^-*$/!p' | \
  grep -v "^---\+$" | \
  grep -v "^$" | \
  sort | \
  uniq > .pyspelling.words
```

The file helped me spot a few spelling mistakes, now fixed. See [code.dblock.org#134](https://github.com/dblock/code.dblock.org/pull/134) for the full change.

Update: I eventually switched to using regular backticks for code when adding a style checker in [#136](https://github.com/dblock/code.dblock.org/pull/136), so the above `delimiters` rule changed as follows.

{% raw %}

```yaml
- pyspelling.filters.context:
    context_visible_first: true
    escapes: \\[\\`~]
    delimiters:
      - open: "(?s)^(?P<open> *`{3,})([a-z+]*)$"
        close: "^(?P=open)$"
      - open: "(?P<open>`+)"
        close: "(?P=open)"
      - open: '{%'
        close: '%}'
```

{% endraw %}