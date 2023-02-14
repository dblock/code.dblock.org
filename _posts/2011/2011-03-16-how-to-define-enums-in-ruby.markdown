---
layout: post
title: "How to define Enums in Ruby?"
redirect_from: "/how-to-define-enums-in-ruby/"
date: 2011-03-16 21:39:46
tags: [ruby]
comments: true
dblog_post_id: 184
---
This is going to heavily quote [http://www.rubyfleebie.com/enumerations-and-ruby/](http://www.rubyfleebie.com/enumerations-and-ruby/),  please read that first. The proposed implementation lets you iterate over enumerated values, which is quite awesome. But it offers little in terms of reuse. Let's improve upon it and split the methods in a way that lets us include an Enum implementation with all its class methods along the way. Full Enum.rb at the end.

{% highlight ruby %}
module Enum

  ... instance methods ...

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    ... class methods ...
  end
end
{% endhighlight %}

The trick here is that when a class includes a module the module self.included method is invoked. The base parameter is the class object for the class that includes the module, so we can extend it with the _ClassMethods _implementation. Magical.

To define an order state enumeration we can now write the following.

{% highlight ruby %}
class OrderState
  include Ruby::Enum

  define :CREATED, 'created'
  define :PAID, 'paid'
end
{% endhighlight %}

You can call `OrderState.all` and `OrderState::CREATED`.

#### What’s next?

I want to be able to write `define :CREATED = "CREATED"` inside `OrderState` class and I want to prevent instances of `OrderState` outside of within `Enum`. First one to accomplish both gets a beer.

#### Full Enum.rb

{% highlight ruby %}
module Enum
  def initialize(key, value)
    @key = key
    @value = value
  end

  def key
    @key
  end

  def value
    @value
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def define(key, value)
      @hash ||= {}
      @hash[key] = self.new(key, value)
    end

    def const_missing(key)
      @hash[key].value
    end

    def each
      @hash.each do |key, value|
        yield key, value
      end
    end

    def all
      @hash.values
    end

    def all_to_hash
      hash = {}
      each do |key, value|
        hash[key] = value.value
      end
      hash
    end
  end
end
{% endhighlight %}

#### Update (2015)

Check out [the ruby-enum gem](https://github.com/dblock/ruby-enum).

#### Update (2023)

The [ruby-enum gem](https://github.com/dblock/ruby-enum) is used by 1M+ projects 🙈🙉.

![]({{ site.url }}/images/posts/2011/2011-03-16-how-to-define-enums-in-ruby/usage.png)
