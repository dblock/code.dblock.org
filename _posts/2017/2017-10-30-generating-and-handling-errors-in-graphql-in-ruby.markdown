---
layout: post
title: "Generating and Handling Errors in GraphQL in Ruby"
date: 2017-10-30
tags: [graphql, ruby]
comments: true
---
In a [previous post](/2017/10/23/building-and-consuming-a-graphql-api-in-ruby-on-rails.html) I walked you through building and consuming a GraphQL API in Ruby. That was the happy path. In this post we'll generate and handle some errors.

### Errors in a GraphQL API

GraphQL APIs can fail in three ways.

1. A _client-side_ error, eg. a query parsing error based on well-known schema.
2. A _server-side_ error, eg. a failure to create a database record behind the scenes.
3. A _transport_ error, eg. a server failing to respond with a 200 status to a `POST` query to the API.

### Client-Side Errors

Client-side errors include parser and validation errors that don't require a roundtrip to the server. Parsing an invalid query with any client library based on graphql-ruby will raise a `GraphQL::ParseError`, see [@d42b6238](https://github.com/dblock/graphql-invoices/commit/d42b62380f87cc41b7c1838089fd46ca3b7d238c) for an example.

### Server-Side Errors

For server-side implementations the [graphql-ruby doc on errors](https://github.com/rmosolgo/graphql-ruby/blob/master/guides/queries/error_handling.md) gives a few options.

#### Returning Errors Inside Resolve

You can return a `GraphQL::ExecutionError` inside a `resolve` function, see [@027d75cf](https://github.com/dblock/graphql-invoices/commit/027d75cf5ca5bebc2fdb1b1dcb329430e417049e) for an example.

{% highlight ruby %}
resolve ->(_object, _inputs, _ctx) {
  GraphQL::ExecutionError.new('This has not been implemented yet.')
}
{% endhighlight %}

The response contains both a `nil` value in `data` and an `errors` field with an error at the `executionError` path with a message.

![]({{ site.url }}/images/posts/2017/2017-10-30-generating-and-handling-errors-in-graphql-in-ruby/execution-error.png)

#### Handling Predictable Errors

You can turn typical errors, such as `ActiveRecord::RecordNotFound`, `ActiveRecord::RecordInvalid` or catch-all `StandardError` into a `GraphQL::ExecutionError` using a generic rescue object, see [@a0b8f58b](https://github.com/dblock/graphql-invoices/commit/a0b8f58b3f1ebed993a303bf379def1d8a83a25b) for an example.

{% highlight ruby %}
class Rescuable
  attr_reader :resolve_func

  def initialize(resolve_func)
    @resolve_func = resolve_func
  end

  def call(obj, args, ctx)
    resolve_func.call(obj, args, ctx)
  rescue ActiveRecord::RecordNotFound => e
    nil
  rescue ActiveRecord::RecordInvalid => e
    error_messages = e.record.errors.full_messages.join("\n")
    GraphQL::ExecutionError.new "Validation failed: #{error_messages}."
  rescue StandardError => e
    GraphQL::ExecutionError.new e.message
  end
end
{% endhighlight %}

This is used with `resolve` as follows.

{% highlight ruby %}
field :findInvoiceById, InvoiceType do
  argument :id, !types.Int
  resolve Rescuable.new ->(_object, args, _ctx) {
    Invoice.where(id: args[:id]).first
  }
end
{% endhighlight %}

But for most APIs a catch-all at schema level is much easier than having to wrap each `resolve` call into `resolve Rescuable.new`, which can be done with the [graphql-errors](https://github.com/exAspArk/graphql-errors) gem. See [@9e65eb47](https://github.com/dblock/graphql-invoices/commit/9e65eb479c1cbdd3e62865e13e7b43ea57c61d0d).

{% highlight ruby %}
GraphQL::Errors.configure(Schema) do
  rescue_from ActiveRecord::RecordNotFound do
    nil
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    error_messages = e.record.errors.full_messages.join("\n")
    GraphQL::ExecutionError.new "Validation failed: #{error_messages}."
  end

  rescue_from StandardError do |e|
    GraphQL::ExecutionError.new e.message
  end
end
{% endhighlight %}

### Transport Errors

Transport errors are straightforward and depend on the GraphQL client and HTTP library used. For example Graphlient's `FaradayAdapter` uses `Faraday::Response::RaiseError`, which will turn any non-200 HTTP status code into an exception, see [adapters/http/faraday_adapter.rb#24](https://github.com/ashkan18/graphlient/blob/v0.1.0/lib/graphlient/adapters/http/faraday_adapter.rb#L24).

### Client-Side Errors or Exceptions?

This is often a matter of preference or strong opinions.

I believe that any unexpected behavior outside of a happy path should raise an exception unless it can be explicitly avoided ahead of time. I also prefer to deal with two scenarios rather than three: _it worked_ and _it didn't work_ vs. _it worked_, _it didn't work in some predictable way_ and _it didn't work in some unpredictable way_. Practically, this means I want to see a `StandardError` when something failed, vs. having to check for an `.errors` field in my business logic.

The Github [graphql-client](https://github.com/github/graphql-client) library does not raise exceptions except when otherwise for all types of errors and parses server-side errors in potentially problematic ways (see [graphql-client#132](https://github.com/github/graphql-client/pull/132)), leaving you having to both handle exceptions and check for `.data.errors` and `.errors`.

The [graphlient](https://github.com/ashkan18/graphlient) library built on top of graphql-client attempts to make sense out of the many scenarios and always raises exceptions of `Graphlient::Errors::Error` variety for server-side problems. It's simpler to use and requires less `if` statements.
