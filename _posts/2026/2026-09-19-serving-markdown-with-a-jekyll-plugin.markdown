---
layout: post
title: Serving Markdown for AI Agents, Now as a Jekyll Plugin
date: 2026-09-19
tags: [ai, jekyll]
---
Back in January I wrote [Serving Markdown for AI Agents](/2026/01/15/serving-markdown-for-ai-agents.html): for every page on this blog, there's also a `.md` version at the same URL, discoverable via a `<link rel="alternate" type="text/markdown">` tag, so AI agents can fetch clean Markdown instead of parsing HTML. It also [made me $360](/2026/04/11/how-i-made-360-dollars-by-serving-markdown-from-my-jekyll-blog.html), via referral conversions an AI agent apparently generated after reading the clean Markdown version of a post.

<img src="{{ site.url }}/images/posts/2026/2026-09-19-serving-markdown-with-a-jekyll-plugin/jekyll-markdown.gif" />

That worked, but it lived in this repo as a one-off script, `_scripts/render_markdown.rb`, [wired into the GitHub Actions deploy workflow](https://github.com/dblock/code.dblock.org/commit/6fab9f3) (needed since GitHub Pages' native build only allows a small [allowlist of plugins](https://pages.github.com/versions/), which `jekyll-md` isn't on), with the `<link>` tags added by hand via Liquid and a `markdown_url` front matter field on every page.

I've since extracted all of it into [jekyll-md](https://github.com/dblock/jekyll-md), a proper Jekyll plugin. It does the same thing - converts each page's fully rendered HTML output to Markdown and injects the discovery `<link>` tag - but as a `Jekyll::Generator` and `Jekyll::Hooks`, with no external script or per-page front matter required.

### What Changed

Add the gem and enable the plugin:

```ruby
# Gemfile
gem 'jekyll-md'
```

```yaml
# _config.yml
plugins:
  - jekyll-md
```

If you don't configure anything else, `jekyll-md` looks for `<main>` or `[role="main"]` before falling back to the whole `<body>`, since that's the closest thing HTML has to a content/chrome convention. You can also configure a CSS selector to convert from, e.g. `md: selector: "#markdown-content"`, and other options - see the [README](https://github.com/dblock/jekyll-md#readme) for the full list.

### Meta

- [jekyll-md](https://github.com/dblock/jekyll-md).
- [Serving Markdown for AI Agents](/2026/01/15/serving-markdown-for-ai-agents.html), the original post.
- [Added GitHub Actions workflow to deploy and serve markdown.](https://github.com/dblock/code.dblock.org/commit/6fab9f3)
- [Use jekyll-md gem to serve Markdown for AI agents.](https://github.com/dblock/code.dblock.org/commit/92bdb7c)
