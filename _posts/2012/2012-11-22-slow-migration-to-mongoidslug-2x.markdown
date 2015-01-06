---
layout: post
title: "Slow Migration to Mongoid::Slug 2.x"
redirect_from: "/slow-migration-to-mongoidslug-2x"
date: 2012-11-22 16:55:14
tags: [mongoid, ruby, open source]
comments: true
---
![]({{ site.url }}/images/posts/2012/2012-11-22-slow-migration-to-mongoidslug-2x/image_3.jpg)

... slow migrations ... slug ..., get it?

We have been using [mongoid_slug](https://github.com/digitalplaywright/mongoid-slug) at [Art.sy](https://artsy.net) for a very long time. The basic idea of the gem is to introduce a friendly URL based on document’s data. For example, artworks can be found at addresses such as [https://artsy.net/artwork/jeremy-geddes-pale-memory](https://artsy.net/artwork/jeremy-geddes-pale-memory) and posts at [https://artsy.net/museumnerd/post/intro-to-net-dot-art-1997](https://artsy.net/museumnerd/post/intro-to-net-dot-art-1997). This morning, I wrote [a blog post](http://artsy.github.com/blog/2012/11/22/friendly-urls-with-mongoid-slug) on our implementation details, including history and internationalization.

The gem’s most recent 2.x iteration is a significant improvement over the previous releases and enables slug history that can be used for lookups. That took some courageous refactoring from the authors – and it only supports Mongoid 3.x. Upgrading all gems to Mongoid 3 and having to migrate mountains of data was a lot for us to swallow a the same time, so I forked an older version of mongoid-slug and added Mongoid 3.x support that writes both the old _slug_ and the new __slugs_ values. The fork is now community-supported at [https://github.com/dblock/mongoid-slug/tree/v0.10.0-mongoid3-with-slugs](https://github.com/dblock/mongoid-slug/tree/v0.10.0-mongoid3-with-slugs) along with tested [instructions](https://github.com/digitalplaywright/mongoid-slug/wiki/How-to-upgrade-to-1.0.0-or-newer) for how to perform a slow migration from mongoid-slug 0.10.x to 2.x without any downtime.

Happy Thanksgiving!
