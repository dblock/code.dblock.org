---
layout: post
title: "ResourceLib 1.2 with added support for RT_JUSTABOUTEVERYTHING"
redirect_from: "/resourcelib-12-with-added-support-for-rtjustabouteverything/"
date: 2009-09-19 02:15:00
tags: [win32]
comments: true
---
I've been either working on [ResourceLib](http://resourcelib.codeplex.com) on the subway on my work to and from work for the last few weeks or reading [Raymond Chen's "The Old New Thing"](http://www.amazon.com/Old-New-Thing-Development-Throughout/dp/0321440307). Those two exercises go well together since Raymond talks quite a bit about win32 resources.

ResourceLib is written in C#, enumerates resources and implements both read and write of the file version `VS_VERSIONINFO`, string resources such as company, copyright and product information, `RT_GROUP_ICON` and `RT_ICON`, `RT_CURSOR`, `RT_BITMAP`, `RT_MENU`, `RT_DIALOG`, `RT_STRING`, `RT_ACCELERATOR`, `RT_FONT` and `RT_FONTDIR` and `RT_MANIFEST` resources. It is unit-tested and documented.

I've updated the [CodeProject article](http://www.codeproject.com/KB/library/ResourceLib.aspx) with a lot of implementation details that can't be found elsewhere on the net and [published a beta of version 1.2 on CodePlex](http://resourcelib.codeplex.com/).

#### Update (2015)

ResourceLib now lives [on Github](https://github.com/dblock/resourcelib).
