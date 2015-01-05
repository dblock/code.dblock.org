---
layout: post
title: "Blame it all on MongoDB"
redirect_from: "/blame-it-all-on-mongodb"
date: 2011-12-20 17:26:09
tags: [art.sy, mongodb, ruby]
comments: true
---
You may have read my [previous post](http://code.dblock.org/mongoid-202-mongo-bson-bsonext-140-and-141) about the MongoDB 1.4.x Ruby driver hell.

We rolled back to 1.3.1 and were running fine in production for a long time. On Friday, we started seeing intermittent _deadlock: recursive locking_ errors from the driver and our site was struggling to stay up. Very quickly the error rate rendered it unusable. A Google search yielded Mongo Ruby driver bug [RUBY-274](https://jira.mongodb.org/browse/RUBY-274), describing the exact error, which pointed a Ruby 1.9.2 threading issue [#4266](http://bugs.ruby-lang.org/issues/show/4266), explained in [this blog post](http://blog.stochasticbytes.com/2011/01/rubys-threaderror-deadlock-recursive-locking-bug/).

We were confused why this suddenly started happening with no apparent reason, created a ticket with our MongoDB provider [MongoHQ](http://mongohq.com) and bounced the replica set members one-by-one as well as our app on Heroku. It did nothing.

Kyle, the maintainer of the Ruby driver at 10gen was replying to [RUBY-274](https://jira.mongodb.org/browse/RUBY-274) and told us to upgrade the driver to 1.5.2. We did. All tests passed (we have over 2000) and our staging site was operating normally. But after pushing it in production where we have a replica set, we were now seeing a different error: _stack level too deep_, with _/app/.bundle/gems/ruby/1.9.1/gems/mongo-1.5.2/lib/mongo/util/pool.rb:72_ on top of a cut-off stack trace. By then I haven’t gotten up from my chair for six hours straight and you bet I was thinking the Ruby driver was the worst piece of crap as I was angrily typing [RUBY-393](https://jira.mongodb.org/browse/RUBY-393), a knee-jerk reaction.

With a bit of calm and holding onto a better error someone on my team dug through this and hit the the root cause. We made a mistake in a data model and ended up with a recursion in a query. Instead of reporting an expected _stack level too deep_ error for this one particular request the Ruby 1.3.1 driver blew up with _deadlock: recursive locking_ and no stack trace, caused by a bug in Ruby 1.9.2, while other queries would immediately start failing bringing the entire site down with this error. The newer version of the driver did much better and only failed the specific query, which was much easier to diagnose. Pilot error – lessons learned. Sincere apologies to everyone involved at 10gen and MongoHQ – you guys were there when I needed you.

The 1.5.2 driver has been running rock solid over the week-end. I am hearing good things about it from other teams too. If you’re on 1.3.1 or 1.4.x, you should consider upgrading.
