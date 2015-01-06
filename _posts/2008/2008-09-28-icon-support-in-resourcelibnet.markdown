---
layout: post
title: "Icon support in ResourceLib.NET"
redirect_from: "/icon-support-in-resourcelibnet"
date: 2008-09-28 19:15:00
tags: [win32]
comments: true
---
I've added icon support in [ResourceLib](https://github.com/dblock/resourcelib), an open source C# File Resource Management library. This lets you programmatically enumerate and change icons in an executable/dll. I needed this for [dotNetInstaller](https://github.com/dblock/dotnetinstaller).

Now ResourceLib can do version, string and icon resources, which are the hardest ones to implement. I hope some day ResourceLib will replace dozens of examples of reading/writing all types of file resources that are out there.

