---
layout: post
title: "Mongoid 2.0.2, Mongo + bson + bson_ext 1.4.0 and 1.4.1"
redirect_from: "/mongoid-202-mongo-bson-bsonext-140-and-141/"
date: 2011-10-22 07:19:42
tags: [mongoid, performance, art.sy, mongodb]
comments: true
dblog_post_id: 280
---
In the past two days we’ve had hell with our production environment. It started with a general feel of slowness followed by all kinds of alarms going off in the monitoring system. Our database performance tanked. The light blue is the time to serve a request (increasing) and the reds are the monitoring system panicking.

![]({{ site.url }}/images/posts/2011/2011-10-22-mongoid-202-mongo-bson-bsonext-140-and-141/image_5.jpg)

The short story is that the issue was caused by the upgrade of the Ruby driver to 1.4.1. The details are filed in [https://jira.mongodb.org/browse/RUBY-347](https://jira.mongodb.org/browse/RUBY-347).

At first, we went down the wrong path of believing that this was a networking issue. We were hitting the Mongo server directly and seeing slow database queries as well, but these were caused by the live system opening a large number of connections and the database server not being able to serve more. The number of connections was the first real useful piece of information.

![]({{ site.url }}/images/posts/2011/2011-10-22-mongoid-202-mongo-bson-bsonext-140-and-141/image18.jpg)

After seeing this graph we backtracked code changes and saw that [mongo-ruby-driver](https://github.com/mongodb/mongo-ruby-driver) (via bson_ext) was upgraded to 1.4.0 right before this started. The [changelog](https://github.com/mongodb/mongo-ruby-driver/blob/master/docs/HISTORY.md) for the next version, 1.4.1 said it fixed a number of issues with replica set refresh. A specific commit described a connection leak [[6a7e991](https://github.com/mongodb/mongo-ruby-driver/commit/6a7e9916892bcf802bafb64db10e0f7ee43610b6)]. Upgrading to 1.4.1 was an improvement, but the performance issues continued at a lesser extent. Finally, downgrading to mongo/bson/bson_ext 1.3.1 got the system healthy again. The number of connections flattened back down and database performance was back to normal.
