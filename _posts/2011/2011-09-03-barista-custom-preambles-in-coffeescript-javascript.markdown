---
layout: post
title: "Barista: Custom Preambles in CoffeeScript => JavaScript"
redirect_from: "/barista-custom-preambles-in-coffeescript-javascript/"
date: 2011-09-03 11:44:13
tags: [barista, coffeescript, open source]
comments: true
dblog_post_id: 256
---
![]({{ site.url }}/images/posts/2011/2011-09-03-barista-custom-preambles-in-coffeescript-javascript/image_4.jpg)

You know I love coffee. My coffee is supported by Vibiemme hardware and [Barista software](https://github.com/Sutto/barista). We even have [interns writing coffee](/embedding-api-sandboxes-in-documentation). Yeah, take that corporate internship! How much coffee-script did _you_ write this summer?

One of the annoying things about Barista, the coffee-script compiler that we use with Rails, is that it adds a preamble with a full path to every generated file (something like _/home/dblock/bla/bla/bla.coffee_). This makes it difficult to force file generation and have those files committed into source control, since they change all the time. I’ve always wanted to make these paths relative, therefore creating the same file contents on different machines.

This will be supported in the next release of Barista, since [pull request #54](https://github.com/Sutto/barista/pull/54) got merged. You can have completely custom preambles, enabling you to make a path relative or to insert a license. Add the following to _config/initializers/barista_config.rb_.

{% highlight ruby %}
Barista.add_preamble do |location|
  "/\* : DO NOT MODIFY - compiled from #{Pathname.new(location).relative_path_from(Rails.root).to_s}\n\n"
end
{% endhighlight %}

My first implementation was a bit raw, but then I remembered that Ruby has this amazing thing called blocks. Let's say you have a method called _preamble_ that is currently a boolean. You can extend it to take an optional block by calling `block_given?`. Voila – now you can both say `preamble = true` and `preamble do ...` that passes some custom code that should get executed to generate a preamble. You can see the final code [here](https://github.com/Sutto/barista/pull/54/files#diff-0). IMO it’s very elegant, beautiful Ruby-magic that enables functions to do extra work when you ask politely.
