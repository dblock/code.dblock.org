---
layout: post
title: "No app specified: telling Heroku gem what its default --app should be"
redirect_from: "/no-app-specified-telling-heroku-gem-what-its-default-app-should-be/"
date: 2011-08-08 15:57:02
tags: [git, heroku]
comments: true
dblog_post_id: 242
---
On a clean checked out source of some app that deploys to Heroku, I want to be able to type `heroku config`. This complains with  the _'No app specified’_ error.

```
No app specified.
Run this command from an app folder or specify which app to use with --app <app name>
```

To fix this, you need to add a remote Git repository for your heroku application and tell the heroku gem to use it as default. Answer found [here](https://groups.google.com/group/heroku/browse_thread/thread/4fc0cc1caa366bfe). Like this.

```
git remote add heroku git@heroku.com:your-app-name.git
git config heroku.remote heroku
```

You can now `git push heroku master` and run `heroku config` without having to specify the app. I often deploy branches, which is `git push heroku branch-name:master`.

