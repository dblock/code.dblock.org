---
layout: post
title: "DBlog: Implementing Skeleton CSS Boilerplate"
redirect_from: "/dblog-implementing-skeleton-css-boilerplate/"
date: 2011-08-02 16:33:14
tags: [skeleton, css, dotnet, blog]
comments: true
dblog_post_id: 240
---
You may have noticed a layout change on this blog. I finally implemented a more modern CSS using [Skeleton](http://getskeleton.com/). Here’s what Skeleton has to say about itself.

> _"Skeleton is a Beautiful Boilerplate for Responsive, Mobile-Friendly Development"_

I totally agree. You can now resize this blog – see how the highlights on the left disappear as the window gets really small.

![]({{ site.url }}/images/posts/2011/2011-08-02-dblog-implementing-skeleton-css-boilerplate/image_8.jpg)

This makes it actually readable on a mobile device – I tried it on my Android and it was a massive improvement from the old view! The implementation was very straightforward, most of the time was spent battling the ASP.NET grids and lists that are primarily table-based. This blog’s code is [here](http://github.com/dblock/dblog/) if you care. Please also do let me know if something doesn’t work or can be improved.
