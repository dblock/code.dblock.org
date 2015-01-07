---
layout: post
title: "Returning a Sample Set from a Mongo Collection w/ Mongoid"
redirect_from: "/returning-a-sample-set-from-a-mongo-collection-w-mongoid/"
date: 2012-07-15 00:11:51
tags: [mongoid, mongodb]
comments: true
dblog_post_id: 344
---

{% highlight ruby %}
module Mongoid
  class Criteria
    def sample(n = 1)
      indexes = (0..self.count-1).sort_by{ rand }.slice(0,n).collect!
      if n == 1
        return self.skip(indexes.first).first
      else
        return indexes.map{ |index| self.skip(index).first }
      end
    end
  end
end
{% endhighlight %}

> [https://gist.github.com/3113975](https://gist.github.com/3113975)

Can we do better?

