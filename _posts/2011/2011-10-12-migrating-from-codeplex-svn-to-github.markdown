---
layout: post
title: "Migrating from CodePlex SVN to Github"
redirect_from: "/migrating-from-codeplex-svn-to-github/"
date: 2011-10-12 16:32:09
tags: [codeplex, github, microsoft]
comments: true
dblog_post_id: 277
---
If you’re like me, trying to Migrate SVN projects on CodePlex to Github, the automatic import will timeout. This is not some kind of conspiracy. This is because CodePlex SVN is a proxy to TFS and revisions don’t start at zero. In order to migrate a project, figure out what your first commit was and specify it in –r in _git svn clone_. This is discussed more in detail [here](https://stackoverflow.com/questions/2405314/git-svn-error-importing-repository-fatal-not-a-valid-object-name).

Usernames in authors files start with `SND\`, so mine is `SND\dblock_cp`. These are domain usernames or something like that. Finally run `git svn clone`. This is what I did for [Log4jna](https://github.com/dblock/log4jna).

```
git svn clone --authors-file=../authors.txt -r 57472:HEAD https://log4jna.svn.codeplex.com/svn log4jna
```

I used to be a fan of CodePlex in its early days. I have about a dozen projects on it now. So why am I moving something off CodePlex to Github? It’s mostly because of comments like the one from the CodePlex’s Principal Development Manager (jwanagel) in #20445 and #23350. The latter has been open since February 2010.
