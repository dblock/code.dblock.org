---
layout: post
title: "Using GCC to install Ruby w/ RVM on Mac OSX Lion"
redirect_from: "/using-gcc-to-install-ruby-w-rvm-on-mac-osx-lion/"
date: 2011-11-03 00:24:40
tags: [mac osx, ruby]
comments: true
dblog_post_id: 284
---
I have an iMac with a gigantic screen and Mac OSX Lion standing on my desk.

The first problem was to get Ruby 1.9.2 running w/RVM. It almost worked minus the segmentation faults left and right, XCode 3.2, 4.1 or 4.2. RVM is not smart enough to tell you that a compilation segfaulted – it just hangs - you have to watch _.rvm/log/ruby.../make.log_. The fix was described in [https://stackoverflow.com/questions/6985690/problem-installing-ruby-1-9-2-on-mac-os-lion](https://stackoverflow.com/questions/6985690/problem-installing-ruby-1-9-2-on-mac-os-lion), use GCC.

```
CC="/usr/bin/gcc-4.2" ARCHFLAGS="-arch x86_64" ARCHS="x86_64" rvm install 1.9.2
```

I ended up adding _CC_, _ARCHFLAGS_ and _ARCHS_ as exports to my _~/.bash_profile_, permanently.
