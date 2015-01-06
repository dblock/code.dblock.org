---
layout: post
title: "Continuous Deployment with Heroku-Bartender"
redirect_from: "/continuous-deployment-with-heroku-bartender/"
date: 2011-03-20 19:13:22
tags: [art.sy, heroku, rails, ruby]
comments: true
dblog_post_id: 186
---
You’ve heard about continuous deployment. But did you actually try to do it?

I’ve never deployed anything five times a day. Much less with a team of people where every engineer has access to the "push to production" button. I mean, I like to sleep peacefully at night. But having recently pressed the reset button on everything technology, I began to quickly unlearn such concepts as _integration_, _zero bug bounce_ and, finally, _branching_ and _releasing_. To do continuous deployment we will do none of those things! Instead, we will rely on automated testing, bit-sized increments and experiments - features that can be turned off and on for portions of the user base. Most importantly, we’ll trust each-other in the engineering team and will learn from our mistakes.

We didn’t want a big complex system and tried to find something dedicated to production push. Our man [@sarcilav](https://github.com/sarcilav) ended up writing a tool that can automate pushing a Rails application to Heroku. It’s called [Heroku-Bartender](https://github.com/sarcilav/heroku-bartender), and it’s scoring many points.

Here’s what our instance looks like.

![]({{ site.url }}/images/posts/2011/2011-03-20-continuous-deployment-with-heroku-bartender/image_10.jpg)

You can see your Github commits (white) and all the successful pushes to production (green). You can deploy any change, including an old one, which means you can rollback to any previous check-in when things go bad. The implementation is rudimentary, but we have been doing several deployments a day and it worked like a charm. It also seems that Heroku receives a push, compiles a slug, then hot-swaps it, creating no downtime for users. That’s continuous deployment right there for dirt cheap!

Every developer in my team has the keys to this system. Everyone knows that their changes can make it to production anytime. Once a developer finishes something visible, they wait for the continuous integration server (we use [CIJoe](https://github.com/defunkt/cijoe)) to pass all tests, then just hit build on the Heroku-Bartender instance.

Heroku-Bartender is open-source and lives at [https://github.com/sarcilav/heroku-bartender](https://github.com/sarcilav/heroku-bartender). Use it. Fork it. Contribute some features!

PS: if you’re using another continuous deployment system that works (or doesn’t), tell us about your experience and about the tools you use.
