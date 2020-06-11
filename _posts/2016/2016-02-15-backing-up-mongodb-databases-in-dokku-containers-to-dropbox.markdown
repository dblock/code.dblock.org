---
layout: post
title: "Backing up MongoDB Databases in Dokku Containers to Dropbox"
date: 2016-02-15
tags: [dokku, digitalocean, mongodb]
comments: true
---
I've [recently moved](/2016/02/08/running-slack-bots-on-digital-ocean-with-dokku.html) my Slack bots to Dokku running on DigitalOcean. The bots use local MongoDB database containers provided by the [dokku-mongo](https://github.com/dokku/dokku-mongo) plugin. Here's the entire setup, from installation to backup to Dropbox.

### Install

{% highlight bash %}
dokku plugin:install https://github.com/dokku/dokku-mongo.git mongo
{% endhighlight %}

### Create a Database

This starts a MongoDB instance which is not accessible from the outside world.

{% highlight bash %}
root@dblock-plum:/# dokku mongo:create market-bot
-----> Starting container
       Waiting for container to be ready
=====> MongoDB container created: market-bot
       DSN: mongodb://market-bot:******@dokku-mongo-market-bot:27017/market-bot
{% endhighlight %}

### Backup with Dropbox

You can certainly rely on DigitalOcean's weekly system backup or any other backup system. However I wanted a daily backup and a historical archive of the data in each individual MongoDB. I also wanted it to be free or cheap.

#### Install Dropbox

{% highlight bash %}
cd ~ && wget -O - "http://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
{% endhighlight %}

This creates `~/.dropbox-dist`, and you can manually start Dropbox via `~/.dropbox-dist/dropboxd`.

#### Configure First Time

Run Dropbox for the first time.

{% highlight bash %}
~/.dropbox-dist/dropboxd
{% endhighlight %}

Dropboxd will tell you _"This client is not linked to any account ..."_ and give you a link copy that and paste it in your local web browser, authenticate and validate the new connection. You can stop the daemon with Ctrl+C.

#### Auto-Start

Create `/etc/init.d/dropbox` from [this gist](https://gist.github.com/dblock/9559719f89ba1e0e4630), eg. `sudo vi /etc/init.d/dropbox`. Edit `DROPBOX_USERS` below (eg. `user1 user2`). I just use `root`.

{% highlight bash %}
DROPBOX_USERS="root"

DAEMON=.dropbox-dist/dropboxd

...
{% endhighlight %}

Set it to automatically start on boot.

{% highlight bash %}
sudo chmod +x /etc/init.d/dropbox
sudo update-rc.d dropbox defaults
{% endhighlight %}

Start the service.

{% highlight bash %}
service dropbox start
{% endhighlight %}

Check that it's running.

{% highlight bash %}
service dropbox status
dropboxd for USER root: running (pid 993)
{% endhighlight %}

#### Selective Sync

If you need selective sync, check out [this blog post](http://buildcontext.com/blog/2012/dropbox-linux-ubuntu-ec2-linode-selective-sync).

### Backup MongoDB Databases

#### Create an Export Script

Create `Dropbox/bin/dokku-mongo-export.sh`. It enumerates Dokku MongoDB databases and runs `mongo:export` on them. The archive that [mongo:export produces](https://github.com/dokku/dokku-mongo/blob/master/functions#L115) is gzipped archive output of `mongodump`.

Notice I just put the script in my Dropbox ;)

{% highlight bash %}
#!/bin/bash

echo "Backing up MongoDB databases to Dropbox ..."

dt=$(date +"%Y-%m-%d")

echo " today is $dt"

BACKUP_PATH=~/Dropbox/mongo/backup/$(date +"%Y")/$(date +"%B")
echo " creating $BACKUP_PATH .."

dbs=$(dokku mongo:list | grep -v ===)

for db in $dbs
do
  echo " backing up $db ..."
  mkdir -p $BACKUP_PATH/$db
  f=$BACKUP_PATH/$db/$dt-$db.dump.gz
  dokku mongo:export $db > $f
done
{% endhighlight %}

The latest version of this script is [here as a gist](https://gist.github.com/dblock/acd70c84af3a3531a510). Make sure to `chmod 700 dokku-mongo-export.sh` and run it manually to test.

#### Run the Script Daily

{% highlight bash %}
cd /etc/cron.daily/
ln -s /root/Dropbox/bin/dokku-mongo-export.sh dokku-mongo-export
{% endhighlight %}

Note that only executables without an extension run from `/etc.cron.*/`, hence the name of the symbolic link is different from the script.

#### Restoring Data

The archive that [mongo:export produces](https://github.com/dokku/dokku-mongo/blob/master/functions#L115) is gzipped archive output of `mongodump`. To restore in Dokku, use `mongo:import`. To restore locally, run `mongorestore --gzip --archive=filename`.

### Neat

This will neatly organize your database backups in Dropbox.

![backups]({{ site.url }}/images/posts/2016/2016-02-15-backing-up-mongodb-databases-in-dokku-containers-to-dropbox/backups.png)
