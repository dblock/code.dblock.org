---
layout: post
title: "Writing a New OpenWeatherMap.org API Ruby Client"
date: 2020-05-17
tags: [openweather, api, ruby]
comments: true
---
I have been writing Ruby clients for various services for a few years now using the same pattern described in [Writing a New Strava API Ruby Client](/2018/11/27/writing-a-new-strava-api-ruby-client.html). That itself was built on the experience of [slack-ruby-client](https://github.com/slack-ruby/slack-ruby-client) and [iex-ruby-client](https://github.com/dblock/iex-ruby-client).

A couple of weeks ago I took to [OpenWeatherMap.org](https://openweathermap.org/api)'s with [open-weather-ruby-client](https://github.com/dblock/open-weather-ruby-client). I'm now [using it](https://github.com/dblock/slack-strava/pull/88) in [Slava](https://slava.playplay.io) to fetch weather during a Strava activity.

{% highlight ruby %}
client = OpenWeather::Client.new(api_key: "...")

data = client.current_weather(city: 'London')
# => OpenWeather::Models::City::Weather
{% endhighlight %}

Returns basic weather information.

{% highlight ruby %}
data.name # => 'London'
data.dt # => Time
data.main.feels_like # => 277.73
data.main.humidity # => 81
data.main.pressure # => 1005
data.main.temp # => 283.15, degrees Kelvin
{% endhighlight %}

Has built-in temperature conversion.

{% highlight ruby %}
data.main.temp_c # => 10, degrees Celcius
data.main.temp_f # => 50.0, degrees Farenheit
{% endhighlight %}

And can return some weather history via the [OneCall API](https://openweathermap.org/api/one-call-api).

{% highlight ruby %}
data = client.one_call(
  lat: 33.441792,
  lon: -94.037689,
  dt: Time.now - 24 * 60 * 60
) # => OpenWeather::Models::OneCall::Weather

data.lat # => 33.44
data.lon # => -94.04
data.timezone # => 'America/Chicago'
data.current # => OpenWeather::Models::OneCall::CurrentWeather
data.hourly # => Array[OpenWeather::Models::OneCall::HourlyWeather]
{% endhighlight %}

### Links

* [open-weather-ruby-client](https://github.com/dblock/open-weather-ruby-client)
