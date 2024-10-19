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

Update: many of my Ruby apps required a Ruby 3.x upgrade before booting successfully on Ubuntu 22. Links to the upgrade diffs/commits below.

* [slack-strava](https://github.com/dblock/slack-strava/compare/55ccd64e130d504277b3522af1b72ae70e797cd7..5a595b2ba1c736d52a7b4f936585b2ce2deb4230)
* [slack-sup2](https://github.com/dblock/slack-sup2/commit/5bf423375cd9e390a76d7a1fdf828edbaabe46b5)
* [slack-gamebot2](https://github.com/dblock/slack-gamebot2/commit/60fae7d9bbf124b19b78a3826182e6bc9357ae93)
* [slack-sup](https://github.com/dblock/slack-sup/compare/26f22ee0488164f16394aae49faedd4906d01978..eb00159ba2200837f5e118f1b0390a18b6796d77)
* [slack-gamebot](https://github.com/dblock/slack-gamebot/commit/aac22e8cf02efc691906f4e397248283682b5ac9)
* [discord-strava](https://github.com/dblock/discord-strava/compare/bba2ce971e0142ff5e56c8244df79e9b3a3d160b..db09ffe396e4ad4ee7cb42c16a4766cda7bbd70c)
* [slack-invite](https://github.com/vestris/slack-invite/commit/744ec76aedbcd0548ba93b57126db29abcd98686)
* [slack-arena](https://github.com/dblock/slack-arena/commit/d08efa5d4913c22e40aec4ee6d03472002306877)
* [slack-moji](https://github.com/dblock/slack-moji/commit/e240efa93305334c06e7ea5dc1d0322824f864a6)