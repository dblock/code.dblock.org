---
layout: post
title: "Handling of HTTP Headers in Grape with Rack and Rails"
tags: [grape, ruby]
date: 2019-07-06
comments: true
---
I recently helped debug [Grape#1880](https://github.com/ruby-grape/grape/issues/1880), an issue a developer had with HTTP headers in Grape and Rack. It wasn't immediately obvious.

### Test API

Let's write a simple Grape API that returns a value for a header.

{% highlight ruby %}
module Acme
  class Headers < Grape::API
    format :json

    desc 'Returns a header value.'
    params do
      requires :key, type: String
    end
    get 'headers/:key' do
      key = params[:key]
      { key => headers[key] }
    end
  end
end
{% endhighlight %}

### Default Headers

The default headers in a Rack test are `Cookie` and `Host`. 

{% highlight ruby %}
  it 'returns all headers' do
    get '/api/headers'
    expect(JSON.parse(last_response.body)).to eq(
      'Cookie' => '',
      'Host' => 'example.org'
    )
  end

  it 'returns a Host header' do
    get '/api/headers/Host'
    expect(JSON.parse(last_response.body)).to eq('Host' => 'example.org')
  end
{% endhighlight %}

Curl sends more headers by default.

{% highlight bash %}
$ curl http://localhost:9292/api/headers

{"Host":"localhost:9292","User-Agent":"curl/7.54.0","Accept":"*/*","Version":"HTTP/1.1"}
{% endhighlight %}

### Pascal Case Conversion

Headers in Grape are always [converted](https://github.com/ruby-grape/grape/commit/f6f585ea6cc720e779a37f756b9e9cda4786dad2) to pascal-case.

{% highlight bash %}
$ curl -H eLiTe:42 http://localhost:9292/api/headers/Elite

{"Elite":"42"}
{% endhighlight %}

This means that a pascal-case-looking header `ReticulatedSpline` is converted to `Reticulatedspline`.

{% highlight bash %}
curl -H ReticulatedSpline:42 http://localhost:9292/api/headers/Reticulatedspline
{"Reticulatedspline":"42"}
{% endhighlight %}

And a lowercase `reticulated-spline` is converted to `Reticulated-Spline`, similarly to `User-Agent`.

{% highlight bash %}
curl -H reticulated-spline:42 http://localhost:9292/api/headers/Reticulated-Spline 
{"Reticulated-Spline":"42"}
{% endhighlight %}

### Rack

Rack stores HTTP headers in `ENV` as all uppercase with an `HTTP_` prefix. You can pass the Rack env as the the second parameter in your specs. In the example below `HTTP_RETICULATED_SPLINE` becomes `Reticulated-Spline` and `SOMETHING_ELSE` is only available in `ENV['SOMETHING_ELSE']` and is not a header. 

{% highlight ruby %}
get '/api/headers', nil, { 
  'HTTP_RETICULATED_SPLINE' => 42, 
  'SOMETHING_ELSE' => 1 
}
expect(JSON.parse(last_response.body)).to eq(
  'Cookie' => '', 
  'Host' => 'example.org', 
  'Reticulated-Spline' => 42
)
end
{% endhighlight %}

To avoid confusion use the `header` helper that behaves as one would expect.

{% highlight ruby %}
header 'Reticulated-Spline', 42
get '/api/headers/Reticulated-Spline'
expect(JSON.parse(last_response.body)).to eq('Reticulated-Spline' => 42)
{% endhighlight %}

### Rails

Rails `get` takes a `Hash`, but it's still a wrapper on top of Rack, sort of. You can specify a header as `Header` or `HTTP_...`.

{% highlight ruby %}
get '/api/headers', headers: {
  'HTTP_RETICULATED_SPLINE' => 42,
  'Something' => 1,
  'SOMETHING_ELSE' => 1
}
expect(JSON.parse(response.body)).to eq(
  'Accept' => 'text/xml,image/png,*/*;q=0.5',
  'Cookie' => '',
  'Host' => 'www.example.com',
  'Reticulated-Spline' => 42,
  'Something' => 1
)
{% endhighlight %}

### Links

* [grape#headers](https://github.com/ruby-grape/grape#headers): Header handling documentation in Grape.
* [grape#1880](https://github.com/ruby-grape/grape/issues/1880): Issue with case insensitive headers.
* [grape-on-rack#18](https://github.com/ruby-grape/grape-on-rack/pull/18): Demonstrate header handling in Rack.
* [grape-on-rails#9](https://github.com/ruby-grape/grape-on-rails/pull/9): Demonstrate header handling in Rails.
