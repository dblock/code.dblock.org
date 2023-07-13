---
layout: post
title: "The tech? It just worked. Thanks AWS!"
redirect_from: "/the-tech-it-just-worked-thanks-aws/"
date: 2012-10-13 22:35:11
tags: [aws, artsy, heroku, architecture]
comments: true
dblog_post_id: 352
---
![]({{ site.url }}/images/posts/2012/2012-10-13-the-tech-it-just-worked-thanks-aws/image3.jpg)

_The NYT warned us about the traffic firehose  ..._

The public launch of [Art.sy](https://artsy.net) via the [New York Times](https://www.nytimes.com/2012/10/09/arts/design/artsy-is-mapping-the-world-of-art-on-the-web.html) last week was an incredible experience.

I first saw an Art.sy prototype in January 2011. It was built in PHP, had a Java web-services back-end talking SOAP and running on a MySQL database. By March that year the tech was rebooted. We’ve iterated at a crazy pace steadily opening the beta for almost two years. And finally, we've served over 10x the highest known number of simultaneous users on a complex, content-rich and interactive system last week. The pounding of our service continues today, setting a new traffic baseline and plenty of future growth to look forward to.

I’ve seen and contributed first hand to plenty of failing and succeeding technology. Aside of having an A-team of engineers, what makes a successful launch possible? It’s without any doubt, the Cloud. It finally enables web technology to "just work". We use a plethora of services, including [Heroku](https://heroku.com/) and [MongoHQ](http://mongohq.com/), all of which run on [AWS](https://aws.amazon.com/). We designed a very simple and horizontally scalable system and then just provisioned front-ends with the growing traffic needs. I realize that I now take this kind of infrastructure for granted, and am always surprised when I meet people that have their minds blown by it. If the concept of getting a booted server responding to web requests in under 60 seconds sounds like science-fiction to you, time to press that reset button and find a new job!

Want a list of new and old tech to check out? Read my blog post on [Art.sy’s Tech Stack](https://artsy.github.io/blog/2012/10/10/artsy-technology-stack/).
