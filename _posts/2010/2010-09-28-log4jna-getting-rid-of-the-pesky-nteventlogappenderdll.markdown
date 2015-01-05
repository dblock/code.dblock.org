---
layout: post
title: "Log4jna: getting rid of the pesky NTEventLogAppender.dll"
redirect_from: "/log4jna-getting-rid-of-the-pesky-nteventlogappenderdll"
date: 2010-09-28 17:16:04
tags: [log4j, java]
comments: true
---
Are you using log4j’s `NTEventLogAppender` to send events to the Windows event log? Then you’re familiar with NTEventLogAppender.dll that one must place in the Windows system directory or PATH. This is often a source of major confusion and bedazzlement for Java developers. There’s now a separate 32-bit version and a 64-bit version and lots of problems loading the same DLL from various web applications (aka "it doesn’t work"). So lets get rid of it!

Introducing [log4jna](http://github.com/dblock/log4jna/), a small project that uses Java Native Access (JNA) and implements the same appender without a need for a native library.

![log4jna]({{ site.url }}/images/posts/2010/2010-09-28-log4jna-getting-rid-of-the-pesky-nteventlogappenderdll/log4jna%5b4%5d.jpg)

Download a build, compatible with log4j 1.2 and swap your appender for `org.apache.log4jna.nt.Win32EventLogAppender`. There’re a few other small things to worry about described in the documentation.



