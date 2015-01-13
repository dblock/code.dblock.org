---
layout: post
title: "How to Move Jekyll Posts Across Sites: Handling Redirects"
date: 2015-01-15
tags: [jekyll]
comments: true
---
I've recently [moved this blog to Jekyll](/2015/01/07/the-new-code-dblock-dot-org.html), moved all my art-related posts to a new [art.dblock.org](http://art.dblock.org) Jekyll blog and replaced [www.dblock.org](http://www.dblock.org) with a landing page. The last bit is to redirect any old popular content from the old www.dblock.org, such as [Your Commute is Killing You: Move to New York](/2011/05/29/dear-california-engineer-your-commute-is-killing-you-move-to-new-york.html) or [How To Frame and Hang Very Big Drawings](http://art.dblock.org/2007/12/18/big-frame-hanging.html) to one or the other site.

The landing [www.dblock.org](http://www.dblock.org) site is also a Jekyll site.

#### Include the Redirect Gem

Include the _jekyll-redirect-from_ gem in __config.yml_.

{% highlight yaml %}
gems:
  - jekyll-redirect-from

{% endhighlight %}

#### Create Redirect Pages

The _jekyll-redirect-from_ library supports _redirect_from_ and _redirect_to_. It creates a file for the source path and a page with a redirect to the destination. Since anything that is not prefixed by an underscore is copied as is to the Jekyll __site_ folder, we can just create a file for each URL in a new _redirect_ directory. For example, here's my _redirect/your-commute-is-killing-you-move-to-new-york.markdown_ file.

```
---
redirect_from: /your-commute-is-killing-you-move-to-new-york/
redirect_to: http://code.dblock.org/2011/05/29/dear-california-engineer-your-commute-is-killing-you-move-to-new-york.html
---
```

#### Moving Pages with Parameters

My old blog had a more complicated scenario with URLs that included a query string ID in the form of _ShowPost.aspx?id=X_. How does Jekyll handle _.aspx_ extensions and how do we translate such an URL into an existing post?

The export tool I wrote added a field to every post called _dblog_post_id_.

```
---
layout: post
title: "Pure Java Waffle"
...
dblog_post_id: 95
---
```

We can create a plain HTML page that will extract the ID from the query string and use a map to perform a redirect. Jekyll will not serve _.aspx_ pages, but if you try to retrieve a folder without a trailing slash, you will be redirected to its _index.html_ page. This is part of the HTTP standard. I created _posts/ShowPost.aspx.html_ that iterates over all posts and performs the redirect.

{% highlight html %}
{% raw %}
---
permalink: '/ShowPost.aspx/'
---

<script language='javascript'>
var posts_map = {};
{% for page in site.posts %}
  {% if page.dblog_post_id %}
    posts_map[{{ page.dblog_post_id }}] = '{{ page.url }}'
  {% endif %}
{% endfor %}

function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}

var id = getParameterByName('id');
var url = posts_map[id];

if (url) {
  window.location.replace(url);
} else {
  window.location = '/'
}
</script>
{% endraw %}
{% endhighlight %}

#### Try It

Try [www.dblock.org/your-commute-is-killing-you-move-to-new-york](http://www.dblock.org/your-commute-is-killing-you-move-to-new-york) and [code.dblock.org/ShowPost.aspx?id=103](http://code.dblock.org/ShowPost.aspx?id=103).

Everything is open-source. Click [here](https://github.com/dblock/www.dblock.org/commit/85ac18118feac15f25b1f6eb2b1a441ef69d0c53) for the source code for the plain redirect and [here](https://github.com/dblock/code.dblock.org/commit/66e15c163704569a9eec6eef45ecf1c667d5ab44) for the more complicated ASPX one.
