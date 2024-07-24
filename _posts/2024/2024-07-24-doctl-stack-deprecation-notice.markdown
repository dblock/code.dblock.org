---
layout: post
title: "Enumerating DigitalOcean Apps with a Deprecated Ubuntu 18 Stack"
date: 2024-07-24
tags: [digitalocean]
comments: true
---
I use [DigitalOcean](https://m.do.co/c/5b26011f9a9b) to [run a bunch of apps](https://code.dblock.org/2023/01/15/migrating-from-dokku-to-digital-ocean-apps.html). It's working out great. 

Yesterday, they sent me an email with a menacing _"Ubuntu 18 is no longer supported and so it’s not receiving security updates."_ note. To be fair, Ubuntu 18 is very old.

Their email included instructions to go to settings to find out what stack you're using. Let's find out what apps use what stack on the command line to save time using [doctl](https://docs.digitalocean.com/reference/doctl/).

{% highlight bash %}
$ for app_id in $(doctl apps list --no-header | cut -d' ' -f1); \
    do echo $app_id; \
    doctl apps spec get $app_id | yq .features; \
    done

110f5185-5570-444e-819c-9651d574c20c
- buildpack-stack=ubuntu-22
e74dcb40-f10e-4ed1-87e1-0ffadd983cea
- buildpack-stack=ubuntu-18
{% endhighlight %}

Should I upgrade now, or wait till the second and third notice?