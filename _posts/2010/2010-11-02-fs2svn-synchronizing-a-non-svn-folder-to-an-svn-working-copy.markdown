---
layout: post
title: "Fs2svn: synchronizing a non-SVN folder to an SVN working copy"
redirect_from: "/fs2svn-synchronizing-a-non-svn-folder-to-an-svn-working-copy"
date: 2010-11-02 11:43:14
tags: [subversion]
comments: true
---

![subversion_logo-384x332_thumb[9]]({{ site.url }}/images/posts/2010/2010-11-02-fs2svn-synchronizing-a-non-svn-folder-to-an-svn-working-copy/subversion_logo-384x332_thumb92.jpg)

I’ve recently needed to update [Waffle](https://github.com/dblock/waffle/)’s Tomcat from version 6.0.14 to 6.0.28. The Tomcat distribution lives in a _ThirdParty/tomcat _folder and is committed to SVN. I needed to compare the two versions and figure out which files were deleted or added, then _svn add/delete_ them. That’s a rather time-consuming, error-prone and most annoying process.

We can do better. I added a new tool to the [Svn2svn project](https://github.com/dblock/svn2svn), _fs2svn_ that does just that. It uses [FolderSync](http://www.codeproject.com/KB/files/kratfoldersync.aspx) with [SharpSVN](http://sharpsvn.open.collab.net/) and will perform the appropriate svn action for each file or directory. You can run it in simulation mode too. It won’t commit anything, you can examine the results and commit them on your time.

```
Fs2Svn:
/simulationOnly[+|-]   Simulation mode, don't commit anything. Default value:'-' (short form /x)
/source:<string>       Source non-SVN path. (short form /s)
/destination:<string>  Target SVN path, default to current. (short form /d)
@<file>                Read response file for more options
```
