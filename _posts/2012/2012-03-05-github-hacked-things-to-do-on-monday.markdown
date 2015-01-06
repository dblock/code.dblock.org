---
layout: post
title: "Github Hacked: Things to Do on Monday"
redirect_from: "/github-hacked-things-to-do-on-monday/"
date: 2012-03-05 02:17:03
tags: [github, rails, shatter, security]
comments: true
dblog_post_id: 321
---
You should take a serious look at your application and write some tests, first thing Monday.

I would write integration tests with real data that attempt to exploit the issues that were exposed by the Github hack. Even if you’re sure of your code, sit down and write a few tests, just to be double-sure. Don’t do a code review, write some code that will tell you, 100%, whether you have problems or you don’t.

I see two major attack vectors.

#### Mass Assignment

Read [Homakov’s post](http://homakov.blogspot.com/2012/03/how-to.html). If it’s not clear, read it again until it’s clear.

Given models Parent and Child where children belong to parents - can I post a parent’s ID to a form that updates a child and therefore change which parent a child belongs to? If so, you have a problem. Go fix it first thing in the morning in a systematic way, by writing a test that reproduces the issue, then by protecting the attributes with an _attr_accessible_ method. This will filter out everything that’s not in the list when you call _update_attributes_. Make sure you just use this on all models, all the time.

A variation of this problem is _garbage in, garbage out_. This affects systems backed by NoSQL document databases. Make sure you aren’t writing random attributes that come from a form into your model. In a relational database you get an exception because the field doesn’t match the schema. In a document store you have just stored junk. It may be harmless or harmful, but you’d rather not find out the hard way.

We use a home grown hash map to whitelist attributes for historical reasons, but _attr_accessible_ does the job just fine.

#### Identity Confusion

Whitelisting attributes only works when you actually don’t need to assign relationships. Do you pass an identity for a Widget as a parameter, maybe in a URL? Do widgets belong to different users? If so, write a test that ensures that a user that doesn’t have access to this Widget cannot modify it.

My recommendation is to use something like [CanCan](https://github.com/ryanb/cancan) and to check authorization in a single layer. You spell out who can create/retrieve/update/delete models and enforce this with a single _has_authorization_to?._ We do this in our API layer systematically. We also learned to key off _current_user_ as much as possible. So if you’re modifying widgets that belong to _current_user_, you won’t find a widget with a rogue ID by doing _current_user.widgets.find(someone_elses_widget_id)_.

#### Dear Github

I still love you. This happens to the best people out there. Shameless plug for my former [Team SHATTER](http://www.teamshatter.com/), if you want a list. Move on and learn from it.

![]({{ site.url }}/images/posts/2012/2012-03-05-github-hacked-things-to-do-on-monday/image_3.jpg)
