---
layout: post
title: "Getting Out of Your First Git Mess"
date: 2015-08-31
tags: [git]
comments: true
---
I'm teaching a [Startup Systems Design and Engineering class](https://github.com/Cornell-CS5356-Fall2015/cs5356) at Cornell Tech this year. As a first homework assignment we've asked students to fork our github repository and add a page with their own info and maybe a photo, linked from the [README](https://github.com/Cornell-CS5356-Fall2015/cs5356/blob/master/README.md#students). A good pull request is done off a feature branch and includes 3 files: the README change, a personal page and a picture named the same way as the personal page file. [Here's a good one](https://github.com/Cornell-CS5356-Fall2015/cs5356/pull/6) from one of our TAs, minus the feature branch.

Since most students use git for the very first time they often make some kind of mess. Everyone successfully forks the repository, clones it locally, makes changes (usually on _master_), commits and pushes, but that's where the issues begin. They try to update from the upstream repository, squash commits, rebase things and make a huge mess. This is normal, git is very powerful and can be very confusing. Eventually it becomes muscle memory and you can only really get there by doing it yourself.

After helping about 5 students I decided to write this up. Here's a quick tutorial on getting out of any mess.

### Clean-ish Slate

First, checkout the _master_ branch.

```
git checkout master
```

Make sure there're no changes currently on master.

```
(master)$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
nothing to commit, working directory clean
```

If there're any changes here, stash them away with _git stash_. Run _git status_ again and make sure it's clean.

### Save Your Work

Create a temporary branch with all your changes.

```
(master)$ git checkout -b tmp
Switched to a new branch 'tmp'

(tmp)$
```

And go back to _master_.

```
(tmp)$ git checkout master
Switched to branch 'master'
Your branch is up-to-date with 'origin/master'.

(master)$
```

### Configure the Upstream Remote

```
(master)$ git remote -v
origin  git@github.com:dblock/cs5356.git (fetch)
origin  git@github.com:dblock/cs5356.git (push)
```

Add the remote.

```
(master)$ git remote add upstream git@github.com:Cornell-CS5356-Fall2015/cs5356.git
```

The _git remote -v_ command would show the upstream remote now.

### Rewind Master a Dozen Commits

Go back in time, losing any changes.

```
(master)$ git reset HEAD~12 --hard
HEAD is now at ee933e2 Smaller logo.
```

Pull from upstream.

```
(master)$ git pull upstream master
remote: Counting objects: 215, done.
remote: Compressing objects: 100% (39/39), done.
remote: Total 215 (delta 92), reused 74 (delta 74), pack-reused 102
Receiving objects: 100% (215/215), 6.25 MiB | 810.00 KiB/s, done.
Resolving deltas: 100% (113/113), completed with 12 local objects.
From github.com:Cornell-CS5356-Fall2015/cs5356
 * branch            master     -> FETCH_HEAD
 * [new branch]      master     -> upstream/master
Updating ee933e2..abaecc6
Fast-forward
...
```

You may get a _Your branch and 'origin/master' have diverged, and have 2 and 8 different commits each, respectively._ error message, which is normal, because your cloned local copy is not the same as your Github fork, they have diverged.

Push master to Github, overwriting all changes.

```
(master)$ git push origin master -f
Counting objects: 289, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (152/152), done.
Writing objects: 100% (289/289), 12.90 MiB | 2.32 MiB/s, done.
Total 289 (delta 149), reused 272 (delta 136)
To git@github.com:dblock/cs5356.git
   dd3a085..abaecc6  master -> master
```

Now master is in sync between upstream's _master_, your fork's _master_ on Github and your computer's _master_, we're back to a state after we've forked the repository, but our changes are on that _tmp_ branch.

### Apply Changes to a New Branch

We saved our work to _tmp_. Create a new branch called _students-list_ and merge all changes from _tmp_ to it, minus the history.

```
(master)$ git checkout -b students-list
Switched to a new branch 'students-list'

(students-list)$ git merge tmp --squash
...
```

Use `git status` to see changes. They aren't committed, it's as if you just made them.

### Examine Changes, Commit and Push

Add any changed files with _git add_, commit changes with _git commit_ and push the branch to Github.

```
git push origin student-list
```

Make a pull request from the _student-list_ branch to the upstream's _master_ branch on Github.

### Need More Changes?

If you need to make more small changes to the student-list branch, edit the files, `git add` them and commit using `git commit --amend`, which updates the last commit instead of adding a new one, then `git push origin student-list -f` to push the changes to Github. This way there's only one commit in the pull request, no need to _squash_.

### Rebase

There's going to be other changes on the _upstream_ repository by other students. Update your fork.

```
(tmp)$ git checkout master
Switched to branch 'master'
Your branch is up-to-date with 'origin/master'.

(master)$ git pull upstream master
...
Fast-forward
...
```

Rebase the _student-list_ branch.

```
(tmp)$ git checkout student-list
Switched to branch 'student-list'

(master)$ git rebase master
...
```

When a conflict is shown during the rebase, fix it by editing the file in conflict with a text editor, then continue the rebase with _git rebase --continue_.

Push the branch to Github.

```
git push origin student-list -f
```

No need to update an existing pull request from the student-list branch, it will be automatically updated with the new changes.

### Cleanup

After the pull request is accepted upstream (merged), cleanup local branches.

```
(master)$ git branch -D tmp

(master)$ git branch -d student-list
```

Prune any branches that were deleted remotely.

```
(master)$ git remote prune origin
```

You can see the list with `git branch -r`.

```
(master)$ git branch -r
  origin/student-list
```

Delete the remote branches.

```
(master)$ git push origin :student-list
```
