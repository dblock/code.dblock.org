---
layout: post
title: "JNA: Building JNA on Windows 64-bit"
redirect_from: "/jna-building-jna-on-windows-64-bit"
date: 2010-12-07 02:20:46
tags: [jna, java]
comments: true
---
Let’s build [JNA](https://github.com/twall/jna/) on a Windows AMD 64. I am always confused about which Cygwin packages I actually need to do that. Every time I get it wrong. So this is what you need beyond the basic Cygwin installation: make, gcc-mingw, mingw64-i686. The latter is important, you need the i686 packages, not the cross-platform x86-64 ones.

![]({{ site.url }}/images/posts/2010/2010-12-07-jna-building-jna-on-windows-64-bit/image%5b9%5d.jpg)

![]({{ site.url }}/images/posts/2010/2010-12-07-jna-building-jna-on-windows-64-bit/image%5b4%5d.jpg)

With these you would still get a failure building libffi, stating that the C compiler can’t produce binaries. Pursuing that I found that libffi will use Visual Studio to build itself on AMD64. You need Visual Studio 2008, including the X64 Compiler and Tools that aren’t installed by default.

![clip_image002]({{ site.url }}/images/posts/2010/2010-12-07-jna-building-jna-on-windows-64-bit/clip_image002%5b6%5d.jpg)

The problem persists! Libffi uses cl.sh that does magical things with cl.exe. I managed to hack around it to finally get a Visual Studio cl.exe to work in this environment, but still couldn’t get libffi to build. At this point I gave up trying to get an AMD64 build. But I do have another 64-bit machine where build works!

The difference is in `JAVA_HOME`. With 32-bit Java libffi will build a 32-bit version. With 64-bit Java it will want to be a native 64-bit thing. Installing 32-bit Java and setting `JAVA_HOME` to `c:\Program Files (x86)\Java\jdk1.6.0_22` solves the problem. While this is not a 64-bit build it runs fine on Win-64, enough for development and debugging.
