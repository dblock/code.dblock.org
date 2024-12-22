---
layout: post
title: Do Not Fix Bugs Reported in Your Open Source Projects
date: 2024-12-19 01:00:00
tags: [open source]
comments: true
---
Have you watched [The IT Crowd](https://en.wikipedia.org/wiki/The_IT_Crowd)? It's a hilarious British television sitcom from around 2006 that cast a bunch of IT geniuses at the Reynholm Industries tech support department in London. One of the signature laughs is that every time the phone rang, Roy would pick it up and without waiting say "Have you turned it off and on again?", then hang up. I often feel like Roy when engaging with users reporting bugs in open-source projects I maintain.

Here's my structured approach for any bug being reported in my open-source projects.

1. Do not fix the bug. Because this is open source, and we are not selling software, maintainers may have some social responsibility, but are under no obligation to do anything.
2. Do not try to reproduce the bug. Not convinced it's a bug? Cannot reproduce the issue? Politely request additional information or clarification.
3. Do not try to write a test that proves this is a bug. Ask the person reporting the issue to try and write the automated and failing test. This helps narrow down the problem and ensures that the bug stays fixed in the future.
4. Do not fix the bug. Now that the person reporting the bug has written an automated test for it, they are *this* close from fixing it. Ask them to do it. This gives the individual reporting the bug a sense of ownership and contribution to the project.
5. Do not do anything else. Can't get any engagement on the bug from the person reporting it? Leave the bug open. Someone else will pick it up.

tl;dr Do not fix the bug! A healthy open-source project will have lots of engaged contributors, especially when it comes to bugs. This is one of the [lowest hanging fruit](/2024/12/18/harvesting-the-low-hanging-fruit-in-open-source-projects.html) that you can harvest as a maintainer. That said, sometimes I just want to fix the bug myself because it's so interesting. So YMMV.
