---
layout: post
title: "Grape: trapping all exceptions within the API"
redirect_from: "/grape-trapping-all-exceptions-within-the-api"
date: 2011-05-04 03:33:39
tags: [rails, ruby]
comments: true
---
We’ve been using [Grape](https://github.com/intridea/grape) to provide a RESTful API. Grape is a micro-framework for Ruby that makes it really easy.

I’ve recently had to deal with code that raises exceptions in a bunch of unpredictable places. This causes Rails to produce an HTML error page, including when making JSON API calls. We want to have some control of this and wrap all calls to return an error message or maybe even a JSON error message. To do so we’ll write the following exception handler. It traps all exceptions in a _rescue_ block and re-throws a specific _:error_ that Grape expects.

```ruby
# trap all exceptions and fail gracefuly with a 500 and a proper message
class ApiErrorHandler < Grape::Middleware::Base
  def call!(env)
    @env = env
    begin
      @app.call(@env)
    rescue Exception => e
      throw :error, :message => e.message || options[:default_message], :status => 500
    end
  end  
end
```

This can be injected into the middleware stack, a construct I find quite elegant.

```ruby
require 'api_error_handler'
 
class Api_v1 < Grape::API
  prefix 'api'
  version 'v1'
  
  use ApiErrorHandler
  
  ...
end
```

To be good citizens we’ll write an RSpec test, heavily inspired by Grape’s specs.

```ruby
require 'spec_helper'
 
describe "ApiErrorHandler" do
 
  subject { Class.new(Grape::API) }  
  def app; subject end
  
  describe "error" do
  
    before do
      subject.prefix 'api'
      subject.use ApiErrorHandler
      subject.get :error do
        raise "api error"
      end
      subject.get :hello do
        { hello: "world" }
      end
    end
 
    it "should return world when asked hello" do    
      get '/api/hello'
      JSON.parse(response.body).should == { "hello" => "world" }
      response.status.should == 200
    end
    
    it "should return a 500 when an exception is raised" do    
      get '/api/error'
      response.status.should == 500
      response.body.should == "api error"
    end
    
  end
end
```

I couldn’t figure out how to wrap it up to return JSON, I keep having to raise an _:error_ to abort all subsequent middleware processors. Maybe someone can suggest a solution or a better approach altogether?


