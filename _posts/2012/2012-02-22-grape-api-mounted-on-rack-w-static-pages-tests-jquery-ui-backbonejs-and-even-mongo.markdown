---
layout: post
title: "Grape API Mounted on RACK w/ Static Pages, Tests, JQuery UI, Backbone.js and Even Mongo"
redirect_from: "/grape-api-mounted-on-rack-w-static-pages-tests-jquery-ui-backbonejs-and-even-mongo/"
date: 2012-02-22 14:19:57
tags: [rack, mongoid, jquery, javascript, grape]
comments: true
dblog_post_id: 318
---
Expanding from my [previous post](http://code.dblock.org/grape-api-mounted-on-rack-w-static-pages) on a Grape API mounted on RACK.

#### Refactoring the Application Instance

Instead of sticking all of the Rack application code into _config.ru_, lets build a cleaner _Acme::App _(in [app/acme_app.rb](https://github.com/dblock/grape-on-rack/blob/master/app/acme_app.rb)). We’re going to drop _Rack::TryStatic_ and build this logic ourselves, since we might need to deal with other error codes than 404 (depending on your URL strategy you may be tripping over a 405). The logic remains the same: we try a bunch of static files and delegate to the API otherwise. You can also build primitive routing instead, so that everything requesting _/api_ goes to the API and everything else goes to _Rack::Static_. Your mileage will vary.

{% highlight ruby %}
module Acme
  class App
    def initialize
      @filenames = ['', '.html', 'index.html', '/index.html']
      @rack_static = ::Rack::Static.new(
        lambda { [404, {}, []] }, {
          :root => File.expand_path('../../public', __FILE__),
          :urls => %w[/]
        })
    end

    def call(env)
      request_path = env['PATH_INFO']
      # static files
      @filenames.each do |path|
        response = @rack_static.call(env.merge({'PATH_INFO' => request_path + path}))
        return response if response[0] != 404
      end
      # api
      Acme::API.call(env)
    end
  end
end
{% endhighlight %}

#### RSpec API Tests

Now that we have an application class, we can add API and Capybara integration tests. We start with RSpec and Rack test gems in _Gemfile_.

{% highlight ruby %}
group :test do
  gem "rspec"
  gem "rack-test"
  gem "rspec-core"
  gem "rspec-expectations"
  gem "rspec-mocks"
end
{% endhighlight %}

The _spec/spec_helper.rb_ adds Rack::Test.

{% highlight ruby %}
require 'rubygems'

ENV["RACK_ENV"] ||= 'test'

require 'rack/test'
require File.expand_path("../../config/environment", __FILE__)

RSpec.configure do |config|
  config.mock_with :rspec
  config.expect_with :rspec
end
{% endhighlight %}

Testing an API involves making requests on the Rack application, pretty straightforward.

{% highlight ruby %}
require 'spec_helper'

describe Acme::API do
  include Rack::Test::Methods

  def app
    Acme::API
  end

  context "v1" do
    context "system" do
      it "ping" do
        get "/api/v1/system/ping"
        last_response.body.should == { :ping => "pong" }.to_json
      end
    end
  end
end
{% endhighlight %}

#### RSpec Capybara Integration Tests

Notice that in the tests above we’re mounting the Rack application and making requests directly to it. Does it actually work in a browser? Do we see the _public/index.html_ page?

We start by adding capybara into Gemfile. At the time of the writing we need to use the code from Capybara head, since it adds support for _Capybara.app_.

{% highlight ruby %}
group :test do
  gem "capybara", :git => "https://github.com/jnicklas/capybara.git"
end
{% endhighlight %}

The _spec/spec_helper.rb_ requires _capybara/rspec_, which brings in methods like _page.visit_ and assigns an instance of the application to _Capybara.app_. Capybara will launch the application for us.

{% highlight ruby %}
require 'capybara/rspec'

Capybara.configure do |config|
  config.app = Acme::App.new
end
{% endhighlight %}

An integration test can go into _spec/integration_ and must be marked with _request: true _and _js: true_ (the latter forces the use of the Selenium driver that will popup a browser). Let's look for a proper title on the homepage.

{% highlight ruby %}
require 'spec_helper'

describe "Grape on RACK", :js => true, :type => :request do
  context "homepage" do
    before :each do
      visit "/"
    end
    it "displays index.html page" do
      page.find("title").text.should == "Rack Powers Web APIs"
    end
  end
end
{% endhighlight %}

#### A POST, PUT and Some JQuery

The sample source in [https://github.com/dblock/grape-on-rack](https://github.com/dblock/grape-on-rack) also adds JQuery, extends the API to simulate a persisted counter, and makes PUT requests to it. Complete with an integration test. Run _bundle install_ and _bundle exec rackup _to see it and _bundle exec rspec spec_ to run the tests.

#### Backbone.js w/ Mongo

[@knewter](https://github.com/knewter) put together a neat Backbone.js + MongoDB w/ Mongoid demo using Grape that is built in a similar manner, [https://github.com/knewter/grape_demo](https://github.com/knewter/grape_demo).
