---
layout: post
title: ":Slow Rails server in development? => :rails_development_boost"
redirect_from: "/slow-rails-server-in-development-railsdevelopmentboost"
date: 2011-05-19 15:06:07
tags: [rails]
comments: true
---
![]({{ site.url }}/images/posts/2011/2011-05-19-slow-rails-server-in-development-railsdevelopmentboost/image_4.jpg)

It takes me 30-45 seconds to load a Rails page in development. Finally someone did something about it.

[rails-dev-boost](https://github.com/thedarkone/rails-dev-boost)

The gem replaces the default reloading mechanism by something much more involved that tracks dependencies. Obviously it’s a lot faster. Works with Rails 3. I feel like a human again developing UI.
