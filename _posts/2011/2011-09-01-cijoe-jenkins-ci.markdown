---
layout: post
title: "CIJoe => Jenkins CI"
redirect_from: "/cijoe-jenkins-ci/"
date: 2011-09-01 15:13:02
tags: [jenkins, cijoe]
comments: true
dblog_post_id: 253
---
![image_thumb5]({{ site.url }}/images/posts/2011/2011-09-01-cijoe-jenkins-ci/headshot7.jpg)

We’ve switched from [CIJoe](https://github.com/defunkt/cijoe) to [Jenkins](http://jenkins-ci.org/). I guess we’ve "graduated" to Jenkins, but in retrospect we should have just used that in the first place. I think CIJoe is fine, we did thousands of builds with it, thank you CIJoe. But it’s actually easier to setup Jenkins and it’s much lighter than what I anticipated. As someone said, there’s no need to have CI written in Ruby to build Ruby projects.

This is what I see after spending a day with Jenkins.

1. A lot less manual configuration, running as a service out-of-the-box.
2. Multiple projects without multiple services on different ports.
3. Console output during build with live progress update.
4. Built-in support for multiple build nodes.

Jenkins is a lot closer to my BuildTracker project at Microsoft – we were doing all the things Jenkins is doing, ten years ago, with build labs that had hundreds of servers. Buildtracker is a "build lab out of the box" and I hear that it’s live and well and widely used in Redmond. Maybe I’ll contribute to Jenkins some plugins around features we built then.

Long story ...

I couldn’t get CIJoe to use RVM and went down the rabbit hole of a global Ruby installation and running CIJoe as root. I managed to get CIJoe to auto-start on boot using a script from [this post](http://www.acalling.co.uk/articles/ci-joe-cause-knowing-how-to-set-it-up-is-half-the-battle), but I was still having trouble getting repeatable builds. I am sure all these issues are resolvable, but it smelled wrong to me, especially since RVM is built to fix most of those problems. After fighting it for half a day I decided to give [JenkinsCI](http://jenkins-ci.org/) a try. An _apt-get_ later I had it running. From the start Jenkins runs as a user, _jenkins_, which can have a regular RVM setup without any headaches – nice!

We used to commit CIJoe runner configuration into Git (like [this](/committing-cijoe-runner-configuration-into-git)). It doesn’t look quite possible with Jenkins unless you commit the entire build script. I think we’ll move the remaining steps into a Rake task and execute that with a Jenkins Rake plugin.

Typing too fast is bad for you. When adding a command-line task to Jenkins on *nix, make sure you choose _Execute shell_ and not _Execute Windows batch command_. The latter is the first choice. I had at least three face-to-palm moments.

Jenkins eats shell commands. You can’t do loops, if-s or other bash-like constructs that you might be used to. For example, I was trying to ignore failures on adding a remote in a build step, unsuccessfully. I tried `command; exit 0` and all kinds of other tricks at no avail. You have to keep things simple – in my case I ended up changing a _git push_ command from `git push heroku master` (that’s why I needed to add a _heroku_ remote) to `git push git@heroku.com:app-name.git`.

Jenkins with Git and Github tags and builds on detached states (if you do `git status` on the workspace you’ll find yourself on _no branch_). Hence you can’t push anything remotely from here. Our builds deploy to staging, so I had to change the build to push the currently built git commit.

```
git push git@heroku.com:app-name.git $GIT_COMMIT:master
```

My wish list for Jenkins today includes the following. I am sure it will grow. If you want to code some open-source stuff, I'll be [happy to help you in any way I can](/contribute-to-any-of-these-open-source-projects-and-i-will-help-you-in-any-way-i-can) in exchange.

- Colorize ANSI console output
- Let me setup a project where I can choose which revision to build. This could make functionality similar to [heroku-bartender](http://github.com/sarcilav/heroku-bartender).

I am Jenkins noob, so looking forward to your comments.
