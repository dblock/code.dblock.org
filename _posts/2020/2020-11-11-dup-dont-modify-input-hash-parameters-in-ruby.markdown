---
layout: post
title: "Dup, Don't Modify Input Hash Parameters in Ruby"
date: 2020-11-11
tags: [ruby]
comments: true
---
We often write Ruby functions that take an `options` Hash, remove some of its values, then pass the hash further down. Unfortunately we also often [introduce a very difficult to catch bug](https://github.com/dblock/iex-ruby-client/pull/94#discussion_r520637150). Here's why you always want to `dup` input options in Ruby that come in as a Hash.

Consider the following example from [iex-ruby-client](https://github.com/dblock/iex-ruby-client). We pluck `range` out of `options` to use in an HTTP request path, then pass the rest of the options as query string parameters. We want to `.delete` the `range` key to avoid passing its value further down because the API does not expect it, and could have all kinds of unfortunate side-effects. We also don't know all the possible arguments to the API, especially not the future ones, as we want to be forward-compatible.

{% highlight ruby %}
def historical_prices(symbol, options = {})
  path = "stock/#{symbol}/chart"
  path += "/#{options[:range]}" if options.key?(:range)
  options.delete(:range)
  get(path, options)
end
{% endhighlight %}

Seems innocent enough. But consider this code.

{% highlight ruby %}
options = { range: 'year' }
msft_prices = historical_prices('MSFT', options)
goog_prices = historical_prices('GOOG', options)
{% endhighlight %}

You can see the problem: the second call to `historical_prices` has incorrect options as `range` was removed by the first call. Here's a fix.

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

Lastly, both `.dup` and `.clone` are both shallow, but that doesn't matter as long as you only use `.delete` and remove values. If you were to modify the `options` Hash in any other way, you may need to [deep_dup](https://apidock.com/rails/Hash/deep_dup) it instead. So, don't modify an object that your method doesn't own and remember that Ruby passes objects such as `Hash` or `Array` by reference, and not by value into functions.

All that said, if you know the finite list of parameters to your functions, use [Ruby 2 Keyword Arguments](https://thoughtbot.com/blog/ruby-2-keyword-arguments) instead.
