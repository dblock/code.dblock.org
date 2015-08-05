---
layout: post
title: "Grape: Routing Multiple Methods"
redirect_from: "/grape-routing-multiple-methods/"
date: 2011-11-03 13:36:26
tags: [grape, rails, ruby]
comments: true
dblog_post_id: 286
---
Sometimes you want to support both GET and POST in a [Grape API](http://github.com/ruby-grape/grape).

If you want to support GET you would write something like `get [path] do`. If you want to support POST you would write `post [path] do`. What are those _get_ and _post_ methods anyway? The answer is in Grape’s [api.rb](https://github.com/ruby-grape/grape/blob/master/lib/grape/api.rb).

{% highlight ruby %}
def get(paths = ['/'], options = {}, &block); route('GET', paths, options, &block) end
def post(paths = ['/'], options = {}, &block); route('POST', paths, options, &block) end
def put(paths = ['/'], options = {}, &block); route('PUT', paths, options, &block) end
def head(paths = ['/'], options = {}, &block); route('HEAD', paths, options, &block) end
def delete(paths = ['/'], options = {}, &block); route('DELETE', paths, options, &block) end
{% endhighlight %}

These call route, which starts as follows.

{% highlight ruby %}
def route(methods, paths = ['/'], route_options = {}, &block)
  methods = Array(methods)
  ...
end
{% endhighlight %}

The Array construct will take anything and make it into an array, unless it’s already one. Which means that we can pass an array of methods to _route_. This is definitely part of Ruby magic, a C# or Java developer would strangle you for accepting _object_ as a parameter and then transforming it into _[object] _– but this is completely kosher in Ruby. But I digress, in order to route multiple methods for a single API we can invoke _route_ directly instead of _get_ or _post_.

{% highlight ruby %}
route ['GET', 'POST'], "foo/bar" do
  # API code goes here
end
{% endhighlight %}
