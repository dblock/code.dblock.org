---
layout: post
title: "Grape API Mounted on RACK w/ Static Pages"
redirect_from: "/grape-api-mounted-on-rack-w-static-pages/"
date: 2012-01-30 15:54:46
tags: [rack, grape, ruby]
comments: true
dblog_post_id: 311
---
_tl;dr_ – the source is [here](https://github.com/dblock/grape-on-rack)

Here’s how I mount a [Grape](https://github.com/ruby-grape/grape) API on Rack and also serve static pages. Most useful for building a service with documentation.

Setup bundler with the required gems. I am using the next version of Grape (_frontier_ branch and the next version of _rack-contrib_ which contains _Rack::TryStatic _that we’re going to want to use).

{% highlight ruby %}
source "https://rubygems.org"

gem "rack", "1.3.5"
gem "rack-contrib", :git => "https://github.com/rack/rack-contrib.git", :require => "rack/contrib"
gem "grape", :git => "https://github.com/ruby-grape/grape.git", :branch => "frontier"
{% endhighlight %}

Static content goes to a new _public_ folder, for example _public/index.html_.

Our application will need to boot with all these gems, we’ll do it Rails-style by starting with a _config/boot.rb_ file. It brings in Bundler.

{% highlight ruby %}
require 'rubygems'
require 'bundler/setup'
{% endhighlight %}

Let's define our Acme Grape API that will have a _system_ resource that answers _ping_ requests with _"pong". _This_ _goes into _api/api.rb._

{% highlight ruby %}
module Acme
  class API < Grape::API
    version 'v1', :using => :header, :vendor => 'acme', :format => :json
    resource :system do
      desc "Returns pong."
      get :ping do
        "pong"
      end
    end
  end
end
{% endhighlight %}

The application requires Bundler, all the gems in Gemfile and our API. Let's define it in _config/application.rb_.

{% highlight ruby %}
require File.expand_path('../boot', __FILE__)

Bundler.require :default, ENV['RACK_ENV']

require File.expand_path('../../api/api', __FILE__)
{% endhighlight %}

Note the odd _File.expand_path_ construct, borrowed from Rails, - it translates a relative path to the current file into an absolute path, there’re allowing us to run the application from any directory – useful for hosting where you never know who boots the application.

Continuing to borrow from Rails, we will want different environments (development, production, etc.), so it’s a good idea to keep things organized. Setup the environment in _config/environment.rb _and then load the application.

{% highlight ruby %}
ENV['RACK_ENV'] ||= :test

require File.expand_path('../application', __FILE__)
{% endhighlight %}

Finally, we need to "rackup" this whole thing in _config.ru_. We will use _Rack::TryStatic_ to serve static pages when available and pass through to the Acme API otherwise.

{% highlight ruby %}
require File.expand_path('../config/environment', __FILE__)

use Rack::TryStatic,
  :root => File.expand_path('../public', __FILE__),
  :urls => %w[/], :try => ['.html', 'index.html', '/index.html']

run Acme::API
{% endhighlight %}

Run the application with _bundle exec rackup_.

![]({{ site.url }}/images/posts/2012/2012-01-30-grape-api-mounted-on-rack-w-static-pages/image_4.jpg)

Full [source on Github](https://github.com/dblock/grape-on-rack).
