---
layout: post
title: "Wrapping Responses with Grape and Rack"
redirect_from: "/wrapping-responses-with-grape-and-rack/"
date: 2012-07-05 13:51:35
tags: [rack, grape, ruby]
comments: true
dblog_post_id: 343
---
[Grape](https://github.com/intridea/grape)’s after blocks don’t allow you to modify response text or status code [[#200](https://github.com/intridea/grape/issues/200)]. So how can you wrap an API response?

Define a Rack middleware and mount it in the API. Here’s an example of a decorator that wraps any body and resets the status code to 200.

{% highlight ruby %}
class ApiDecorator
    def initialize(app)
        @app = app
    end
    def call(env)
        status, headers, bodies = @app.call(env)
        bodies = bodies.map do |body|
            { :body => body, :status => status }
        end
        [200, headers, bodies]
    end
end

class MyApi < Grape::API
    use ApiDecorator
    get :ping do
        { :ping => "pong" }
    end
end
{% endhighlight %}

You can see a working sample with _API_v4_Decorator_ mounted in _API_v4_ in [https://github.com/dblock/grape-on-rack](https://github.com/dblock/grape-on-rack).

This works with all kinds of Rack applications, not just Grape.
