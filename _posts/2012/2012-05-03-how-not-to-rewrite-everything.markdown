---
layout: post
title: "How Not to Rewrite Everything"
redirect_from: "/how-not-to-rewrite-everything"
date: 2012-05-03 13:47:24
tags: [technology, art.sy, ruby, people]
comments: true
---
I wrote a blog post yesterday about [How to Start Small With Big Data and Google Analytics](http://artsy.github.com/blog/2012/05/01/how-to-start-small-with-big-data-and-google-analytics/). Essentially, it’s a jumpstart for fetching Google Analytics pageviews and merging the daily data with some domain knowledge. But it also asks an important question:

_Why do so many companies write a homegrown pageviews tracking system? Between Google Analytics, Kissmetrics and many others, isn’t that a completely solved problem?_

![]({{ site.url }}/images/posts/2012/2012-05-03-how-not-to-rewrite-everything/image_7.jpg)

_this is a solved problem, too_

I look back at my early years in software development and find myself rewriting a lot of software that has already been written by other people. It’s a typical overconfident engineer problem, where my initial reaction to anything created by other people is that it’s insufficient in too many ways. It started with early C++ code, where achieving performance and portability between many *nix systems and Windows was a nightmare – STL wasn’t nearly as good as today. I ended up rewriting everything, including String or Vector classes (an entire C++ library open-sourced as [https://github.com/dblock/baseclasses](https://github.com/dblock/baseclasses)). I then went on to work for Microsoft where we were trying to build a 24/7 service that would not die from memory allocation failures. .NET didn’t exist then, MFC was out of the question because of it’s legendary reliability and so was the Microsoft version of the STL that was just merging with MFC. Open-source was not even part of Microsoft lingo. We built CoreSDK, a C++ library where I ended up rewriting everything, including String or Vector classes, again. I think I implemented at least a dozen versions of String in my life that went into some production code. Those were the days!

This decade’s software is way too complicated to rewrite everything. When I choose a platform or framework for a project, I like open-source ecosystems that encourage reuse. Adding third-party components in the .NET world is not commonplace. Adding dependencies in Java with Maven is better, until you need to make changes to the code in your dependencies. The Ruby world with Rubygems and Bundler gets it right: there’s virtually no overhead for using a third-party library. Node.js is a bit younger, but also gets it right.

Now that I can easily reuse third-party systems, I must try to remember that I should write less lines of code, introduce less operational overhead and create more positive product impact in a reasonable amount of time. It doesn’t mean I just want to slap together someone else’s components - things worth focusing on should be elements that serve my company’s core competencies or be educational for me, useful to the open-source community at large or just plain fun. While this sounds obvious, sticking to the guidelines and keeping myself accountable is a daily effort.

How do _you_ avoid rewriting everything?

