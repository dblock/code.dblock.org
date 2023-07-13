---
layout: post
title: "Grape vs. Poncho"
redirect_from: "/grape-vs-poncho/"
date: 2013-04-06 13:19:37
tags: [grape, ruby]
comments: true
dblog_post_id: 381
---
There’re a number of excellent micro-frameworks to author RESTful APIs in Ruby. Let’s take a look at the newcomer, [Poncho](https://github.com/stripe/poncho), from the Stripe team, [brought up](https://groups.google.com/forum/?fromgroups=#!topic/ruby-grape/4oEnuDA9e-8) on the Grape mailing list. For those that don’t know me, I’m the maintainer of [Grape](https://github.com/ruby-grape/grape) and use it very heavily at [Artsy](https://artsy.net/). I’ll do my best not to be biased.

With Poncho you start by declaring resources that inherit from _Poncho::Resource_. A resource is a prescriptive way of declaring what parameters to expect and what results to render from the API. In many ways resources are similar to [Grape’s entities](https://github.com/ruby-grape/grape-entity), except that the latter are no longer part of Grape and you can use [roar](https://github.com/apotonick/roar), [rabl](https://github.com/nesquena/rabl) or any other framework to render results - you choose. Poncho resources include parameter validation, which makes sense. Personally, language matters, so I would not call values that can be assigned to the resource _parameters_, but maybe _fields_ or _attributes_.

You then declare a _Poncho::JSONMethod_, which inherits from _Poncho::Method_, which is a piece of middleware. The former is equivalent to a Grape formatter, and the latter is equivalent to the Grape endpoint Rack middleware. You have to override the _invoke_ method and implement your business logic.

How does all this come together?

{% highlight ruby %}
# poncho
get "/users", & UsersListMethod
{% endhighlight %}

{% highlight ruby %}
# grape
get "/users" do
   ...
end
{% endhighlight %}

Grape could easily support the Poncho syntax with a few lines of code. Internally it creates a Proc from the body of the block.

I think that Poncho is in the very early days of development and has made some choices that Grape already made a year or two ago and decided undo more recently. Poncho hasn’t dealt with more complicated problems like versioning or content-negotiation, yet. Once it does, poncho contributors will find that infrastructure begins to bloat and will likely split it the same way we split grape and grape-entity. My current view is that the API DSL layer should be providing functionality closer to the HTTP protocol and a separate entities-like library should deal with data representation. That’s because I have strong opinions that a modern API should be a Hypermedia one, but I would not want to impose this on anyone, which is incidentally a similar philosophy that lead to  Webmachine (check out my earlier [Grape vs. Webmachine](https://code.dblock.org/grape-vs-webmachine) post).

That said, none of the above is difficult to accomplish.

I would certainly have preferred if Stripe chose Grape as the API DSL and implemented their style of data presenters if they felt strongly about that. But we all want our own micro frameworks, don’t we?
