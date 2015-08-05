---
layout: post
title: "Modularizing a RoR Grape API: Multiple Versions"
redirect_from: "/modularizing-a-ror-grape-api-multiple-versions/"
date: 2011-07-30 06:12:01
tags: [grape, rails, ruby]
comments: true
dblog_post_id: 239
---
We made some progress with modularizing our Grape API in the [last post](/modularizing-a-ror-grape-api). But we only had one version and declared _Api_v1_ as our main API entry. Unless you’re Netflix and need an API per device family (I know, [wow!](http://blog.programmableweb.com/2011/07/28/redesigning-the-netflix-api-no-versions-many-endpoints/), 18’000 different devices use the Netflix API), you might want to make a Grape API with two versions.

We’ll start by declaring an API class the way we would like to see it.

{% highlight ruby %}
class Api < Grape::API
  prefix 'api'
  rescue_from :all, :backtrace => true
  error_format :json
  include Api_v1
  include Api_v2
end
{% endhighlight %}

This API is routable in _config/routes.rb_.

{% highlight ruby %}
match '/api/v1/\*other' => Api
match '/api/v2/\*other' => Api
{% endhighlight %}

What does _Api_v1_ or _Api_v2_ look like? It’s  a little tricky. We need to include api modules into the parent Grape API, like this.

{% highlight ruby %}
module Api_v1
  def self.included(api)
    api.version 'v1'
    api.include Api_v1_Me
    ...
  end
end
{% endhighlight %}

Unfortunately _Module::include_ is private. Let’s expose it as _module_ by extending the _Api_ class with the methods of _ApiModule::ClassMethods_. I personally find this _included / extend_ pair particularly elegant.

{% highlight ruby %}
module ApiModule
  module ClassMethods
    def module(mod)
      include mod
    end
  end
  def self.included(api)
    api.extend ClassMethods
  end
end

class Api < Grape::API
  include ApiModule
  prefix 'api'
  ...
end
{% endhighlight %}

The Api_v1 will use _module_ instead of _include_.

{% highlight ruby %}
module Api_v1
  def self.included(api)
    api.version 'v1'
    api.module Api_v1_Me
  end
end
{% endhighlight %}

Don’t forget to write some tests. I’ve made [a pull request](https://github.com/ruby-grape/grape/pull/48) into Grape exposing API _versions_ and _routes_, so I can actually write a test now that makes sure we have both versions of the API properly loaded. This goes into _spec/requests/api_spec.rb_.

{% highlight ruby %}
require 'spec_helper'

describe Api do
  describe "version" do
    it "includes version 1 and 2" do
      Api::versions.should == ['v1', 'v2']
    end
  end
end
{% endhighlight %}
