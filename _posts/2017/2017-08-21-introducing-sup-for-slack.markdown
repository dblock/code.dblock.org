---
layout: post
title: "Introducing S'Up for Slack Teams"
date: 2017-08-21
tags: [teams, agile, slack]
comments: true
---
**Update**: I wrote a longer article, ["What “S’Up”? Using Triads to Develop Tribal Leadership"](https://medium.com/artsy-blog/what-sup-using-triads-to-develop-tribal-leadership-a01d4f207bf8) on the Artsy Medium blog about this.

> The most valuable relationships are not made of two people, they’re made of three.  A third person will always stabilize and grow the relationship between the other two. It’s called a triad, and the more you create, the stronger your network.
> - via [CultureSync, Tribal Leadership](https://web.archive.org/web/20170914154315/https://www.culturesync.net/toolbox/intro-to-triads)

I was introduced to S'Up, short for "standup", between three randomly selected people at [Artsy](https://www.artsy.net). Every time I met 3 of my colleagues, especially those who didn't work on my team, I came out with incredible insights. We organized those meetings manually, then [Ilya Kavalerov](https://github.com/ilyakava) automated the process by creating [a web app](https://github.com/artsy/sup). Today I am launching [S'Up for Slack Teams](https://sup.playplay.io).

This bot passively generates fresh triads of company members to meet every week in a S'Up.

<a href='https://sup.playplay.io' target='_blank'>![]({{ site.url }}/images/posts/2017/2017-08-21-introducing-sup-for-slack/sup-dm.png)</a>

S'Up will then ask whether you met and keep track, a few days later.

![]({{ site.url }}/images/posts/2017/2017-08-21-introducing-sup-for-slack/sup-ask.png)

The bot us written in Ruby, is [open-source](https://github.com/dblock/slack-sup) and is available at [sup.playplay.io](https://sup.playplay.io) as a paid service to cover the costs of hosting. A small price to pay for increased communication in your growing organization!
