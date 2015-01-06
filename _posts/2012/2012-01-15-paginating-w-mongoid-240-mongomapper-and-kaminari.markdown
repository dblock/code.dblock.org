---
layout: post
title: "Paginating w/ Mongoid 2.4.0, MongoMapper and Kaminari"
redirect_from: "/paginating-w-mongoid-240-mongomapper-and-kaminari/"
date: 2012-01-15 13:54:15
tags: [mongoid, mongodb, ruby]
comments: true
---
I’ve upgraded our project from Mongoid 2.0.2 to 2.4.0. It took me a few days since our specs raised a couple of real issues. If you’re doing the same, take Mongoid from the tip of [2.4.0-Stable](https://github.com/mongoid/mongoid/tree/2.4.0-stable).

If you remember, 2.0.2 dropped pagination support and a helpful Kaminari gem took over (details [here](http://code.dblock.org/mongoid-202-dropped-pagination-kaminari)). Once again the upgrade had a surprise, the number of items on the current page was wrong, displaying the entire count of a collection. I thought this was a bug in Mongoid and created [#1584](https://github.com/mongoid/mongoid/issues/1584). Turns out that the behavior of _count_ on a_ Mongoid::Criteria_ is now aligned with the Ruby driver, which takes a curious boolean _skip_and_limit_ parameter that basically says whether to take _limit_ and _skip _options into account (doc [here](http://api.mongodb.org/ruby/1.2.0/Mongo/Cursor.html#count-instance_method)). So calling _Foo.limit(1).count_ may return 10 if there’re 10 Foos. The fix is to call _Foo.limit(1).count(true)_. I am going to guess this was a bug in the Mongo driver and the additional of a boolean was a clever hack?

Kaminari needed to pass the boolean, which meant adding a _current_page_count_ to the Kamiari collection wrapper, pulled in [#194](https://github.com/amatsuda/kaminari/pull/194). Next version (probably 0.14.0) will have the fix. In the meantime, I am not super happy with my [implementation](https://github.com/amatsuda/kaminari/pull/194/files):

- It’s not possible to know whether _count_ takes a parameter, _method(:count).arity_ doesn’t provide enough indication for optional parameters, so the code relies on a _ArgumentError_.
- MongoMapper needed the same fix, but is lacking a way to pass count to the driver. The current implementation calls _to_a_, which can’t be good when you just want a count.
