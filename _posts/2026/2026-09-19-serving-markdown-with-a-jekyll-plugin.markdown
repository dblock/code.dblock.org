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

### What About llms.txt?

There's a related convention, [llms.txt](https://llmstxt.org), a single root-level file that's supposed to give an AI agent a curated map of a site. I considered adding `llms.txt` generation to `jekyll-md`, then didn't. The spec is explicit that the file should "stay small enough to fit in context" and contrasts itself with `sitemap.xml`, which it calls out for being too large and unfiltered to be useful. A plugin walking every page and dumping it into `llms.txt` - which is what some similar plugins do by default - just recreates the sitemap problem in Markdown instead of solving it. This blog alone has almost 600 posts; nobody wants all of them in one file.

Instead, I wrote `llms.txt` by hand as a plain Jekyll page with Liquid front matter, listing a handful of pinned posts, the 10 most recent ones, and a few key pages, reusing this blog's existing `pinned: true` front matter flag rather than inventing a new mechanism. You can see the result at [code.dblock.org/llms.txt](https://code.dblock.org/llms.txt) and the [template that generates it](https://github.com/dblock/code.dblock.org/blob/gh-pages/llms.txt).

### Meta

- [jekyll-md](https://github.com/dblock/jekyll-md).
- [Serving Markdown for AI Agents](/2026/01/15/serving-markdown-for-ai-agents.html), the original post.
- [Added GitHub Actions workflow to deploy and serve markdown.](https://github.com/dblock/code.dblock.org/commit/6fab9f3)
- [Use jekyll-md gem to serve Markdown for AI agents.](https://github.com/dblock/code.dblock.org/commit/92bdb7c)
- [Add curated llms.txt.](https://github.com/dblock/code.dblock.org/commit/1a40e12)
