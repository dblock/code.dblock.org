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

```
|-- source
|   |-- dotfiles
|   |-- hyperclient
|   |   |-- codegram
|   |   `-- dblock
|   `-- grape
|       |-- grape
|       |   |-- ruby-grape
|       |   `-- dblock
|       `-- grape-swagger
|           |-- ruby-grape
|           `-- dblock
```

### A Source Directory

All my source code lives in `~/source`. It's lowercase and sometimes I want to make it `~/Source` like `~/Movies`, but I dislike capitalizing words that are not complete sentences.

```sh
~$ ls -la ~/source/
total 0
drwxr-xr-x   5 dblock  staff   170 Mar 25 11:26 .
drwxr-xr-x+ 42 dblock  staff  1428 Mar 24 11:12 ..
drwxr-xr-x  10 dblock  staff   340 Mar 23 11:53 dotfiles
```

### Clones

I clone my own projects directly under `source`, starting with my own [dblock/dotfiles](https://github.com/dblock/dotfiles).

```sh
~/source/dotfiles (master)$ ls -la
total 16
drwxr-xr-x  10 dblock  staff  340 Mar 23 11:53 .
drwxr-xr-x   7 dblock  staff  238 Mar 25 16:09 ..
drwxr-xr-x  16 dblock  staff  544 Mar 25 11:26 .git
-rw-r--r--   1 dblock  staff    8 Mar 23 10:09 .gitignore
-rw-r--r--   1 dblock  staff  764 Mar 23 10:09 README.md
```

```sh
~/source/dotfiles (master)$ git remote -v
origin  git@github.com:dblock/dotfiles.git (fetch)
origin  git@github.com:dblock/dotfiles.git (push)
```

### Forks

For forks, I often need both the upstream repository and my fork, so I clone into subfolders named after the repo owner. For example, I forked [codegram/hyperclient](https://github.com/codegram/hyperclient) as follows.

```sh
~/source/hyperclient$ ls -la
total 0
drwxr-xr-x   4 dblock  staff  136 Mar 25 11:43 .
drwxr-xr-x   5 dblock  staff  170 Mar 25 11:43 ..
drwxr-xr-x  22 dblock  staff  748 Mar 25 11:43 codegram
drwxr-xr-x  22 dblock  staff  748 Mar 25 11:43 dblock
```

There're two git remotes in `dblock`, `origin` and `upstream`.

```sh
~/source/hyperclient/dblock (master)$ git remote -v
origin  git@github.com:dblock/hyperclient.git (fetch)
origin  git@github.com:dblock/hyperclient.git (push)
upstream  git@github.com:codegram/hyperclient.git (fetch)
upstream  git@github.com:codegram/hyperclient.git (push)
```

### Organizations

I organize larger groups of projects together by org (eg. `artsy` or `grape`) and sometimes theme (eg. `slack`). This lets me cleanly separate projects that are for my job at [Artsy](https://www.artsy.net) from open-source projects in which I am heavily involved and that have a lot of Github repositories.

```sh
~/source$ ls -la
total 0
drwxr-xr-x   6 dblock  staff   204 Mar 25 11:40 .
drwxr-xr-x+ 42 dblock  staff  1428 Mar 24 11:12 ..
drwxr-xr-x  10 dblock  staff   340 Mar 23 11:53 dotfiles
drwxr-xr-x   5 dblock  staff   170 Mar 25 11:24 artsy
drwxr-xr-x   2 dblock  staff    68 Mar 25 11:40 grape
drwxr-xr-x  26 dblock  staff   884 Mar 25 11:28 slack
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

### Forks within Organizations

I clone forks into subfolders named after the repo owner the same way as forks outside of organizations described above.

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

Happy cloning and organizing. How do you do it?
