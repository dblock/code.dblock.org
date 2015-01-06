---
layout: post
title: "IE9: Cache-Busting with Grape Middleware"
redirect_from: "/ie9-cache-busting-with-grape-middleware"
date: 2011-09-14 03:45:08
tags: [grape, rails, ruby]
comments: true
---
Ran into a series of weird bugs with IE9. Turned out that a lot of our API requests were cached on the client. I am not sure whether this is some clever plot to make things work faster, but it was rather puzzling. Nothing in our API headers indicated that the data can be cached for any duration, but nothing indicated otherwise either. Generally I’d like IE to work more like other browsers these days, not the other way around.

It was pretty easy to add a set of no-cache headers with [Grape](https://github.com/intridea/grape) Middleware.

```ruby
class ApiCacheBuster < Grape::Middleware::Base
  def after
    @app_response[1]["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    @app_response[1]["Pragma"] = "no-cache"
    @app_response[1]["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    @app_response
  end
end

class Api < Grape::API
  use ApiCacheBuster
  ...
end
```

And, trying to get muscle memory for good habits, a test.

```ruby
require 'spec_helper'

describe ApiCacheBuster do
  it "sets cache headers" do
    get "/api/v1/ping"
    response.body.should == "pong".to_json
    response.headers["Cache-Control"].should == "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"].should == "no-cache"
    response.headers["Expires"].should == "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
```

The headers are inspired from [this StackOverflow article](http://stackoverflow.com/questions/711418/how-to-prevent-browser-page-caching-in-rails), which shows how to do it with plain Rails controllers.
