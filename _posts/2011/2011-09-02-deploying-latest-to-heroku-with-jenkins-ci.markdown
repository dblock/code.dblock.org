---
layout: post
title: "Deploying Latest to Heroku with Jenkins CI"
redirect_from: "/deploying-latest-to-heroku-with-jenkins-ci/"
date: 2011-09-02 03:16:25
tags: [jenkins, heroku]
comments: true
---
You can use [Jenkins Batch Task Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Batch+Task+Plugin) if you want to deploy the latest revision to Heroku. Our deployment has two steps: a rake task that pushes assets to S3/Cloudfront and a git push. So the batch task attached to our repo looks like this.

```
git rev-parse HEAD
echo $GIT_COMMIT
bundle exec rake heroku:predeploy
git push git@heroku.com:heroku-app.git $GIT_COMMIT:master
```

The first two lines are there for logging, so that we know which revision was pushed to Heroku.

We’re now missing two important pieces from [Heroku-bartender](https://github.com/sarcilav/heroku-bartender)’s functionality: a visual of which revision has been deployed and the ability to run a task on any previous build.
