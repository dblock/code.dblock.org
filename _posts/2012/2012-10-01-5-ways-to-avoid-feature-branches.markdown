---
layout: post
title: "5 Ways to Avoid Feature Branches"
redirect_from: "/5-ways-to-avoid-feature-branches/"
date: 2012-10-01 12:03:19
tags: [teams, deployment, testing, organizations, agile]
comments: true
dblog_post_id: 348
---
![]({{ site.url }}/images/posts/2012/2012-10-01-5-ways-to-avoid-feature-branches/image_11.jpg)

This is an actual pull request. It’s a merge from a feature branch, which includes some (excellent) work done by several people over the course of 3 weeks. Someone started a prototype, then we all pooled for a week to finish it and decided not to waste time and keep hacking on a feature branch. A week turned into two for perfectly good business reasons. Then into three because of external influences. Some bugs required heavy lifting and a lot of code. Small improvements became big changes.

I feel the same thing about feature branches as [Martin Fowler](https://www.thoughtworks.com/perspectives/30-06-2011-continuous-delivery). There’re plenty of people in [the opposite camp](https://jamesmckay.net/2011/07/why-does-martin-fowler-not-understand-feature-branches/) too.

Long running feature branches are a result of human, cultural and organizational behaviors. While I sometimes fail to, here’re a few ways to avoid them.

#### Make Everything an Experiment

From the tech point of view, experiments require a bit of mechanics with site-wide feature toggles and per-user labs. Features debut being turned off for all users. But the harder part to achieve is where developers feel very comfortable pushing a half-baked feature, experiment or idea into production, whether it’s very mature or a half-baked prototype. Remove friction with tools, then make sure everyone on your team deploys to production in such a way that it’s a low stress operation.

#### Rely 100% on Automation

In order for everyone not to feel anxious pushing that deploy button three times a day with half baked experiments, the production parts of the software must be fully tested. Can my users login to the site? I am 100% sure that the answer is yes. Write tests for your Easter eggs, too. Systematic automation of regression tests for any bugs found in production is good way to ensure you don’t mess up twice.

#### Remove Humans, Chickens and Safety Nets

Don’t do any long bake periods or team-wide manual testing. Remove non-contributing managers from the process. Humans easily succumb to feature creep and are generally hesitant to take responsibility, preventing software from shipping. You don’t need release managers, product committees or war teams. Developers are both the back office and the front line.

#### Defer Some Completeness and Quality

Think twice before pushing back on a pull request with code that’s not quite baked. When properly isolated, it might be good enough. Relax. Merge it. File an improvement in your project or bug tracking system. Test your limits and seek ways to promote trust between engineers by pushing some of these boundaries. Don’t let it get out of hand though.

#### Resist Date-Driven Development

Dates have a tendency to move beyond your control, just as in my example. Ask yourself what meaningful increment you can deliver into production today and figure out how it can contribute to your deadlines. Everything will be different tomorrow!

