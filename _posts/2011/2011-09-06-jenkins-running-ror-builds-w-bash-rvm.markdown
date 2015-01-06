---
layout: post
title: "Jenkins: Running RoR Builds w/ Bash & RVM"
redirect_from: "/jenkins-running-ror-builds-w-bash-rvm/"
date: 2011-09-06 12:23:16
tags: [jenkins]
comments: true
dblog_post_id: 261
---
I went through a few iterations of running builds via shell commands in Jenkins. Once I added a remote node things didn’t work quite the same as on master. I learned that Jenkins creates a _.sh_ file and executes it with _-xe_, so we can change the interpreter like this.

```
#!/bin/bash
source ~/.bash_profile
bundle install
bundle exec ...
```

This loads RVM from _.bash_profile_. You can add an _rvm use_ in there if you are building with multiple versions of Ruby.
