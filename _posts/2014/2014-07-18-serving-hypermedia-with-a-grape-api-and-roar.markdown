---
layout: post
title: "Serving Hypermedia with a Grape API and Roar"
redirect_from: "/serving-hypermedia-with-a-grape-api-and-roar/"
date: 2014-07-18 22:06:06
tags: [apis, grape]
comments: true
dblog_post_id: 418
---
I’ve begun experimenting with Hypermedia APIs a bit more seriously, trying to come up with a good infrastructure for the next version of the [Artsy](https://artsy.net) API. It might even be a public one, but I am not making any promises right now. I’ve played with serialization and attempted to use ActiveModel::Serializers with the [grape-activemodel_serializers](https://github.com/jrhe/grape-active_model_serializers) gem and HAL with [Roar](https://github.com/apotonick/roar). It turned out that we do need a little bit of help with Roar, so I released a new gem called [grape-roar](https://github.com/dblock/grape-roar), which enables using Grape’s _present_ keyword.

Check out an example application deployed at grape-with-roar.herokuapp.com, source code in [https://github.com/dblock/grape-with-roar](https://github.com/dblock/grape-with-roar).

First, swap the JSON formatter for _Grape::Formatter::Roar_. It’s implementation is almost identical to the default JSON formatter, except that it passes _env_ along to the _to_json_ call.

{% highlight ruby %}
module Acme
  module Api
    class RootEndpoint < Grape::API
      prefix 'api'
      format :json
      formatter :json, Grape::Formatter::Roar
    end
  end
end
{% endhighlight %}

Implement a presenter. It will typically have a number of _:properties_. Include _Grape::Roar::Representer_ to use _present _in your API.

{% highlight ruby %}
module Acme
  module Api
    module Presenters
      module SplinePresenter
        include Roar::Representer::JSON::HAL
        include Roar::Representer::Feature::Hypermedia
        include Grape::Roar::Representer

        property :uuid
        property :reticulated

        link :self do |opts|
          request = Grape::Request.new(opts[:env])
          "#{request.base_url}/api/splines/#{uuid}"
        end
      end
    end
  end
end
{% endhighlight %}

You can now present an entity in your API implementation.

{% highlight ruby %}
module Acme
  module Api
    class SplinesEndpoint < Grape::API
      namespace :splines do
        desc 'Get a spline.'
        params do
          requires :id, type: String, desc: 'Spline id.'
        end

        get ':id' do
          spline = Acme::Models::Spline.find(params[:id])
          present spline, with: Acme::Api::Presenters::SplinePresenter
        end
      end
    end
  end
end
{% endhighlight %}

Representing collections is similar, check out [https://github.com/dblock/grape-with-roar](https://github.com/dblock/grape-with-roar) for a complete example with bonus pagination support.

I’d love it if someone could contribute a POST/PUT example.
