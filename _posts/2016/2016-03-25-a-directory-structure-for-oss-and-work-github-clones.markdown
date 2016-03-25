---
layout: post
title: "A Directory Structure for OSS and Work Github Clones"
date: 2016-03-25
tags: [git, github, open-source, shell]
comments: true
---
I have thousands of Github clones on my computer. You might also know that I have a massive OCD for organizing things. I organize my personal documents by year, going back to 1994 and photos by date. I freak out if there're too many top level folders.

Most people `git clone` a repo (eg. `grape`), then `git clone` their forks into another folder (eg. `grape2`), which makes a huge mess and makes me nervous.

This is how I organize my source code.

### A Source Directory

All my source code lives in `~/source`. It's lowercase and sometimes I want to make it `~/Source` like `~/Movies`, but I hate capitalizing words that are not complete sentences.

```sh
~$ ls -la ~/source/
total 0
drwxr-xr-x   5 dblock  staff   170 Mar 25 11:26 .
drwxr-xr-x+ 42 dblock  staff  1428 Mar 24 11:12 ..
drwxr-xr-x  10 dblock  staff   340 Mar 23 11:53 dotfiles
```

### Organizations

I organize projects together by org or theme. This lets me cleanly separate projects that are for my job at [Artsy](https://www.artsy.net) from open-source projects in which I am heavily involved and that have a lot of Github repositories. The rest lives at the `~/source` level, such as my `dotfiles` example below.

```sh
~/source$ ls -la
total 0
drwxr-xr-x   6 dblock  staff   204 Mar 25 11:40 .
drwxr-xr-x+ 42 dblock  staff  1428 Mar 24 11:12 ..
drwxr-xr-x   5 dblock  staff   170 Mar 25 11:24 artsy
drwxr-xr-x   2 dblock  staff    68 Mar 25 11:40 grape
drwxr-xr-x  26 dblock  staff   884 Mar 25 11:28 slack
drwxr-xr-x  10 dblock  staff   340 Mar 23 11:53 dotfiles
```

I often lose sleep over whether I should rename `grape` to `ruby-grape`, which is the actual name of the [Ruby Grape organization](https://github.com/ruby-grape).

### Projects

I create a subfolder for each forked project within an org.

```sh
~/source/grape$ ls -la
total 0
drwxr-xr-x  5 dblock  staff  170 Mar 25 11:43 .
drwxr-xr-x  6 dblock  staff  204 Mar 25 11:40 ..
drwxr-xr-x  4 dblock  staff  136 Mar 25 11:43 grape
drwxr-xr-x  4 dblock  staff  136 Mar 25 11:43 grape-swagger
drwxr-xr-x  4 dblock  staff  136 Mar 25 11:43 grape-with-roar
```

### Forks

I often need both the upstream repository and my fork, so I clone into subfolders named after the repo owner.

```sh
~/source/grape/grape-swagger$ ls -la
total 0
drwxr-xr-x   4 dblock  staff  136 Mar 25 11:43 .
drwxr-xr-x   5 dblock  staff  170 Mar 25 11:43 ..
drwxr-xr-x  22 dblock  staff  748 Mar 25 11:43 dblock
drwxr-xr-x  22 dblock  staff  748 Mar 25 11:43 ruby-grape
```

There're two git remotes in `dblock`, `origin` and `upstream`.

```sh
~/source/grape/grape-swagger/dblock (master)$ git remote -v
origin  git@github.com:dblock/grape-swagger.git (fetch)
origin  git@github.com:dblock/grape-swagger.git (push)
upstream  git@github.com:ruby-grape/grape-swagger.git (fetch)
upstream  git@github.com:ruby-grape/grape-swagger.git (push)
```

### Scripts

I cooked a little script, [github-clone](https://github.com/dblock/dotfiles/blob/master/bash/bin/github-clone) that creates this folder structure and adds an upstream remote. It supports both HTTP and GIT remotes.

```sh
~/source/grape$ github-clone git@github.com:ruby-grape/grape-entity.git

github-clone: cloning ruby-grape/grape-entity into grape-entity/ruby-grape and grape-entity/dblock

Cloning into 'ruby-grape'...
remote: Counting objects: 1152, done.
remote: Total 1152 (delta 0), reused 0 (delta 0), pack-reused 1152
Receiving objects: 100% (1152/1152), 374.82 KiB | 0 bytes/s, done.
Resolving deltas: 100% (570/570), done.
Checking connectivity... done.

Cloning into 'dblock'...
remote: Counting objects: 1055, done.
remote: Total 1055 (delta 0), reused 0 (delta 0), pack-reused 1055
Receiving objects: 100% (1055/1055), 345.14 KiB | 0 bytes/s, done.
Resolving deltas: 100% (525/525), done.
Checking connectivity... done.

/Users/dblock/source/grape/grape-entity
dblock     ruby-grape

~/source/grape$
```

The above cloned `ruby-grape/grape-entity` and `dblock/grape-entity` and set an `upstream` remote in `grape-entity/dblock`.

```sh
~/source/grape$ ls -la grape-entity/
total 0
drwxr-xr-x   4 dblock  staff  136 Mar 25 11:46 .
drwxr-xr-x   6 dblock  staff  204 Mar 25 11:46 ..
drwxr-xr-x  17 dblock  staff  578 Mar 25 11:46 dblock
drwxr-xr-x  22 dblock  staff  748 Mar 25 11:46 ruby-grape
```

Happy cloning and organizing.
