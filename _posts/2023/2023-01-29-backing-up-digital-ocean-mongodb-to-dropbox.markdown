---
layout: post
title: Backing up DigitalOcean MongoDB to Dropbox
date: 2023-01-29
tags: [mongodb, devops]
comments: true
---
After [migrating my apps to DigitalOcean apps](/2023/01/15/migrating-from-dokku-to-digital-ocean-apps.html) I started looking for a MongoDB automated offsite backup solution. DO backs up all MongoDB daily automatically, but I am paranoid, and like to store an offsite copy of the data in Dropbox in monthly increments.

I first [tried to build a DigitalOcean app function](https://github.com/dblock/do-mongodb-backup) that could run on a schedule and connect to my database, but ran into two missing features: [lack of non-web app functions](https://ideas.digitalocean.com/app-framework-services/p/non-web-app-functions-that-cannot-be-invoked-externally-without-auth), and [adding functions to trusted sources](https://ideas.digitalocean.com/app-framework-services/p/add-functions-to-trusted-sources). In short you can either make an app with a function that connects to a database, but then it's always a web function with no cron support, or you can make a function that can be invoked on a cron, but cannot connect to your database.

I tried [simplebackups](https://simplebackups.com/?via=dblock), and found the UX somewhat to be desired and that it was too expensive for the service it provided. In theory, it could connect to DO in a single click, and set everything up, but in practice the UX didn't always work, I had to manually allow-list a bunch of IPs, saw cryptic error messages in failing backups, etc. A serverless simple backup with your own storage costs $29/mo, which is too steep for my needs of 1 single database backup that is stored offsite. I'd just be paying for a daily cron, worth no more than $5 to me.

Finally, I settled on a cron and [a script](https://github.com/dblock/dotfiles/blob/master/bash/bin/mongodb-dump) to run on my mac. The script has some nice features, such as storing credentials in the keychain that I reuse in a lot of such scripts.

{% highlight bash %}
AUTH=$(security find-generic-password -s $URI -w)

if [ -z "$AUTH" ]; then
    read -p 'MongoDB Username: ' USERNAME
    read -sp 'MongoDB Password: ' PASSWORD
    printf "\n"
    AUTH=$USERNAME:$PASSWORD
    security add-generic-password -a $USER -s $URI -w "$AUTH"
fi
{% endhighlight %}

Note that to access a DO MongoDB you need your [external IP](https://github.com/dblock/dotfiles/blob/master/bash/bin/ip) in trusted sources. It's annoying to add in case my IP changes, but because I already get automated backups elsewhere, I am OK with these limitations.
