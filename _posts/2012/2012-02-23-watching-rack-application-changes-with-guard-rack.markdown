---
layout: post
title: "Watching Rack Application Changes with Guard-Rack"
redirect_from: "/watching-rack-application-changes-with-guard-rack/"
date: 2012-02-23 16:29:49
tags: [rack, grape, rails, ruby, open source]
comments: true
dblog_post_id: 319
---
One of the frequently requested features in Grape to to automatically reload code changes, much like Rails does ([#131](https://github.com/intridea/grape/issues/131)). This is actually pretty difficult to implement and requires Grape support where an _API::reload!_ method would blow away all of the mounted features, procs, settings, etc.

For bare Rack-mounted applications we can make our life easy with Guard. Introducing [guard-rack](https://github.com/dblock/guard-rack), which will _rackup_ your Rack application on change. On a decent developer box this just takes a second or two.  The implementation is heavily inspired (aka stolen) from [guard-rails](https://github.com/guard/guard-rails).

For a typical Rack application, including one that uses Grape, add _guard_, _guard-bundler_ (to watch _Gemfile_ changes) and _guard-rack_ to Gemfile.

{% highlight ruby %}
group :development do
  gem "guard"
  gem "guard-bundler"
  gem "guard-rack"
end
{% endhighlight %}

Create a _Guardfile_. Watch the folders of your application.

{% highlight ruby %}
guard 'bundler' do
  watch('Gemfile')
end

guard 'rack' do
  watch('Gemfile.lock')
  watch(%r{^(config|app|api)/.\*})
end
{% endhighlight %}

Run with _bundle exec guard_. Watch _rackup_ happen every time you change files.

I’ve added this to my [grape-on-rack](https://github.com/dblock/grape-on-rack) demo.
