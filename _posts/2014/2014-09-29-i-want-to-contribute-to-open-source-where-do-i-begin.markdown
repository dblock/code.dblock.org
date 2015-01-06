---
layout: post
title: "I Want to Contribute to Open-Source: Where do I Begin?"
redirect_from: "/i-want-to-contribute-to-open-source-where-do-i-begin/"
date: 2014-09-29 10:45:36
tags: [teams, teaching, open source]
comments: true
---
I get this question a lot. I turned to my friends, [HN](https://news.ycombinator.com/item?id=8361790) and [Twitter](https://twitter.com/dblockdotorg/status/514789874155945986) for some advice.

#### Step 1: Start by using open-source.

This is great advice. Before writing anything in your application, see if there’s an open-source implementation for it out there. This will make your code simpler, cleaner and more maintainable, or at least will expose you to the incredible amount of software written by very smart people out there.

#### Step 2: Start by fixing typos in someone else’s README.

The hardest part in contributing to open-source is making the initial effort. See a typo? Fork the repo, fix it, make a [pull request](https://help.github.com/articles/using-pull-requests). This exercises the contributing workflow and creates muscle memory.

![]({{ site.url }}/images/posts/2014/2014-09-29-i-want-to-contribute-to-open-source-where-do-i-begin/screenshot.jpg)

#### Step 3: Extract non-business logic from your application into a library.

Your application could be less bloated with utility code.

For example, pick a file from the _lib_ folder in your Ruby project and extract it into a gem. I’ve done it numerous times with [ruby-enum](https://github.com/dblock/ruby-enum) (Ruby), [ARTiledImageView](https://github.com/dblock/ARTiledImageView) (Objective-C) or [VMWareTasks](https://github.com/dblock/vmwaretasks) (C#).

#### Step 4: Don’t bloat your application with non-business logic.

Your application is bloated enough. Don’t add anything that’s not application-specific to it.

That utility class you’re about to write? Don’t do it. Make it into an open-source library right away. It seems like more work, but think about it - you’re starting very small, so the test-code-rinse-and-repeat loop is really tight, you’ll be saving time. Code will be more focused and have better interfaces, helping others on your team use it. You’ll have to document what you’re doing, saving future effort and helping your coworkers and maybe even other users of your library.

#### Other Resources

There’re other resources, groups, meet-ups and websites that help you find an open-source project to contribute to. These are all great! Please link to them in the comments.
