---
layout: post
title: "Enabling SSL on Github Pages"
date: 2018-03-07
tags: [ssl, jekyll, blog]
comments: true
---
Github has been [petitioned, begged and implored](https://gist.github.com/coolaj86/e07d42f5961c68fc1fc8) to enable SSL on custom domains running on Github pages. They finally [delivered](https://blog.github.com/2018-05-01-github-pages-custom-domains-https) SSL support with [LetsEncrypt](https://letsencrypt.org).

![]({{ site.url }}/images/posts/2018/2018-03-07-enabling-ssl-on-github-pages/ssl.png)

This is what I had to do for my Github pages Jekyll site at [https://www.dblock.org](https://www.dblock.org). You can see the changes in [www.dblock.org@5f6f047d](https://github.com/dblock/www.dblock.org/commit/5f6f047df4d8a48111365bbb1e3528b4152c4d5c).

#### _config.yml

Change `url` in `_config.yml` to `https://www.dblock.org` to fix asset and other internal links.

I couldn't figure out how to make those relative to either HTTP or HTTPs.

#### _includes/_enforce_ssl.html

Add a JavaScript redirect to `_head.html` from HTTP to HTTPs.

{% highlight js %}
<script language="javascript">
  // Enforce SSL
  (function (root) {
    "use strict";
    var h = root ? root.location.hostname : "",
    p = root ? root.location.protocol : "";
    if ("http:" === p && !(/^(localhost|127.0.0.1)/).test(h)) {
      root.location.protocol = "https:";
    }
  }
  ("undefined" !== typeof window ? window : this));
</script>
{% endhighlight %}

I couldn't find a plugin that could make a 301 redirect before page load, something that Google recommends.

#### _includes/_head.html

Include the JavaScript.

{% highlight liquid %}
{% raw  %}
{% include _enforce_ssl.html %}
{% endraw  %}
{% endhighlight %}
