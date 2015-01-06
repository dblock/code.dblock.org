---
layout: post
title: "Committing CIJoe Runner Configuration into Git"
redirect_from: "/committing-cijoe-runner-configuration-into-git/"
date: 2011-08-31 18:50:18
tags: [cijoe, git, linux, build]
comments: true
---
A nice way of telling CIJoe (or any other CI service) what to do is to commit git configuration under, for example, _git-config_.

Here’s what a typical _git-config/config_ looks like. It’s the same as your usual _.git/config_.

We’re going to have a remote [origin] and a [cijoe] section that tells CIJoe what to do.

```config
[remote "origin"]
  fetch = +refs/heads/\*:refs/remotes/origin/\*
  url = git@github.com:name/project.git
[branch "master"]
  remote = origin
  merge = refs/heads/master
[cijoe]
  runner = ((bundle check || bundle install) && bundle exec spec spec )
  buildqueue = true
```

We can also have two scripts, _git-config/build-worked_ and _git-config/build-failed_. Here’s the latter.

```shell
#!/bin/sh
echo "
Visit http://ci.example.com:9000/ for details

Author:  $AUTHOR
Message:
$MESSAGE

$OUTPUT
" | mail -s "[example] BUILD FAILED $SHA" --to dev@example.com
```

How do we hook this up? CIJoe tells us to place all this stuff into _.git/hooks_.

We can just trick it with some symbolic links on the CI server.

```
cd .git
rm config
ln -s ../git-config/config .
cd hooks
ln -s ../../git-config/build-failed .
ln -s ../../git-config/build-worked .
```

Easy.
