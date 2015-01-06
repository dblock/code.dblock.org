---
layout: post
title: "Data Corruption Is Most Likely Caused By Your Code And Not Your Database"
redirect_from: "/data-corruption-is-most-likely-caused-by-your-code-and-not-your-database"
date: 2013-02-09 19:30:22
tags: [mongoid, mongodb]
comments: true
---
![]({{ site.url }}/images/posts/2013/2013-02-09-data-corruption-is-most-likely-caused-by-your-code-and-not-your-database/image_11.jpg)

I am increasingly convinced that those who blame MongoDB for any kind of data corruption are waving hands out of desperation. Every single time I had an issue with data I ended up finding code that I’ve written or code that was written in a library that I used. The hardest bugs involve some kind of concurrent operation, including one I’ve described in a new post on the Artsy Engineering blog: [Data Corruption and Concurrent Updates to Embedded Objects w/ MongoDB](http://artsy.github.com/blog/2013/02/09/data-corruption-and-concurrent-updates-to-embedded-objects-with-mongoid/). Read it, especially if you are using an ODM to manipulate embedded objects.

I also want to point out two magical lines of code that I use all the time.

```ruby
Moped.logger = Logger.new($stdout)
Moped.logger.level = Logger::DEBUG
```

Knowing what Mongoid is doing is half the battle.
