---
layout: post
title: "Storing Timestamps in MongoDB with Mongoid"
date: "2018-08-25"
tags: [mongodb, mongoid]
---
Coming from [mongoid-locker#57](https://github.com/mongoid/mongoid-locker/pull/57), in which I, too, wasn't sure whether calling `.utc` on a timestamp was necessary with Mongoid.

The [MongoDB documentation](https://docs.mongodb.com/manual/tutorial/model-time-data/) is pretty clear - _MongoDB stores times in UTC by default, and will convert any local time representations into this form._ The [Mongoid documentation on timestamps](https://docs.mongodb.com/mongoid/master/tutorials/mongoid-documents/#timestamping) doesn't say anything about time zones, however its [confguration docs](https://docs.mongodb.com/mongoid/master/tutorials/mongoid-configuration/index.html) say that you have to set `use_utc` to `true` to _ensure all times are UTC in the app side_.

What all of this means is that you don't have to worry about timezones unless you're trying to display a date/time to a user in their time zone. Just store a date/time, use it as you would use any timestamp regardless of where it came from, and call it a day.

Lets experiment a bit.

{% highlight ruby %}
require 'mongoid'

Mongoid.connect_to 'test'

class Foo
  include Mongoid::Document
  include Mongoid::Timestamps
end

Foo.create!
{% endhighlight %}

The MongoDB log shows that the time is inserted in UTC, `"updated_at"=>2018-08-25 10:12:58 UTC`.

According to [the documentation](https://docs.mongodb.com/manual/core/shell-types/), internally, Date objects are stored as a signed 64-bit integer representing the number of milliseconds since the Unix epoch (Jan 1, 1970). The shell returns an ISO date.

{% highlight bash %}
$ mongo
MongoDB server version: 4.0.1
> use test
switched to db test
> db.foos.findOne()
{
  "_id" : ObjectId("5b812baa7186b5320c9346a9"),
  "updated_at" : ISODate("2018-08-25T10:12:58.514Z"),
  "created_at" : ISODate("2018-08-25T10:12:58.514Z")
}
{% endhighlight %}

Lets try with a well known time.

{% highlight ruby %}
Foo.create!(created_at: Time.at(0).utc)
Foo.create!(created_at: Time.at(0))
{% endhighlight %}

Both are inserting `1970-01-01 00:00:00 UTC`.

How about a local time?

{% highlight ruby %}
now = Time.now
puts now

Foo.create!(created_at: now.utc)
Foo.create!(created_at: now)
{% endhighlight %}

My local time is `2018-08-25 12:44:37 +0200` and both insert `2018-08-25 10:44:37 UTC`.

Lets query some times.

{% highlight ruby %}
Foo.where(:created_at.gte => now)
Foo.where(:created_at.gte => now.utc)
{% endhighlight %}

Both are doing `"created_at"=>{"$gte"=>2018-08-25 10:46:41 UTC}}`.

You get the idea: it doesn't matter whether you call `.utc` or not, the server will store times in UTC. This also means that you don't know in which original timezone a timestamp was recorded from, but that the data is fully portable between timezones and that your application's timezone can change. Finally, MongoDB has interesting non-obvious features in its aggregation framework that let you extract and group times within a specific timezone (see [SO#18287493](https://stackoverflow.com/questions/18287493/how-to-deal-with-the-timezone-issue-when-storing-dates-in-utc-using-mongod)) for details.

What if you care about the timezone at save time? It looks like that would require changing how MongoDB stores the timestamp or you would have to store a timezone separately. The [mongoid-metastamp gem](https://github.com/sporkd/mongoid-metastamp) claimed to do this, but it hasn't been updated in a long time and doesn't currently support any new versions of Mongoid.



