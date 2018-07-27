---
layout: post
title: "Running Slack Bots on DigitalOcean with Dokku"
date: 2016-02-08
tags: [slack, api, digitalocean]
comments: true
---
Slack bot experimentation, especially for not-too-serious purposes, has become a little too expensive on Heroku. There's no free tier for maintaining apps running 24/7, so the dollars add up quickly at 7x12=84$ a year per application. I am currently running [playplay.io](http://playplay.io), [shell](http://shell.playplay.io), [api-explorer](http://api-explorer.playplay.io) and [market](http://market.playplay.io). Add another $18x12 = $216 for a non-free-tier MongoDB for one of the apps and it's no longer a coffee-money bill.

I've always liked and thought highly of DigitalOcean, but loved the convenience of Heroku and enjoyed having all my apps in one place with a consistent git workflow. Yesterday one of DigitalOcean developers kindly offered me some droplet credits to run one of the bots their team uses. I decided that _free_ beats _convenient_ and that it's time to do some work, save money and learn a few things.

tl;dr A 20$ droplet can easily run half a dozen Ruby bots. I won't miss Heroku much.

### Getting a Droplet with Dokku

Sign up for a DigitalOcean account. If you haven't, use [my referral link](https://m.do.co/c/5b26011f9a9b), and thank you. Enable two-factor auth and create a Dokku droplet from within _One-click Apps_. I use a 20$ one, but smaller works too.

![create droplet]({{ site.url }}/images/posts/2016/2016-02-08-running-slack-bots-on-digital-ocean-with-dokku/signup.png)

