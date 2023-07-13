---
layout: post
title: "Grape vs. Webmachine"
redirect_from: "/grape-vs-webmachine/"
date: 2011-12-14 03:13:28
tags: [webmachine, grape, rails, ruby]
comments: true
dblog_post_id: 303
---
One of my favorite talks at QCon 2011 was [about Webmachine](https://www.infoq.com/presentations/Webmachine-A-Practical-Executable-Model-for-HTTP). I was very curious to see what those well-disciplined Erlang people had come up with. At the end of the talk I had learned that Webmachine used a resource-based model that enabled well-behaved HTTP applications, which is RESTful by definition. So I went to [NYC.rb](https://www.meetup.com/NYC-rb/events/28968101/?value=Resources%2C+For+Real+This+Time+(with+Webmachine)) today to hear about the Ruby version of Webmachine and to write a post about how these two frameworks compare.

Should you build your next RESTful API with [Grape](https://github.com/ruby-grape/grape) or [Webmachine](https://github.com/seancribbs/webmachine-ruby)?

Both frameworks as saying that you should not force HTTP onto an MVC-shaped application. Both excel at serving HTTP resources.

Webmachine is an executable model for HTTP, while Grape is a DSL for RESTful APIs. This means that in Webmachine you don’t perform actions – you declare resources. In Grape you declare API methods and fill out the responses. In Grape you have to be disciplined about those API methods - they should represent resources, not RPC service endpoints. More differences appear in branching: halting execution in Webmachine is done by returning appropriate answers in resource-specific functions, while halting execution in Grape is done by throwing a specific exception that carries an HTTP error code. Routing-wise, In Webmachine you map URIs to resources, while in Grape you define namespaces and method paths that translate into invisible routes. In Webmachine you implement resource callbacks, while in Grape you use procedural logic within the API method implementation. Webmachine is trying to be a complete executable model and is therefore more structured, while Grape wants you to use middleware for aspects such as ETag-based caching and doesn’t try to prevent you from jumping in the water when you don’t know how to swim.

We had a long discussion about this outside of Pivotal Labs with [@seancribbs](https://twitter.com/seancribbs) and [@johnjoseph](https://twitter.com/johnjoseph) (who even mentioned Prolog at some point). It helped me frame my opinion around mostly philosophical differences between the two frameworks. I could very well use Webmachine to build an API and be very happy with it (I would not be happy building an API in Rails). I would grant Webmachine an advantage over purity from the developer’s perspective – it’s harder to step outside of the programming model. I would grant Grape an advantage over favoring the API consumer, since it focuses on the expressiveness of the API. For example, Grape now has self-introspection for automatically generating documentation, a feature that seems harder and maybe even unnatural to build for Webmachine.

Fundamentally, Webmachine declares resources served via HTTP, while Grape declares an API. Your choice?
