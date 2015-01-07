---
layout: post
title: "Grape Mounted behind Goliath"
redirect_from: "/grape-mounted-behind-goliath/"
date: 2013-10-20 14:02:10
tags: [performance, ruby]
comments: true
dblog_post_id: 399
---
Got a chance to play with [Goliath](http://postrank-labs.github.io/goliath/) for a bit. You don’t need to do much work to mount [Grape](https://github.com/intridea/grape) behind it. Grape figures out content-negotiation and formatting for you, so just stream the response through Goliath.

{% highlight ruby %}
module Acme
 class Ping < Grape::API
   format :json
   get '/ping' do
     { ping: "pong" }
   end
 end

 class App < Goliath::API
   use Goliath::Rack::Params
   use Goliath::Rack::Render

   def response(env)
     Acme::API.call(env)
   end
 end
end
{% endhighlight %}

Tests for something like this are a little bit tricky, because Goliath is fully asynchronous.

{% highlight ruby %}
describe Acme::API do
 it "ping" do
   with_api Acme::App do
     get_request(path: "/api/ping") do |async|
       async.response.should == { ping: "pong" }.to_json
     end
   end
 end
end
{% endhighlight %}

Working code in [https://github.com/dblock/grape-on-goliath](https://github.com/dblock/grape-on-goliath).

There’s also a very complete demo with asynchronous IO and PostgreSQL [here](https://github.com/djones/grape-goliath-example). Haven’t tried it, but looks very promising.
