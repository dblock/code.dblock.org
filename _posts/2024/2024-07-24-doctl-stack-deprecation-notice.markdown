---
layout: post
title: "Enumerating DigitalOcean Apps with a Deprecated Ubuntu 18 Stack"
date: 2024-07-24
tags: [digitalocean]
comments: true
---
I use [DigitalOcean](https://m.do.co/c/5b26011f9a9b) to [run a bunch of apps](https://code.dblock.org/2023/01/15/migrating-from-dokku-to-digital-ocean-apps.html). It's working out great. 

Yesterday, they sent me an email with a menacing _"Ubuntu 18 is no longer supported and so it’s not receiving security updates."_ note. To be fair, Ubuntu 18 is very old.

Their email included instructions to go to settings to find out what stack you're using. Let's find out what apps use what stack on the command line to save time using [doctl](https://docs.digitalocean.com/reference/doctl/) and [yq](https://github.com/mikefarah/yq).

{% highlight bash %}
$ for app_id in $(doctl apps list --no-header | cut -d' ' -f1); do \
    doctl apps spec get $app_id | yq ".name,.features"; \
    done

app-1
- buildpack-stack=ubuntu-22
app-2
- buildpack-stack=ubuntu-18
{% endhighlight %}

Should I upgrade now, or wait till the second and third notice?