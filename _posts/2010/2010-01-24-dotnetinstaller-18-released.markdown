---
layout: post
title: "dotNetInstaller 1.8 Released"
redirect_from: "/dotnetinstaller-18-released"
date: 2010-01-24 13:53:08
tags: [dotnetinstaller, msi]
comments: true
---
[![](https://github.com/dblock/dotnetinstaller/raw/master/Documentation/Images/Logo.gif)](https://github.com/dblock/dotnetinstaller)

dotNetInstaller 1.8 was released today, January 24th, 2010. Build 1.8.7120.0 has been beta, then a release candidate for over a month now with no major issues reported. Here’re some highlights.

- Added support for uninstall sequences with new command-line /i and /x switches, supports_install, supports_uninstall global options in configurations, components and controls. Added extended uninstall parameters in cmd and msi components.
- Added user-defined form controls and input for labels, checkboxes, edit boxes, hyperlinks and file/directory browse controls.
- Added user-defined splash screen embedded with the InstallerLinker /Splash option and an optional /nosplash switch to dotNetInstaller.
- Added returncodes that specify which return code(s) should be treated as success, failure or a required reboot.
- Added support for a license agreement checkbox user-defined control.
- Added clear_cache to download components. When true, attempts to clear the local internet cache entry for the url to download.
- Cabbing now embeds files that belong in components in separate resource streams, extracting only those files that are necessary for installation of a particular component. Embedded files outside of components continue to always be extracted.
- CAB extraction uses the memory-mapped resource streams and no longer writes temporary files to extract embedded components. This significantly reduces disk space requirements and improves extraction speed.

dotNetInstaller continues being the most widely used setup bootstrapper. Please reply to [this thread](http://dotnetinstaller.codeplex.com/discussions/48275) if you’re using it too.