[Dokku](https://github.com/dokku/dokku) is a docker-powered PaaS. These days it's very mature and works flawlessly.

You'll be asked for an SSH key during setup. Use your existing one or generate a new one with `ssh-keygen` (I made `digitalocean_id_rsa` and `digitalocean_id_rsa.pub`), copy-paste the contents of the `.pub` file into the box during signup and save the private and public keys in a vault (I use 1Password).

DigitalOcean boots a droplet and assigns it an IP address. I use [DNSimple](https://dnsimple.com/r/0fd8bf77eef5bd) to give it a name via an A DNS record as well as a wildcard entry.

![dns entry]({{ site.url }}/images/posts/2016/2016-02-08-running-slack-bots-on-digital-ocean-with-dokku/dnsimple.png)

Finally, navigating to the droplet's URL and clicking a couple of buttons will complete the Dokku setup.

### SSH and Dokku

Install `dokku-cli` via `gem install dokku-cli`. Adding a `dokku` remote to your local git repository will let you run `dokku config` and other commands just like on Heroku. You can also SSH to the Droplet and run commands from there. It's just a Linux Ubuntu box.

![ssh]({{ site.url }}/images/posts/2016/2016-02-08-running-slack-bots-on-digital-ocean-with-dokku/ssh.png)

You can run `dokku` to get all the available commands.

### MongoDB

My bot stores data in MongoDB, so I need to get that into Dokku.

{% highlight bash %}
dokku plugin:install https://github.com/dokku/dokku-mongo.git mongo
{% endhighlight %}

Create a database. This actually starts a MongoDB instance which is not accessible from the outside world.

{% highlight bash %}
root@dblock-plum:/# dokku mongo:create market-bot
-----> Starting container
       Waiting for container to be ready
=====> MongoDB container created: market-bot
       DSN: mongodb://market-bot:******@dokku-mongo-market-bot:27017/market-bot
{% endhighlight %}

Of course you don't have to do any of this and signup for a MongoDB hosting provider like MongoLab or Compose, too.

### Creating an App

Creating an app is very similar to Heroku. In fact, this uses [herokuish](https://github.com/gliderlabs/herokuish), a utility for emulating Heroku build and runtime tasks in containers, so from now on everything pretty much looks like Heroku.

{% highlight bash %}
root@dblock-plum:/# dokku apps:create market-bot
Creating market-bot... done
{% endhighlight %}

We want to link the MongoDB container to this app, ie. publish a `MONGO_URL` configuration setting to the app and connect the apps logically.

{% highlight bash %}
root@dblock-plum:/# dokku mongo:link market-bot market-bot
no config vars for market-bot
-----> Setting config vars
       MONGO_URL: mongodb://market-bot:******@dokku-mongo-market-bot:27017/market-bot
-----> Restarting app market-bot
App market-bot has not been deployed
{% endhighlight %}

Any other environment variable can be set as well.

{% highlight bash %}
root@dblock-plum:/# dokku config:set market-bot SLACK_CLIENT_ID=... SLACK_CLIENT_SECRET=... RACK_ENV=production LANG=en_US.UTF-8
{% endhighlight %}

### Supervisord

Install [dokku-logging-supervisord](https://github.com/sehrope/dokku-logging-supervisord) to auto-restart crashing processes, just like on Heroku. Use [this fork](https://github.com/rsteckler/dokku-logging-supervisord) to avoid [docker-locking-supervisord#34](https://github.com/sehrope/dokku-logging-supervisord/issues/34) which points to [docker#18543](https://github.com/docker/docker/issues/18543) as a bug that causes hangs on restart.

{% highlight bash %}
root@dblock-plum:/# dokku plugin:install https://github.com/rsteckler/dokku-logging-supervisord.git
{% endhighlight %}

This will also cause application log files to go into `/var/log/dokku/[app name]`, so you can `tail -f` those normally.

### Pushing Code

Dokku supports Git workflow. Add a remote and push code to it.

{% highlight bash %}
~/slack-market (master)$ git remote add dokku dokku@dblock-plum.digitalocean.playplay.io:market-bot
...

~/slack-market (master)$ git push dokku master
...
{% endhighlight %}

The app is now available at _market-bot.dblock-plum.digitalocean.playplay.io_, much like any _herokuapp.com_ applications. I added a DNS CNAME [market.playplay.io](https://market.playplay.io) entry pointing here and told Dokku about it.

{% highlight bash %}
root@dblock-plum:~# dokku domains:add market-bot market.playplay.io
-----> Configuring market-bot.dblock-plum.digitalocean.playplay.io...(using /var/lib/dokku/plugins/available/nginx-vhosts/templates/nginx.conf.template)
-----> Configuring market.playplay.io...(using /var/lib/dokku/plugins/available/nginx-vhosts/templates/nginx.conf.template)
-----> Creating http nginx.conf
-----> Running nginx-pre-reload
       Reloading nginx
-----> Added market.playplay.io to market-bot
{% endhighlight %}

### Hot Deploys

When a new version of a bot is deployed, Dokku will wait `DOKKU_WAIT_TO_RETIRE` to shutdown the previous instance. You may not want two instances of a bot to hang around and either set this time to zero or a smaller number.

{% highlight bash %}
root@dblock-plum:~# dokku config:set --global DOKKU_WAIT_TO_RETIRE=0
-----> Setting config vars
       DOKKU_WAIT_TO_RETIRE: 5
{% endhighlight %}

### New Relic

Sign up for New Relic and configure it for Docker as described [here](https://docs.newrelic.com/docs/servers/new-relic-servers-linux/installation-configuration/enabling-new-relic-servers-docker), which gives you a view inside the Docker containers.

![NewRelic]({{ site.url }}/images/posts/2016/2016-02-08-running-slack-bots-on-digital-ocean-with-dokku/newrelic.png)

{% highlight bash %}
dokku config:set market-bot NEW_RELIC_APP_NAME=market-bot NEW_RELIC_LICENSE_KEY=...
{% endhighlight %}

### Lets Encrypt

Setup SSL as described [here](https://medium.com/@pimterry/effortlessly-add-https-to-dokku-with-lets-encrypt-900696366890).

{% highlight bash %}
root@dblock-plum:~# dokku plugin:update letsencrypt
...
{% endhighlight %}

For a new app.

{% highlight bash %}
root@dblock-plum:~# dokku domains:add market-bot market.playplay.io
-----> Added market.playplay.io to market-bot
...

dokku config:set --no-restart market-bot DOKKU_LETSENCRYPT_EMAIL=dblock@example.com
-----> Setting config vars
       DOKKU_LETSENCRYPT_EMAIL:    dblock@example.com

root@dblock-plum:~# dokku letsencrypt market-bot
=====> Let's Encrypt market-bot
...
done
{% endhighlight %}

### Things I Will Miss

The only thing I will miss from Heroku is the ability to change the number and the size of each process. Other than that the DigitalOcean + Dokku combination is much more cost-effective and equally convenient.
