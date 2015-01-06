---
layout: post
title: "Paging and Iterating Over Large Mongo Collections"
redirect_from: "/paging-and-iterating-over-large-mongo-collections/"
date: 2012-03-28 13:23:09
tags: [mongoid, mongodb, ruby]
comments: true
---
Sometimes you need to iterate over a large MongoDB collection. The biggest issue is that, by default, cursors timeout after 10 minutes of inactivity. For very large collections it’s not uncommon to take longer than that to process results and you get an exception half way through the iteration. A cursor is a server-side construct, how about a client-side cursor?

Here’s a Mongo Ruby iterator that will call Mongo::Collection.find in increments.

```ruby
module Mongo
  class Collection
    def find_all(query = {}, by = 1000, &block)
      idx = 0
      while ((results = find(query, { :limit => by, :skip => idx })) && results.count(true) > 0)
        results.each do |result|
          yield result
          idx += 1
        end
      end
      self
    end
  end
end
```

And a Mongoid iterator built into Mongoid::Criteria.

```ruby
module Mongoid
  class Criteria
    def each_by(by = 1000, &block)
      idx = 0
      set_limit = options[:limit]
      while ((results = clone.limit(by).skip(idx)) && results.any?)
        results.each do |result|
          return self if set_limit and set_limit >= total
          yield result
          idx += 1
        end
      end
      self
    end
  end
end
```

Of course you must be careful that the collection doesn’t change during the iteration. If you add or remove an item before you, or will skip elements or process some elements twice.

