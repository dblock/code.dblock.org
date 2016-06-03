---
layout: post
title: "Very Slow MongoDB in Development and Test"
date: 2016-06-03
tags: [mongodb]
comments: true
---
MongoDB [SERVER-24384](https://jira.mongodb.org/browse/SERVER-24384) bit me.

RSpec tests in Mongoid/MongoDB projects would take forever to run, spending multiple seconds creating collections or indexes. Typically, projects using MongoDB (I have a list of at least two dozen [here](/2015/07/24/getting-things-done-with-mongoid-5.html)) use [database_cleaner](https://rubygems.org/gems/database_cleaner) to drop the entire database before each test and re-create all indexes to mimic a clean production-like environment. This would now take 5-10 seconds per test.

I opened [SERVER-24384](https://jira.mongodb.org/browse/SERVER-24384), which was closed as a duplicate of [SERVER-17675](https://jira.mongodb.org/browse/SERVER-17675). Turns out, WiredTiger uses one file per collection and one file per index, so in this workload the system is very busy creating and removing files, which explains why it's so slow.

The workaround is to use the `mmapv1` storage engine in development. Here's my `/usr/local/etc/mongod.conf`.

{% highlight conf %}
systemLog:
  destination: file
  path: /usr/local/var/log/mongodb/mongo.log
  logAppend: true
storage:
  dbPath: /usr/local/var/mongodb
  engine: mmapv1
  journal:
     enabled: false
net:
  bindIp: 127.0.0.1
{% endhighlight %}

You'll have to stop MongoDB, then clear all your data in `/usr/local/var/mongodb/` before restarting it.

{% highlight bash %}
$ brew services stop mongodb
Stopping `mongodb`... (might take a while)
==> Successfully stopped `mongodb` (label: homebrew.mxcl.mongodb)

$ rm -rf /usr/local/var/mongodb/*

$ brew services start mongodb
==> Successfully started `mongodb` (label: homebrew.mxcl.mongodb)
{% endhighlight %}
