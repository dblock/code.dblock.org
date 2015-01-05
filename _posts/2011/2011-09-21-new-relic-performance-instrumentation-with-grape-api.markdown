---
layout: post
title: "New Relic: Performance Instrumentation with Grape API"
redirect_from: "/new-relic-performance-instrumentation-with-grape-api"
date: 2011-09-21 22:05:40
tags: [performance, grape, rails, ruby]
comments: true
---
We’re using [Grape](https://github.com/intridea/grape) in our Rails app on Heroku, which comes with New Relic instrumentation out-of-the-box. Let's get the Grape API route details to show in New Relic as well.

#### Gemfile

Add the [newrelic_rpm](https://github.com/newrelic/rpm) gem to Gemfile. It will give us a start with Grape Middleware.

```ruby
group :production do
  gem "newrelic_rpm", "3.1.2"
end
```
#### Rack Up

Grape is a Rack-based system. If we wanted to display a bulk metric for Rack middleware, we could simply extend our API model as follows.

```ruby
class Api < Grape::API
  ...
  if Rails.env.production?
    extend NewRelic::Agent::Instrumentation::Rack
  end
end
```

I use New Relic in production only, hence the _if_ block. But this is not good enough for us – this would show a single API entry for all calls.

#### API Instrumentation

Examining the source code for NewRelic’s Rack module, we can make a few small changes and show the API path itself. Copy-paste the code from my [config/initializers/new_relic_agent_instrumentation_api.rb](https://gist.github.com/1233422), importing it with `extend NewRelic::Agent::Instrumentation::API` in the API class. All it does is figure out a better name for New Relic to record – in this case the API path without forward slashes and an appended lowercase method after the #.

#### New Relic Screenshots

A breakdown per API. We got _api/v1/search _and _api/v1/me._

![image]({{ site.url }}/images/posts/2011/2011-09-21-new-relic-performance-instrumentation-with-grape-api/image%5b31%5d.jpg)

Drilling through the top entry we can see the performance breakdown (including the MongoDB instrumentation that comes from the [rpm_contrib gem](https://github.com/newrelic/rpm_contrib)).

![image]({{ site.url }}/images/posts/2011/2011-09-21-new-relic-performance-instrumentation-with-grape-api/image%5b21%5d.jpg)
