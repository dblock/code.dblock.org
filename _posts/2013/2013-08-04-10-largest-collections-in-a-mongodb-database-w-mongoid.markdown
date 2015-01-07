---
layout: post
title: "10 Largest Collections in a MongoDB Database w/ Mongoid"
redirect_from: "/10-largest-collections-in-a-mongodb-database-w-mongoid/"
date: 2013-08-04 16:47:44
tags: [mongoid, mongodb]
comments: true
dblog_post_id: 390
---

{% highlight ruby %}
Mongoid.default_session.collections.map do |c|
  s = Mongoid.default_session.command(collstats: c.name)
  [c.name, s["size"] + s["totalIndexSize"] ]
end.sort_by { |n, s| -s }.take(10).each do |n, s|
  puts "#{n}: #{s}"
end; nil
{% endhighlight %}

Outputs something like this:

```
squirrels: 5432044544
monkeys: 949976816
sleuths: 723951712
```

