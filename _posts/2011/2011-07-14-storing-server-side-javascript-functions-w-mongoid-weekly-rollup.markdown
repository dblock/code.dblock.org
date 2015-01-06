---
layout: post
title: "Storing Server-Side JavaScript Functions w/ Mongoid + Weekly Rollup"
redirect_from: "/storing-server-side-javascript-functions-w-mongoid-weekly-rollup/"
date: 2011-07-14 00:42:44
tags: [mongodb]
comments: true
dblog_post_id: 231
---
I was working on some map/reduce that rolled up daily, weekly and yearly statistics in MongoDB and discovered, to my surprise, that JavaScript Date doesn’t have a _getWeek_ method. Worse, the [piece of code](http://javascript.about.com/library/blweekyear.htm) on About.com turned out to be buggy (it has issues with week 1 and 52). Total Internet #fail. In this post I’ll show you how to add `getWeek(date)` to MongoDB/Mongoid and how to use it from a map/reduce.

The server-side JavaScript is almost like a stored procedure and is documented [here](http://www.mongodb.org/display/DOCS/Server-side+Code+Execution). Let's use [this implementation](http://techblog.procurios.nl/k/n618/news/view/33796/14863/Calculate-ISO-8601-week-and-year-in-javascript.html) with a slight change in parameters and save it as [lib/javascripts/getWeek.js](https://gist.github.com/1081513). We can then store the JavaScript server-side in any Mongoid model. In our case we’ll be counting _Widgets_, so add this to _Widget.rb_.

```ruby
def self.install_javascript
  getWeekJs = Rails.root.join("lib/javascript/getWeek.js")
  if collection.master['system.js'].find_one({'_id' => "getWeek"}).nil?
    collection.master.db.add_stored_function("getWeek", File.new(getWeekJs).read)
  end
end
```

The [add_stored_function](http://api.mongodb.org/ruby/current/Mongo/DB.html) method comes from the Ruby MongoDB driver. Call _Widget.install_javascript_ somewhere in a Rake task or inside your map/reduce code.

Let's now map/reduce our _widgets_ into _widgets_weekly_ using the created_at timestamp. Notice the call to _getWeek_.

```ruby
def self.rollup_weekly
  map = <<-EOS
    function() {
        emit({'ts': this.created_at.getFullYear() + '-' + getWeek(this.created_at) }, {count: 1})
    }
  EOS
  reduce = <<-EOS
    function(key, values) {
      var count = 0;
      values.forEach(function(value) {
        count += value['count'];
      });
      return({ count: count });
    }
  EOS
  collection.map_reduce(map, reduce, :out => "widgets_weekly", :query => {})
end
```

This yields the following collection in _widgets_weekly_.

```
{ "_id" : { "ts" : "2011-1" }, "value" : { "count" : 73 } }
{ "_id" : { "ts" : "2011-2" }, "value" : { "count" : 60 } }
{ "_id" : { "ts" : "2011-3" }, "value" : { "count" : 31 } }
{ "_id" : { "ts" : "2011-4" }, "value" : { "count" : 73 } }
{ "_id" : { "ts" : "2011-5" }, "value" : { "count" : 32 } }
```

If anyone knows of a library that does this kind of rollups, OLAP cubes or any other data transformation for reporting purposes with MongoDB/Mongoid, please speak up!
