---
layout: post
title: "Svn2Svn 1.2 Released"
redirect_from: "/svn2svn-12-released/"
date: 2011-06-09 12:17:09
tags: [open source, subversion]
comments: true
dblog_post_id: 215
---
I just released a new version of [svn2svn 1.2](https://github.com/dblock/svn2svn), a tool for replaying changes in SVN repositories.

- Added /incremental (/i) mode to svn2svn; detects all previously synced revisions and starts at the latest revision that has not been synced (thx @dei79).
- Added fs2svn, a tool that synchronizes a file system folder to SVN.
- Added svn2, a tool that can recycle unversioned files (sync).
- Added /stopOnCopy[+/-] to svn2svn, default isto follow branch/copy history.
- Added /root option to svn2svn, specifies ancestor svn path.
- Added support for specifying HEAD in svn2svn --revision:start:end.
- Svn2svn will assume HEAD revision when end revision omitted in --revision.
- Modified files are displayed in svn2svn console output before each action with an M marker.

As much as I love SVN I suggest you check out Git and especially [Github](https://github.com/) for your next project.
