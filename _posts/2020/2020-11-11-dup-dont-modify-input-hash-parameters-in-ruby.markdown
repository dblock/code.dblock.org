---
layout: post
title: "Dup, Don't Modify Input Hash Parameters in Ruby"
date: 2020-11-11
tags: [ruby]
comments: true
---
This comes up [all the time](https://github.com/dblock/iex-ruby-client/pull/94#discussion_r520637150). Here's why you always want to `dup` input options in Ruby that come in as a Hash.

{% highlight ruby %}
def historical_prices(symbol, options = {})
  path = "stock/#{symbol}/chart"
  path += "/#{options[:range]}" if options.key?(:range)
  options.delete(:range)
  get(path, options)
end
{% endhighlight %}

Seems innocent enough. But consider the following.

{% highlight ruby %}
options = { range: 'year' }
msft_prices = historical_prices('MSFT', options)
goog_prices = historical_prices('GOOG', options)
{% endhighlight %}

You can see the problem: the second call to `historical_prices` has incorrect options. Here's a fix.

{% highlight ruby %}
def historical_prices(symbol, options = {})
  options = options.dup
  path = "stock/#{symbol}/chart"
  path += "/#{options[:range]}" if options.key?(:range)
  options.delete(:range)
  get(path, options)
end
{% endhighlight %}

You can optimize a little to avoid `.dup` in all cases, but I don't think it's worth it because it does not provide any meaningful performance improvement unless the function gets called a lot.

{% highlight ruby %}
def historical_prices(symbol, options = {})
  path = "stock/#{symbol}/chart"
  if options.key?(:range)
    options = options.dup
    path += "/#{options[:range]}"
    options.delete(:range)
  end
  get(path, options)
end
{% endhighlight %}

If you use Rails, you can use `except`. I like how clean this is.

{% highlight ruby %}
def historical_prices(symbol, options = {})
  path = "stock/#{symbol}/chart"
  path += "/#{options[:range]}" if options.key?(:range)
  get(path, options.except(:range))
end
{% endhighlight %}

All that said, if you know the finite list of parameters to your functions, use [Ruby 2 Keyword Arguments](https://thoughtbot.com/blog/ruby-2-keyword-arguments) instead.
