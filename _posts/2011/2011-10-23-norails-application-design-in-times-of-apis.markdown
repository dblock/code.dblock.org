---
layout: post
title: "NoRails: Application Design in Times of APIs"
redirect_from: "/norails-application-design-in-times-of-apis"
date: 2011-10-23 15:40:54
tags: [grape, rails, architecture]
comments: true
---
A recent post ["Rails is Not Your Application"](http://blog.firsthand.ca/2011/10/rails-is-not-your-application.html) caught my attention. It was fundamentally right, but the suggested implementation was misguided.

> _"Rails is not your application. It might be your views and data source, but it's not your application. Put your app in a Gem or under lib/."_

When your application is a gem or a lib the design is answering the following question: _"How do I create a solid model based on my problem domain?"_. That’s what domain driven design teaches you. But it fails to answer subsequent issues of: "_How do I create a solid and <u>usable</u> domain model?_" and _"How do I define a clear <u>externally visible</u> and testable boundary?"._

The answer to all these questions is a proper external API. But when it comes to an implementation with Rails one usually fails to express the API with the suggested MVC layout. I see several issues.

1. Controllers don’t express RESTful intent. Rails controllers are designed to serve views. Calling JSON a format or a view is misguided because the format and the contents of the JSON belongs with the model, not with its presentation.
2. Rails routes don’t coherently express RESTfulness and the separation of routes and controllers creates an unnecessary level of indirection. Therefore it’s difficult to know where the API beings and where it ends by looking at the controller code.
3. Versioning is very hard and the changes in an API are difficult to trace. It’s particularly hard to take an existing Rails application and turn it into an API.
4. Testing a controller allows reaching into the guts of the implementation to test assignment, therefore discouraging testing from the user’s perspective via the HTTP protocol. Furthermore mocking, heavily encouraged in testing controllers, serves no purpose in testing an API whatsoever.

We’ve chosen Grape ([https://github.com/intridea/grape](https://github.com/intridea/grape)), a DSL that expresses RESTful APIs and have been heavily contributing to it. Grape is RACK-based and can run in a Rails application. In Grape you define your API and can directly interact with models. Since we’ve started using Grape we no longer find the need for an MVC layer (ie. Rails) and the MVC layer has moved into the UI, written entirely in Javascript with Backbone.js. This is also good because we consume our own API the same way we would consume anybody else’s and the models don’t have to worry about how they are presented – they express the domain of our business via a clearly defined and testable API.
