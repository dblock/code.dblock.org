---
layout: post
title: "Writing a New Strava API Ruby Client"
date: 2018-11-27
tags: [strava, api, ruby]
comments: true
---
Despite an existing Swagger-compatible API, most of Strava interactions written in Ruby don't use any auto-generated code and prefer [strava-api-v3](https://github.com/jaredholdcroft/strava-api-v3), a thin client that covers the majority of the Strava API. This is a much cleaner than any swagger-generated mess, but only comes with bare minimum extras. For example, the client can retrieve an activity, but does not have any code to convert a distance from meters to miles or calculate an athlete's pace. It will also leave you having to refer to the Strava documentation on whether `distance` is in meters, yards or feet.

That seems reasonable for a thin client, but I've already had to copy-paste a ton of code between [publishing my runs to github pages](/2018/02/17/auto-publishing-strava-runs-to-github-pages.html) and my [Strava Slack bot](https://code.dblock.org/2018/04/03/slava-slack-bot-for-strava.html). I considered adding that code to the strava-api-v3 client, but found its implementation gross enough to write a brand new one.

Introducing [strava-ruby-client](https://github.com/dblock/strava-ruby-client).

Unlike strava-api-v3 provides complete OAuth refresh token flow support, a richer first class interface to Strava models, natively supports pagination and implements more consistent error handling.

The rest of this post is about implementation details.

This is not my first API client rodeo, following the very popular [slack-ruby-client](https://github.com/slack-ruby/slack-ruby-client) and a newer [iex-ruby-client](https://github.com/dblock/iex-ruby-client), so you can be sure I integrated many of the lessons learned into this work. If you're building a Ruby client for an API, I strongly encourage you to reuse this as a boilerplate.

### Basics

I always start with a [README.md](https://github.com/dblock/strava-ruby-client/blob/master/README.md), [LICENSE.md](https://github.com/dblock/strava-ruby-client/blob/master/LICENSE.md), [CONTRIBUTING.md](https://github.com/dblock/strava-ruby-client/blob/master/CONTRIBUTING.md), [CHANGELOG.md](https://github.com/dblock/strava-ruby-client/blob/master/CHANGELOG.md) and [RELEASING.md](https://github.com/dblock/strava-ruby-client/blob/master/RELEASING.md). Future updates will include [UPGRADING.md](https://github.com/slack-ruby/slack-ruby-client/blob/master/UPGRADING.md).

### Version

This is very straightforward, but many API clients don't even include a version, much less announce themselves to servers properly.

{% highlight ruby %}
module Api
  VERSION = '0.1.0'.freeze
end
{% endhighlight %}

We are going to use this in the API's user agent.

{% highlight ruby %}
self.user_agent = "Client/#{Api::VERSION}"
{% endhighlight %}

And make sure we have a test.

{% highlight ruby %}
require 'spec_helper'

RSpec.describe Client do
  before do
    Config.reset
  end
  context 'with defaults' do
    let(:client) { Client.new }
    it 'sets user-agent' do
      expect(client.user_agent).to eq Config.user_agent
      expect(client.user_agent).to include Api::VERSION
    end
  end
end
{% endhighlight %}

### Configuration

API clients tend to want to be configurable globally or directly in a client instance. This is a pretty interesting pattern with the following configuration class.

{% highlight ruby %}
module Api
  module Config
    extend self

    ATTRIBUTES = %i[
      endpoint
      access_token
      logger
      proxy
      timeout
    ].freeze

    attr_accessor(*Config::ATTRIBUTES)

    def reset
      self.endpoint = 'https://example.com/api'
      self.access_token = nil
      self.logger = Api::Logger.instance
      self.proxy = nil
      self.timeout = 30
    end
  end

  class << self
    def configure
      block_given? ? yield(Config) : Config
    end

    def config
      Config
    end
  end
end

Api::Config.reset
{% endhighlight %}

Note that this pattern can be extended deeper, and the configuration can be further nested, as in [iex-ruby-client#88](https://github.com/dblock/iex-ruby-client/pull/88).

The client itself.

{% highlight ruby %}
module Api
  class Client < Strava::Web::Client
    attr_accessor(*Config::ATTRIBUTES)

    def initialize(options = {})
      Config::ATTRIBUTES.each do |key|
        send("#{key}=", options[key] || Api.config.send(key))
      end
    end
  end

  class << self
    def configure
      block_given? ? yield(Config) : Config
    end

    def config
      Config
    end
  end
end
{% endhighlight %}

What does this do? It allows global configuration.

{% highlight ruby %}
Api::Client.configure do |config|
  config.access_token = 'token'
  config.logger = ::Logger.new(STDOUT)
end
{% endhighlight %}

And allows local configuration that overrides global configuration.

{% highlight ruby %}
client = Api::Client.new(access_token: 'token')
{% endhighlight %}

### HTTP

For HTTP clients I prefer to use [Faraday](https://github.com/lostisland/faraday), which allows clients to compose modules in a single pipeline, including `Faraday::FlatParamsEncoder` to convert input arguments into the HTTP GET query string, `FaradayMiddleware::ParseJson` to parse JSON in response or `Faraday::Response::RaiseError` to raise exceptions on HTTP errors. This also allows the caller to swap the HTTP engine in the future, often desired in complex applications that want fewer ways to HTTP.

I breakup the code into [`Web::Connection`](https://github.com/dblock/strava-ruby-client/blob/master/lib/strava/web/connection.rb) and [`Web::Request`](https://github.com/dblock/strava-ruby-client/blob/master/lib/strava/web/request.rb), easily gaining global configuration for the much needed `proxy` or `timeout` options.

These are mixed into the client class and reuse options from `Config::ATTRIBUTES`.

{% highlight ruby %}
class Api
  class Client
    include Web::Connection
    include Web::Request
  end
end
{% endhighlight %}

### Models

JSON API responses are parsed by Faraday into a `Hash`, but I prefer first-class objects that can be extended. I like [`Hashie::Trash`](https://github.com/intridea/hashie#trash), despite being [demoniacally possessed](/2017/02/24/the-demonic-possession-of-hashie-mash.html).

{% highlight ruby %}
class Model < Hashie::Trash
  include Hashie::Extensions::IgnoreUndeclared

  property 'id'
  property 'created_at', transform_with: ->(v) { Time.parse(v) }
  property 'widget', transform_with: ->(v) { Models::Widget.new(v) }
  property 'gadgets', transform_with: ->(v) { v.map { |r| Models::Gadget.new(r) } }
end
{% endhighlight %}

This allows for first class, strongly typed instance properties and for future extensibility if the API adds fields or a stronger contract with `Hashie::Extensions::IgnoreUndeclared` deleted.

You can also easily extend the class with additional methods.

{% highlight ruby %}
class Activity < Hashie::Trash
  property 'type'

  def type_emoji
    case type
    when 'Run' then '🏃'
    when 'Ride' then '🚴'
  end
end
{% endhighlight %}

### API Calls

A basic API `GET` call.

{% highlight ruby %}
#
# Get current user.
#
def current_user(options = {})
  Models::User.new(get('current_user', options))
end
{% endhighlight %}

Something with parameters. I choose to use an extensible `Hash` of `options`, but YMMV.

{% highlight ruby %}
#
# Get user by id.
#
# @option options [String] :id
#   User id.
#
def user(options = {})
  throw ArgumentError.new('Required argument :id missing') if options[:id].nil?
  Models::User.new(get("users/#{options[:id]}", options.except(:id)))
end
{% endhighlight %}

A collection of objects.

{% highlight ruby %}
#
# Get users.
#
def users(options = {})
  get('users', options).map do |row|
    Models::User.new(row)
  end
end
{% endhighlight %}

### Pagination

Clients should help with pagination. I typically roll out a cursor and wrap all collection API calls into it, enabling developers to automatically paginate through results by supplying a block. This can be seen in [strava-ruby-client@40f2a0fd](https://github.com/dblock/strava-ruby-client/commit/40f2a0fd25d9ed0c19204c56f4308a186f1ee5f9).

### Famous Last Words

Writing clients is fun. If you are stuck with a crappy client with poor error handling or data modeling, roll your own based on [strava-ruby-client](https://github.com/dblock/strava-ruby-client) in less than a day's worth of work.
