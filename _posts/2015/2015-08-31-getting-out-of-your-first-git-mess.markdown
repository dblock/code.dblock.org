---
layout: post
title: "Getting Out of Your First Git Mess"
date: 2015-08-31
tags: [git]
comments: true
---
I'm teaching a [Startup Systems Design and Engineering class](https://github.com/Cornell-CS5356-Fall2015/cs5356) at Cornell Tech this year. As a first homework assignment we've asked students to fork our github repository and add a page with their own info and maybe a photo, linked from the [README](https://github.com/Cornell-CS5356-Fall2015/cs5356/blob/master/README.md#students). A good pull request is done off a feature branch and includes 3 files: the README change, a personal page and a picture named the same way as the personal page file. [Here's a good one](https://github.com/Cornell-CS5356-Fall2015/cs5356/pull/6) from one of our TAs, minus the feature branch.

Since most students use git for the very first time they often make some kind of mess. Everyone successfully forks the repository, clones it locally, makes changes (usually on _master_), commits and pushes, but that's where the issues begin. They try to update from the upstream repository, squash commits, rebase things and make a huge mess. This is normal, git is very powerful and can be very confusing. Eventually it becomes muscle memory and you can only really get there by doing it yourself.

After helping a handful of students I decided to write this up. Here's a quick tutorial on getting out of a git mess.

### Make a Clean-ish Slate

The first goal is to make both the local computer's and our Github fork's _master_ branches look like the _upstream_, the repository that was forked, _master_ branch, without losing changes already made.

Checkout the _master_ branch.

```
(big-mess)$ git checkout master
Switched to branch 'master'
Your branch is up-to-date with 'origin/master'.
```

Make sure there're no changes currently on master.

```
(master)$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
nothing to commit, working directory clean
```

If there're any changes here, `git stash` them away. If you were in the middle of a merge, run `git merge --abort`. If you were in the middle of a rebase, run `git rebase --abort`. Run `git status` again and make sure everything is clean.

### Save Your Work

Create a temporary branch with all your changes.

```
(master)$ git checkout -b tmp
Switched to a new branch 'tmp'

(tmp)$
```

And go back to the _master_ branch.

```
(tmp)$ git checkout master
Switched to branch 'master'
Your branch is up-to-date with 'origin/master'.

(master)$
```

### Configure the Upstream Remote

This is our link to the parent or forked repository called the _upstream_.

```
(master)$ git remote -v
origin  git@github.com:dblock/cs5356.git (fetch)
origin  git@github.com:dblock/cs5356.git (push)
```

Add the _upstream_ remote.

```
(master)$ git remote add upstream git@github.com:Cornell-CS5356-Fall2015/cs5356.git
```

The `git remote -v` command would show the upstream remote now.

```
(master)$ git remote -v
origin  git@github.com:dblock/cs5356.git (fetch)
origin  git@github.com:dblock/cs5356.git (push)
upstream  git@github.com:Cornell-CS5356-Fall2015/cs5356.git (fetch)
upstream  git@github.com:Cornell-CS5356-Fall2015/cs5356.git (push)
```

### Rewind Master a Dozen Commits

Go back in time, losing any changes with `git reset --hard`.

```
(master)$ git reset HEAD~12 --hard
HEAD is now at ee933e2 Smaller logo.
```

This just undid a dozen changes, including ours, on _master_. Fortunately we saved everything in that _tmp_ branch.

Pull from _upstream_ with `git pull upstream master`.

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

You may get a _"Your branch and 'origin/master' have diverged, and have 2 and 8 different commits each, respectively."_ error message, which is normal, because your cloned local copy is not the same as your Github fork, they have diverged.

Push the _master_ branch to Github, overwriting all changes wutg `git push origin master -f`. The force flag, `-f` is required because we're overwriting changes on Github.

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

Now master is in sync between upstream's _master_, your fork's _master_ on Github and your computer's _master_, we're back to a state after we've forked the repository, and our changes are on that _tmp_ branch.

### Apply Changes to a New Branch

We saved our work to _tmp_. Create a new branch called _students-list_ and merge all changes from _tmp_ to it, minus the history with `git merge --squash`. That flag applies the changes but doesn't replay the commits.

```
(master)$ git checkout -b students-list
Switched to a new branch 'students-list'

(students-list)$ git merge tmp --squash
Updating dd3a085..abaecc6
Fast-forward
Squash commit -- not updating HEAD
...
```

Use `git status` to see changes. They aren't committed, it's as if you just made them with a text editor.

```
(students-list)$ git status
On branch students-list
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

  new file:   ...
```

### Examine Changes, Commit and Push

Add any changed files with `git add`, commit changes with `git commit` and push the branch to Github.

```
(students-list)$ git push origin student-list
```

Make a pull request from the _student-list_ branch to the upstream's _master_ branch on Github. You're all set.

### Need More Changes?

If you need to make more small changes to the _student-list_ branch, edit the files, `git add` them and commit using `git commit --amend`, which updates the last commit instead of adding a new one, then `git push origin student-list -f` to push the changes to Github. This way there's only one commit in the pull request, no need to _squash_.

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

When a conflict is shown during the rebase, fix it by editing the file in conflict with a text editor, then continue the rebase with `git rebase --continue`.

Push the branch to Github.

```
git push origin student-list -f
```

No need to update an existing pull request from the _student-list_ branch, it will be automatically updated with the new changes!

### Cleanup

After the pull request has been accepted upstream (ie. merged), checkout the _master_ branch, `git pull upstream master`, then cleanup local branches.

```
(master)$ git branch -D tmp

(master)$ git branch -d student-list
```

The `-D` force-deletes unmerged branches with changes and `-d` deletes all merged branches.

You may get a _"error: unable to delete 'branch-name': remote ref does not exist_" when trying to delete a branch. Prune any branches that were deleted remotely.

```
(master)$ git remote prune origin
```

You can see the remote branch list with `git branch -r`.

```
(master)$ git branch -r
  origin/student-list
```

Delete the merged remote branches.

```
(master)$ git push origin :student-list
```

### Conclusion

The biggest issue was that you started without a _topic_ or _feature_ branch, _student-list_ in our example. That makes it hard to have a local baseline (_master_) to rebase or update against. Always keep all the _master_ branches in sync, and use _feature_ branches for development.
