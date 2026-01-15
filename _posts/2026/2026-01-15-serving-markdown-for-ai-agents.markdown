---
layout: post
title: Serving Markdown for AI Agents
date: 2026-01-15
tags: [ai, jekyll]
comments: true
---
Dries Buytaert recently wrote about [The Third Audience](https://dri.es/the-third-audience). For decades, websites have targeted two audiences: humans and search engines. AI agents are now the third audience, and most websites aren't optimized for them yet.

AI agents prefer clean, structured content over HTML. Markdown is ideal - it's readable, semantic, and free of navigation chrome. So I made this blog serve its source markdown files alongside the HTML.

### How It Works

For every post like [/2026/01/15/serving-markdown-for-ai-agents.html](/2026/01/15/serving-markdown-for-ai-agents.html), you can now fetch the source at [/2026/01/15/serving-markdown-for-ai-agents.md](/2026/01/15/serving-markdown-for-ai-agents.md).

AI agents can discover this via a `<link>` tag in the HTML head:

```html
<link href="serving-markdown-for-ai-agents.md"
      type="text/markdown"
      rel="alternate"
      title="Markdown">
```

### Implementation

Since this is a GitHub Pages blog, custom Jekyll plugins don't work. Instead, I added a [GitHub Actions workflow](https://github.com/dblock/code.dblock.org/blob/gh-pages/.github/workflows/deploy.yml) that builds Jekyll and copies the markdown source files to `_site` before deployment.

The workflow extracts the date and slug from each post filename and copies it to the matching URL path with a `.md` extension.

### Should You Do This?

Dries raises a valid concern: are we just making it easier for AI companies to use our content without sending traffic back? Perhaps. But AI agents are already crawling our sites. Giving them cleaner input might lead to better attribution and more accurate responses that reference our work.

The web has always been about making information accessible. This is just the next evolution.

Plus, we will soon all work for AI anyway, so might as well get on its good side.

### Meta

This entire feature was implemented by [Claude](https://claude.ai), and this post was written by it as well.

- [Added GitHub Actions workflow to deploy and serve markdown.](https://github.com/dblock/code.dblock.org/commit/6fab9f3)
- [Use Ruby 3.4 in deploy workflow.](https://github.com/dblock/code.dblock.org/commit/45769b0)
- [Also serve page markdown files.](https://github.com/dblock/code.dblock.org/commit/e5cb737)
- [Added link rel alternate for markdown discovery.](https://github.com/dblock/code.dblock.org/commit/fcff077)
- [Moved markdown link to post layout.](https://github.com/dblock/code.dblock.org/commit/e5eede2)
- [Fixed markdown alternate URL to remove .html.](https://github.com/dblock/code.dblock.org/commit/f6ae02a)
- [Serving Markdown for AI Agents.](https://github.com/dblock/code.dblock.org/commit/5ef474c)
