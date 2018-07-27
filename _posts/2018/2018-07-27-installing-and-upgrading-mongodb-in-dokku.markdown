---
layout: post
title: "Installing and Upgrading MongoDB in Dokku"
date: "2018-07-27"
tags: [dokku, mongodb]
---
This was expanded from [Running Slack Bots on DigitalOcean with Dokku](/2016/02/08/running-slack-bots-on-digital-ocean-with-dokku.html).

Let's run MongoDB inside Dokku on DigitalOcean.

### Install the Plugin

{% highlight bash %}
$ dokku plugin:install https://github.com/dokku/dokku-mongo.git mongo
{% endhighlight %}

### Create a MongoDB Instance

This starts a MongoDB instance which is not accessible from the outside world. Replace `database-name` with your own.

{% highlight bash %}
$ dokku mongo:create database-name
-----> Starting container
       Waiting for container to be ready
=====> MongoDB container created: database-name
       DSN: mongodb://database-name:******@dokku-mongo-database-name:27017/database-name
{% endhighlight %}

### Link the Instance to an App

Logically connect the MongoDB instance with an app and publish a `MONGO_URL` configuration setting to it. Replace `database-name` and `app-name` with your own.

{% highlight bash %}
$ dokku mongo:link database-name app-name
no config vars for app-name
-----> Setting config vars
       MONGO_URL: mongodb://database-name:******@dokku-mongo-market-bot:27017/database-name
-----> Restarting app app-name
       ...
{% endhighlight %}

You're done.

In the future you might want to upgrade both the plugin and the MongoDB instance itself.

### Upgrade the Plugin

{% highlight bash %}
$ dokku plugin:update mongo

Plugin (mongo) updated
3.4.9: Pulling from library/mongo
Digest: sha256:97c51a36d08871557c02e64d20a9a6b645b16ce387b39ae4414609c39dfc439c
Status: Downloaded newer image for mongo:3.4.9
0.2: Pulling from dokkupaas/wait
Digest: sha256:a829d552e0e55c858b70a7d6f0e5bc9a5cc18b42bc8832271deaff3fed5fa212
Status: Downloaded newer image for dokkupaas/wait:0.2
0.8.0: Pulling from dokkupaas/s3backup
Digest: sha256:032ebf48626bddd422a88ae7e7675187b296a81488ec738f28c53dbf57f94788
Status: Downloaded newer image for dokkupaas/s3backup:0.8.0
latest: Pulling from library/busybox
75a0e65efd51: Pull complete
Digest: sha256:d21b79794850b4b15d8d332b451d95351d14c951542942a816eea69c9e04b240
Status: Downloaded newer image for busybox:latest
{% endhighlight %}

### Upgrade the Database

This was discussed in [dokku-mongo#74](https://github.com/dokku/dokku-mongo/issues/74).

For a minor upgrade in which the database version doesn't require any intervention (eg. 3.2.9 to 3.4.9) you can do the following.

{% highlight bash %}
$ dokku mongo:stop database-name
=====> Stopping container
       Container stopped

$ dokku mongo:info database-name --id
6a56353106a3c3559e62b29f447891239dc82fa4166d711dc41cdf9051bd8b4c

$ docker rm 6a56353106a3c3559e62b29f447891239dc82fa4166d711dc41cdf9051bd8b4c
6a56353106a3c3559e62b29f447891239dc82fa4166d711dc41cdf9051bd8b4c

$ MONGO_IMAGE_VERSION=3.4.9 dokku mongo:start database-name
=====> Starting container
       Waiting for container to be ready
{% endhighlight %}

### Backup MongoDB

See [Backing up MongoDB Databases in Dokku Containers to Dropbox](/2016/02/15/backing-up-mongodb-databases-in-dokku-containers-to-dropbox.html).

