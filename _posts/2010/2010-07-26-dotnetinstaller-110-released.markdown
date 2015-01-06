---
layout: post
title: "dotNetInstaller 1.10 Released"
redirect_from: "/dotnetinstaller-110-released/"
date: 2010-07-26 00:43:40
tags: [dotnetinstaller]
comments: true
dblog_post_id: 117
---

![dni]({{ site.url }}/images/posts/2010/2010-07-26-dotnetinstaller-110-released/dni_3.jpg)

dotNetInstaller 1.10 was released July 12th, 2010. dotNetInstaller is a very popular general purpose setup bootstrapper for Microsoft Windows created by Davide Icardi. I’ve been maintaining the project and contributing the vast majority of the features since 2008, mostly driven by our needs at [work](http://www.appsecinc.com).

> [Download](https://github.com/dblock/dotnetinstaller)

Here’re some highlights in this release.

- Added support for executable components with an optional response file and installation directory.
- Added lots of convenience features in Installer Editor, such as remembering configuration files.
- Added os_filter that behaves like lcid_filter for operating system IDs.
- Added user-defined image control.
- Holding the keyboard Control key and double-clicking on a bootstrapper component will install it, regardless of whether the component is selected or not.
- Added /ProcessorArchitecture:list to InstallerLinker to link an installer targeting a specific platform architecture.

The next release (2.0) should be very exciting as I’ve been prototyping an HTML-based installer that gives users full control of the bootstrapper UI. Stay tuned.
