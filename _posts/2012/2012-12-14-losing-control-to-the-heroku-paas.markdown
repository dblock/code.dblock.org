---
layout: post
title: "Losing Control to the Heroku PaaS"
redirect_from: "/losing-control-to-the-heroku-paas"
date: 2012-12-14 05:09:27
tags: [technology, heroku, ruby, architecture]
comments: true
---
![]({{ site.url }}/images/posts/2012/2012-12-14-losing-control-to-the-heroku-paas/image_5.jpg)

I love Heroku and [we have had great success with it](http://success.heroku.com/artsy). Yet, today, I find myself releasing [heroku-forward](http://artsy.github.com/blog/2012/12/13/beat-heroku-60-seconds-application-boot-timeout-with-a-proxy/), a gem born from frustration, that works around a seemingly simple limitation of the platform - a 60 seconds application boot timeout.

Why did I need to do all that work? How hard can it be for Heroku to raise a timeout limit? The truth is that it’s probably very hard. I don’t know anything about Heroku’s internals, but I bet that there’s some math going on on for resource allocation as well as a system that runs on a 1-minute cycle. Changing a number impacts everything, making some customers happy and others upset, adding risk.

We all make similar design choices that hard-code numbers all the time. I’ve deliberately created a 1:1 relationship between an object and the object’s owner knowing that in some future an object may have multiple owners. I’ve probably saved countless hours of minor pain doing so, but I am about to pay the full price. The entire system must be turned on its head.

Are those two issues comparable? The biggest difference is _control_. In the Heroku PaaS example, someone else has it. In my domain model, it’s me.  But after years of tinkering with every single layer of hardware and software, I find myself increasingly comfortable delegating control of those areas outside of my domain expertise. I guess it’s called focusing exclusively on your core competencies.
