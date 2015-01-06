---
layout: post
title: "Git: Deleting Merged Branches"
redirect_from: "/git-deleting-merged-branches/"
date: 2011-06-09 21:16:25
tags: [git]
comments: true
---

```
git branch --merged | grep -v master | xargs git branch -d
git branch -r --merged | awk -F'/' '/^ \*origin/{if(!match($0, /(>|master)/)){print $2}}' | xargs git push origin --delete
```

Here’s the same in [a Gist](https://gist.github.com/1017765) for you to comment and improve.
