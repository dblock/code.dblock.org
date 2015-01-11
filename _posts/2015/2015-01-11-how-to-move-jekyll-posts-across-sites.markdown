---
layout: post
title: "How to Move Jekyll Posts Across Sites: Plain Redirects"
date: 2015-01-15
tags: [jekyll]
comments: true
---
I've recently [moved this blog to Jekyll](/2015/01/07/the-new-code-dblock-dot-org.html), moved all my art-related posts to a new [art.dblock.org](http://art.dblock.org) Jekyll blog and replaced [www.dblock.org](http://www.dblock.org) with a landing page. The last bit is to redirect any old popular content from the old www.dblock.org, such as [Your Commute is Killing You: Move to New York](/2011/05/29/dear-california-engineer-your-commute-is-killing-you-move-to-new-york.html) or [How To Frame and Hang Very Big Drawings](http://art.dblock.org/2007/12/18/big-frame-hanging.html) to one or the other site.

The landing [www.dblock.org](http://www.dblock.org) site is also a Jekyll site.

#### Include the Redirect Gem

Include the `jekyll-redirect-from` gem in `_config.yml`.

{% highlight yaml %}
gems:
  - jekyll-redirect-from

{% endhighlight %}

#### Create a Redirect Layout

Create a redirect layout. This does the actual redirected to `page.target_uri`.

{% highlight html %}
<!doctype html>
  <head>
    <link rel=canonical href="{ page.target_uri }">
    <meta http-equiv=refresh content="0; url={ page.target_uri }">
  </head>
  <body>
    <h1>Redirecting...</h1>
    <a href="{ page.target_uri }">Click here if you are not redirected.</a>
    <script>location='{ page.target_uri }'</script>
  </body>
</html>
{% endhighlight %}

#### Create Redirect Pages

Anything that is not prefixed by an underscore is copied as is to the Jekyll __site_ folder. Create a file for each URL in a new _redirect_ folder. For example, here's my _redirect/your-commute-is-killing-you-move-to-new-york.markdown_ file.

```
---
redirect_from: /your-commute-is-killing-you-move-to-new-york/
target_uri: http://code.dblock.org/2011/05/29/dear-california-engineer-your-commute-is-killing-you-move-to-new-york.html
layout: redirect
---
```

#### Try It

Try [www.dblock.org/your-commute-is-killing-you-move-to-new-york](http://www.dblock.org/your-commute-is-killing-you-move-to-new-york).

Everything is open-source. Click [here](https://github.com/dblock/www.dblock.org/commit/dbb42fe5f85f0cf69899b1714819c27c34fc4704) for the source code.
