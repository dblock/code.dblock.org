---
layout: post
title: "Improving tags map/reduce with MongoDB 1.8.x"
redirect_from: "/improving-tags-mapreduce-with-mongodb-18x/"
date: 2011-05-12 13:52:44
tags: [mongodb, ruby, javascript]
dblog_post_id: 206
---
Today we'll improve [this map/reduce implementation](https://markembling.info/2010/11/using-map-reduce-in-a-mongodb-app) that produces a collection of tags with their counts. We'll add inline map/reduce for databases that support it, inline JavaScript and make fast incremental updates.

MongoDB 1.7.4 introduced inline results within map/reduce. It avoids creating a temporary collection and can be achieved by passing `{ :raw => true, :out => { :inline => 1 } }` within the map/reduce options. Since we'd like to support multiple versions of MongoDB, we'll inspire ourselves from some code in [mongoid_fulltext](https://github.com/artsy/mongoid_fulltext) and switch between map/reduce that supports inline results (MongoDB = 1.7.4) and one that doesn't (older versions of MongoDB).

<!-- # rubocop:disable Style/EmptyElse -- Both branches are illustrative placeholders. -->

```ruby
if collection.db.connection.server_version >= '1.7.4'
  # supports inline map/reduce
else
  # doesn't support inline map/reduce
end
```

<!-- # rubocop:enable Style/EmptyElse -->

Let's also learn to declare JavaScript functions inline. It's prettier than a string.

```ruby
map = <<-JAVASCRIPT
  function() {
    if (this.tags != null) {
      this.tags.forEach(function(t) {
        emit(t, 1);
      });
    }
  }
JAVASCRIPT

reduce = <<-JAVASCRIPT
  function(key, values) {
    var count = 0;
    values.forEach(function(v) { count += v; });
    return count;
  }
JAVASCRIPT
```

The `map` function emits a count for each tag and the reduce function sums the counts up.

To make the tags update incremental, let's collect all the tags upfront into a hash (it's a tradeoff which consumes more memory, but avoids a lengthy cursor that can potentially lead to a sever timeout with very large collections). The following code transforms the array of Tag instances into a hash with the tag name as key.

```ruby
tags_before = Hash[*Tag.all.collect do |tag|
  [tag.name, tag]
end.flatten]
```

The incremental update takes care of creating new tags or updating counts.

```ruby
tag = tags_before[name]
if tag
  tag_mapreduce_count = tag_mapreduce['value'].to_i
  tag.update_attribute(:count, tag_mapreduce_count) if tag_mapreduce_count != tag.count
else
  Tag.create!(name: name, count: tag_mapreduce['value'].to_i)
end
```

We'll also have to remember to delete tags that no longer exist.

```ruby
(tags_before.values - tags_after).each(&:delete)
```

Full implementation [here](https://gist.github.com/968519). Copy/paste and rename _TaggedModel_ to your model that contains tags. Maybe time to make a library out of this?

## Update (2015)

Check out the [mongoid-tag-collectible](https://github.com/dblock/mongoid-tag-collectible) gem.
