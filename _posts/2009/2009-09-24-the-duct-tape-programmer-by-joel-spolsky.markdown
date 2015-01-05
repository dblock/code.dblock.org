---
layout: post
title: "The Duct Tape Programmer by Joel Spolsky"
redirect_from: "/the-duct-tape-programmer-by-joel-spolsky"
date: 2009-09-24 22:15:00
tags: [people]
comments: true
---
Someone forwarded me Joel Spolsky's article, [The Duct Tape Programmer](http://www.joelonsoftware.com/items/2009/09/23.html). I think Joel must have been a manager for far too long.

Sure as a manager you appreciate people who can bang features out fast. But as an engineer I’d rather go back on a duct tape programmer’s work, rewrite the thing, with unit tests this time that the duct tape programmer decided aren’t a good idea. I’ll write it in a way that I can bang features fast and still feel good about the technology and architecture. That’s the difference between a duct tape programmer and me, the result is the same, but I don’t feel bad passing my crap to the next developer that takes over my job when I am madly successful. I can basically live with myself.

[dotNetInstaller](http://github.com/dblock/dotnetinstaller) is such an example. The contributors have been doing a lot of duct tape programming and I got tired of fixing the same bugs, over and over again, release after release. So the in 1.7 I rewrote the base C++ library with tests, reduced the codebase by half and wrote tons of end-user automated tests. I write a unit test for each regression that is reported. I sleep much better now and I bang out a lot more features.
