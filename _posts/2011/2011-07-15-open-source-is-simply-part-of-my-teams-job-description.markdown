---
layout: post
title: "Open-Source Is Simply Part of my Team’s Job Description"
redirect_from: "/open-source-is-simply-part-of-my-teams-job-description/"
date: 2011-07-15 07:26:58
tags: [technology, artsy, open source]
comments: true
dblog_post_id: 233
---
In the last 24 hours my [Github Is Your New Resume](/github-is-your-new-resume) post gathered 343 comments between my blog, [HN](http://news.ycombinator.com/item?id=2763182) and [Reddit](http://www.reddit.com/r/programming/comments/ipo90/github_is_your_new_resume/). There’re also [233 RTs](http://twitter.com/search?q=http%3A%2F%2Fcode.dblock.org%2FShowPost.aspx%3Fid%3D232). First, I want to thank those with good comments. I found a few consistent themes in the debate – the one most interesting to me says that Github represents personal open-source projects done on one’s free time as opposed with paid work developed for an employer.

Let's start with a few quotes.

> _Makes sense if you have personal or open source projects . Company code not so much._
>
> _Before we hire you to write code that we won't ever in a million years let you publish to Github, we'd like to see what you've already written and published there._
>
> _I don't especially want to discuss about my personal and open-source projects with potential employers._
>
> _So, Github and open-source is the new internship. Every company expects you to consistently do work for free ... just for the chance to interview for a job._
>
> _So, I should work on open source projects instead of doing my job now?_

These certainly held true when open-source was only a matter of enthusiasm. But given the intense complexity of modern systems, the vast majority of projects use some open-source software, placing development teams just one inch away from contributing back. Finally, many corporations have made that important step and are paying their developers to (also) write open-source code while solving their business problems and making their companies money.

I believe all corporations should open-source their non-core-IP projects. Start with infrastructure and tools and continue with specialized libraries that are a matter of development time vs. intense brain activity. How many times do we really need to rewrite the same build script at five different jobs or a library to insert Google analytics code into a website?

Every software engineer can agree that smaller, well-tested and specialized modules are better than gigantic complex intertwined spaghetti systems. A generic library, in general, is easier to maintain and makes the project that consumes it cheaper to develop and upkeep. If you open-source it, you may get contributors, aka free labor. Note that those contributors saved time and money to their corporation because they didn’t have to re-develop the library and saved time and money to your company by adding a feature or fixing a bug that you will likely leverage. Those contributors were paid by their employer.

I hope this disambiguates my post – I don’t make the distinction that many commenters did. So it leads to the following question.

> _Since it would be kind of hypocritical of you to expect people to keep up active public contributions when they work for other people in order to show they are worthy of a job from you, and then expect them to stop keeping publicly active afterward, what steps will you take if I take the job to ensure that I will have plenty of free time to work on open source projects, and to ensure that my work for you won't be so challenging and interesting so that I just don't want to work on outside projects?_

This is getting right to the point. How do we, managers, enable paid open-source contributions?

1. Encourage your developers to solve real problems in the most elegant way
2. Let them know that open-source is a tool available to them.
3. Be clear that they can continue maintaining and developing personal projects on their free time.

We have started using the [analytical](https://github.com/jkrall/analytical) library to insert the infamous Google Analytics code in our site. It also enabled us to easily experiment with other analytics providers, such as Chartbeat. Unfortunately Analytical settings don’t support development vs. test vs. production environments. The easy fix would be to stick a bunch of if-then-else in code around it. Instead, I spent a couple of hours looking at its source and making [this pull request](https://github.com/jkrall/analytical/pull/17) that enabled settings-based configuration much like other similar utility libraries. The pull has not been accepted yet, so we use my fork. Implementing the feature in the library forced me to write a good test for it and incidentally reduced the number of lines of code and the complexity of our own, for profit website.

Often you don’t find a library to do something and are going to write one. You need it to solve a real business problem and you’re going to pay your developers to do it. For us it was simple full text search for MongoDB. So we created [mongoid_fulltext](https://github.com/artsy/mongoid_fulltext) as an open-source library from day one. A college student can write a simple n-gram search, so what’s the big deal? Why wouldn’t we open-source it? In fact, full-text search is the number one requested feature in MongoDB and quite a few people are probably using mongoid_fulltext now judging by the number of watchers on the project. We got two modest contributions too, which is nice and the developer can show this work to his next employer if he likes.

Personal projects? That’s everyone’s personal business. I expect developers to deliver results rather than work 9-5 (we don’t have "working hours", everyone works whenever they want) and engineers can do whatever they want on their copious free time, as long as it doesn’t compete with our company’s core business goals.

To summarize, open source is simply part of my team’s job description.
