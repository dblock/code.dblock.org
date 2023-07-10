---
layout: post
title: "Win32: When things get seriously obscure in Windows XP/2003 UpdateResource"
redirect_from: "/win32-when-things-get-seriously-obscure-in-windows-xp2003-updateresource/"
date: 2011-01-25 03:18:02
tags: [resourcelib, dotnetinstaller, win32]
comments: true
dblog_post_id: 160
---
I just fixed dotnetinstaller#8157. It was a humbling and head-scratching two hours.

The story goes like this. dotNetInstaler embeds files into the final bootstrapper. When built on Windows 7, everything works fine. When built on Windows XP or 2003, the executable produced runs, but its resources can no longer be loaded (which causes the htmlInstaller UI to look ugly). If you try to open the executable generated on Windows XP in Visual Studio, the latter will complain that the resources cannot be enumerated.

I spent two hours trying to compare the binary output, which obviously looked quite different. I found that the executable generated on XP is bigger than the one generated on Windows 7. So I gradually reduced the problem to a single resource and that (almost) worked. The generated binary was okay, but I noticed that my output on Windows 7 ended up with a single _INDEX_HTML_ resource, while the output on Windows XP with two resources, _"INDEX_HTML"_ and "_index_html"_. Bingo! Writing the second resource called _"style_css"_ on top of _"STYLE_CSS"_ corrupted the binary.

The fix was a simple `resourceid.ToUpper()`. The _why_ or the _how_ question is left for Raymond Chen as homework.
