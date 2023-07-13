---
layout: post
title: "Svn2svn: migrating from SourceForge to CodePlex"
redirect_from: "/svn2svn-migrating-from-sourceforge-to-codeplex/"
date: 2009-02-22 19:00:00
tags: [subversion]
comments: true
dblog_post_id: 36
---
I am in the process of migrating a 3rd project from some SVN repository to CodePlex. I do love it, despite some performance concerns, which I am sure will be addressed eventually. I used Toolbox, an internal Microsoft project, a lot. CodePlex must have learned something from Toolbox since I like it so much. But back to the real world, I am moving DNI (dotNetInstaller) from the clunky SourceForge.

I tried to do it the ["rigth way" with svnsync](https://blogs.collab.net/subversion/mirroring-repos), but CodePlex doesn't support editing revision properties and setting the zero revision. This is also a rather heavy requirement in general unless you're truly synchronizing a repository. In my case I don't care enough to preserve the revision numbers, I just want to replay the changelog in another repository, and I'd like to skip a few revisions. This is sometimes called _reflection _(find sdreflect on Toolbox :)).

For the first two projects I had migrated, I only had a handful of revisions, so I did an _svn export_ for each on top of the previous one and commited the changes with the same log message. I had to manually svn add/delete the files. DNI has 136 revisions in the past couple of months only, so it was time to find a tool to do that. There's a [Python svn2svn tool](https://code.google.com/p/svn2svn/) that claims to do the work, but it gave me a rash after Python refused to run it on my Windows Vista. I guess my problem is that I'm trying to do things easily.

Someone has to do the work, so please welcome my new svn2svn project, [https://web.archive.org/web/20091227022713/https://www.codeplex.com/svn2svn](https://web.archive.org/web/20091227022713/https://www.codeplex.com/svn2svn). It implements what I need, but I am sure many people will want more options.

- supports copying across repositories
- no zero-revision requirements, this is a change replay tool
- supports non-rooted paths (copy a subtree towards another subtree)
- supports add/delete/modify
- optional revision range
- simulation mode
- prompts on commit

Alpha build on it's way.

#### Update (2015)

Svn2svn now lives [on Github](https://github.com/dblock/svn2svn).
