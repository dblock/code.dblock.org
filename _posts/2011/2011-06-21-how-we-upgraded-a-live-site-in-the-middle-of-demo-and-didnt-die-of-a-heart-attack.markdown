---
layout: post
title: "How we Upgraded a Live Site in the Middle of Demo (and Didn’t Die of a Heart Attack)"
redirect_from: "/how-we-upgraded-a-live-site-in-the-middle-of-demo-and-didnt-die-of-a-heart-attack/"
date: 2011-06-21 14:24:53
tags: [artsy, testing, agile]
comments: true
dblog_post_id: 220
---
![]({{ site.url }}/images/posts/2011/2011-06-21-how-we-upgraded-a-live-site-in-the-middle-of-demo-and-didnt-die-of-a-heart-attack/image_9.jpg)

Last week I got to experience Art Basel from the inside. [Art.sy](https://artsy.net) was presented at the "most exclusive event" at the Beyeler Foundation, to quote [an article](http://www.artinfo.com/news/story/37897/from-christian-marclay-to-will-ferrell-see-the-stars-at-the-elite-and-highly-eclectic-bash-for-the-launch-of-artsy-in-basel/). Behind all the hype, we were very nervous. I had high confidence in the mountain of work that was put into the site by our A-team of 5 engineers, but it was really the first time we were showing it live to so many partners. There was no plan B, it just had to work. Then we  had to upgrade the site on-the-fly during the big demo.

What?!

We got these gigantic 28’’ monitors that had an unusually wide aspect ratio. We had thirty minutes to set them up before people started arriving. They were beautiful, but it became quickly apparent that we had a nasty image stretching bug that made most horizontal paintings appear wider than they were. Needless to say this was a critical problem – the art world is extremely sensitive to displaying and describing things accurately. Someone back in New York had a fix in just a few minutes, CI picked it up and all tests passed. Were we going to deploy this right now and risk everything? No way, no, no ... no! I was being pulled away to get introduced to a major museum executive who wanted to know more about genome search. A big name collector was staring at an overstretched Robert Longo’s "Study for White Ghost". My colleague doing the demo was composed, but pale. I said "let’s do it".

(insert two minutes of dramatic music here)

Nothing happened. The fix was deployed with zero downtime and the demo was a total success.

A lot of small things added up to this, preventing many heart attacks and therefore lowering the total cost of medical insurance.

1. We have a culture where it’s OK to fail. Relieving as much unnecessary pressure as possible helps people make rational decisions and focus on the problem rather than on the stress.
2. We have working continuous integration (using [CIJoe](https://github.com/defunkt/cijoe)) that builds, runs tests and deploys the system to a staging environment that looks like a copy of production.
3. We use an automated system ([Heroku Bartender](https://code.dblock.org/ShowPost.aspx?Id=186)) for deploying to production. We can easily rollback in the case of a disaster. We’ve done this a couple of times.
4. We deploy several times a day, rain or shine. We have experienced live update many times over and worked through many early failures.
5. We deploy to a virtually zero downtime platform ( [Heroku](http://www.heroku.com/)), which compiles the application and swaps instances without terminating any requests, queuing them inside a proxy.
6. We are very diligent about testing regressions. Our best tests are those that make sure we don’t reintroduce previously found bugs.
7. We’re pragmatic about test-driven development. While we always try to write tests upfront, we spend much more time writing regression tests.
8. We use copies of production data (with faked user data) in all our development, testing and staging environments.
9. We do have a demo environment upgraded once a week or so as a backup plan for peace of mind. We’ve actually never used it.

We’re still very young and don’t have a service that’s used by millions of people, but this experience tells us we did something right. This was a small technical success.
