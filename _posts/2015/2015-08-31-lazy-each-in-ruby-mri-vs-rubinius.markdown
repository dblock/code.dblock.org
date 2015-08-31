---
layout: post
title: "Lazy Each in Ruby MRI vs. Rubinius"
date: 2015-08-31
tags: [ruby, mri, rubinius]
comments: true
---
It's fairly rare to run into MRI vs. Rubinius or JRuby differences. Here's one from [spidey#5](https://github.com/joeyAghion/spidey/pull/5).

![]({{ site.url }}/images/posts/2015/2015-08-31-lazy-each-in-ruby-mri-vs-rubinius/each.gif)

The "each" iterator continues on MRI as you modify the collection, but not on Rubinius. Opened [rubinius#3494](https://github.com/rubinius/rubinius/issues/3494).

