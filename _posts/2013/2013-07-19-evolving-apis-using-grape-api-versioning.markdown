---
layout: post
title: "Evolving APIs using Grape API Versioning"
redirect_from: "/evolving-apis-using-grape-api-versioning/"
date: 2013-07-19 16:35:12
tags: [apis, rack, grape, ruby]
comments: true
---
I’ve seen two common API versioning strategies in the wild. The first is to use a single API version and gradually deprecate methods. This usually means introducing new API routes, while retiring old ones, and representing the same objects in multiple, versioned, formats. Fast forward a few years and you are likely to inherit a significant amount of technical debt. The second strategy involves making a clean cut, leaving the version one of the API alone and building a fresh, new, API version two.

Starting with the next release of Grape (likely 0.6.0) you will have a third alternative: building a new API version incrementally on top of a previous one. There’re no hacks involved. Consider the following trivial API.

```ruby
module Acme
 class V1 < Grape::API
   format :json
   version 'v1', using: :header, vendor: 'acme', format: :json

   desc "Returns the current API version, v1."
   get do
     { version: 'v1' }
   end

   desc "Returns pong."
   get "ping" do
     { ping: "pong" }
   end
 end
end
```

Define the next API version.

```ruby
module Acme
 class V2 < Grape::API
   format :json
   version 'v2', using: :header, vendor: 'acme', format: :json

   desc "Returns the current API version, v2."
   get do
     { version: 'v2' }
   end
 end
end
```

At this point we want _v1_ to be identical to _v2_, except for the root method. We’ll start by allowing _v1_ to respond to both _v1_ and _v2_ requests.

```ruby
version ['v2', 'v1'], using: :header, vendor: 'acme', format: :json
```

Mount v2 before v1 and allow v2 to cascade the request to the next Rack middleware by adding _cascade: true_ to its version declaration. Rack::Cascade works by passing on any requests until a middleware replies with something else than a 404.

```ruby
new Rack::Cascade([Acme::V2, Acme::V1])

version 'v2', using: :header, vendor: 'acme', format: :json, cascade: true
```

Try it on my demo project in [https://github.com/dblock/grape-on-rack-v1-inside-v2](https://github.com/dblock/grape-on-rack-v1-inside-v2).

By default we get the root of v2 and the ping method implemented on v1.

```
curl http://localhost:9292/
{"version":"v2"}

curl http://localhost:9292/ping
{"ping":"pong"}
```

With version two, we get the same thing.

```
curl http://localhost:9292 -H "Accept:application/vnd.acme-v2+json"
{"version":"v2"}

curl http://localhost:9292/ping -H "Accept:application/vnd.acme-v2+json"
{"ping":"pong"}
```

With version 1 we get the old behavior.

```
curl http://localhost:9292 -H "Accept:application/vnd.acme-v1+json"
{"version":"v1"}

curl http://localhost:9292/ping -H "Accept:application/vnd.acme-v1+json"
{"ping":"pong"}
```

The only fix needed in Grape for this was to enable multiple versions specified with _version_, committed in [2be499c51](https://github.com/intridea/grape/commit/2be499c51542e536e9e0bf7fd4e7587dd069e289).

This came up [on the Grape mailing list](https://groups.google.com/forum/?fromgroups#!topic/ruby-grape/yTQZtQmfxrs).
