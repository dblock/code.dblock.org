---
layout: post
title: Migrating from Dokku to DigitalOcean Apps
date: 2023-01-15
tags: [mongodb, slack, devops]
comments: true
---
In 2016 I [moved](/2016/02/08/running-slack-bots-on-digital-ocean-with-dokku.html) half a dozen apps from Heroku to a DigitalOcean droplet to save money. I found [dokku](https://github.com/dokku/dokku), a docker-powered PaaS. It was already quite mature, and worked flawlessly. In 2023 I am moving back from the single droplet to apps, but staying on DigitalOcean. It was a good 7-year-long run for my droplet!

### What am I moving?

I've got 4 profitable, and 5 money-losing or free Slack apps, all open-source.

- [www.playplay.io](https://www.playplay.io): A ping-pong/chess/pool/tic-tac-toe leaderboard for Slack.
- [slava.playplay.io](https://slava.playplay.io/): Strava integration in Slack.
- [sup.playplay.io](https://sup.playplay.io/): Helps team members meet every week in an informal standup.
- [market.playplay.io](https://market.playplay.io/): Stock market quotes in Slack.
- [moji.playplay.io](https://moji.playplay.io/): More emoji in Slack.
- [invite.playplay.io](https://invite.playplay.io/): Help your users join your Slack.
- [arena.playplay.io](https://arena.playplay.io/): Are.na integration with Slack.
- [shell.playplay.io](https://shell.playplay.io/): Whoa, a bash shell inside Slack!
- [api-explorer.playplay.io](https://api-explorer.playplay.io/): A Slack web API explorer.

### Why move?

Over the years I got increasingly nervous about doing any kind of maintenance operations on the Linux droplet. Upgrading Dokku, or its plugins, under half a dozen applications had the potential side effect of taking all my projects down at once. Before doing anything drastic, I would cautiously snapshot my droplet. For major upgrades, I would even power the droplet down before making a snapshot, incurring half an hour of downtime. Then I'd type `sudo apt-get upgrade`, fingers crossed. A couple of times these operations would render the host inoperable, so I'd revert and figure out a manual path forward.

In early 2022 the inevitable happened: I [got permanently stuck](https://github.com/dokku/dokku/issues/5523) with an old Linux distro that just would not upgrade the ancient 3.13 kernel to 4.x. Slack runs periodic pentests on its marketplace bots, and I was now running on non-LTS versions of Ruby, whereas newer versions would [not work on the old kernel](https://github.com/heroku/heroku-buildpack-ruby/issues/1312) (_securerandom.rb:75:in 'urandom': failed to get urandom (RuntimeError)_). I was forced to upgrade, but every attempt to bring my Dokku apps back up on a 4.x kernel failed. Docker refused to start with my existing data. 

I finally had to accept that I was just not smart enough to understand what _"aufs is not supported anymore"_ meant, or how I was supposed to _"use overlay"_ without losing all my existing data, despite the fact that _"as far as people know, only ephemeral container data is stored in that aufs path"_. I was *that* old to understand how Docker worked. I've finally reached the level of my incompetence!

The only workable solution was to provision a new server with a newer Linux distro, and migrate everything to it. Instead, I decided to evaluate other options. Because DigitalOcean had been a reliable and trusted platform for 7 years, I went with [DigitalOcean apps](https://m.do.co/c/5b26011f9a9b).

### Migration Cookbook

Here's a migration cookbook, mostly for my own reference.

#### Prepare

Lower the DNS TTL to a minute about an hour prior to migration.

#### Migrate Data

1. Stop the dokku container on the droplet with `dokku ps:stop app`.
2. Lock the app to prevent future accidental deployments with `dokku apps:lock app`.
3. Export data from MongoDB with `dokku mongo:export app > app.dump.gz`.
4. Fetch the data from the droplet and back it up with `scp root@domain:/path/to/data/app.dump.gz .`.
5. Restore data into the new managed MongoDB database.
    {% highlight bash %}
mongorestore
  --uri "mongodb+srv://doadmin:password@db/admin?authSource=admin&replicaSet=db&tls=true" 
  --gzip
  --archive=app.dump.gz
  --nsInclude=app.*`.
{% endhighlight %}

#### Create an App

1. Set the new name to `app`.
2. Choose a GitHub repository for source code, grant permissions as needed.
3. Hit `Edit Plan`, reduce containers to 1, choose a $5 basic or $12/pro plan.
4. Hit `Add Resource`, and add a previously created MongoDB database, which adds a user with proper authorizations.
5. Edit environment settings. Copy them from `dokku config app` on the droplet. Remove `DATABASE_URL` that was added automatically, since it doesn't include the right database name.
6. Set the MongoDB database URL `MONGO_URL: mongodb+srv://${db.USERNAME}:${db.PASSWORD}@${db.HOSTNAME}/app?authSource=admin&replicaSet=db&tls=true`.
7. Change a default app name to `app`.
8. Deploy the app.

#### Finish

Add a domain in app settings, update the DNS entry, re-increase back the DNS record TTL.

### Cost Comparison

My monthly server total was $134.39 ($96 for a s-8vcpu-16gb droplet, $4.89 for droplet snapshots, $19.20 for droplet backups, $10.00 for an external 100GB volume for MongoDB data, and $4.30 for volume snapshots). 

Monthly app cost is $103 (5x$5 for basic apps, 4x$12 for pro, $30.00 for a shared 1gb-1vcpu-15gb MongoDB).

It's actually cheaper to use apps than the droplet for roughly the same capacity and availability, minus having to manage infrastructure.

I think DigitalOcean apps are priced very well for my use-case. If you've never used the platform, sign up for an account using [my referral link](https://m.do.co/c/5b26011f9a9b), and thank you.
