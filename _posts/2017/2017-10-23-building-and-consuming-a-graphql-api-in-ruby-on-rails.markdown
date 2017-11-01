---
layout: post
title: "Building and Consuming a GraphQL API with Ruby on Rails"
date: 2017-10-23
tags: [graphql, ruby]
comments: true
---
In the past few weeks I've convinced myself that GraphQL can work well for any micro-service. This post is a full walk-through of getting a working GraphQL API on Ruby on Rails. This should help you get started, especially if you've never written a line of GraphQL in your life. The code for this post is [dblock/graphql-invoices](https://github.com/dblock/graphql-invoices).

### Prerequisites

Make a bare Rails API app with `rails new --api`, get RSpec and RuboCop. See [@c26b0e18](https://github.com/dblock/graphql-invoices/commit/c26b0e18ca1daea4d4754a520c0b2053f5f8dc10).

### GraphQL

Add `gem 'graphql'` to the project.

This is the [graphql-ruby](https://github.com/rmosolgo/graphql-ruby) library, an implementation of GraphQL in Ruby and is what is used for building a GraphQL endpoint on the server. See [@7649ba2b](https://github.com/dblock/graphql-invoices/commit/7649ba2bc46ce2003f2cab19826a5d032dd8a00c).

### Defining Schema

This project will implement a dummy invoice API where clients can get invoices and create invoices.

The invoice type has an ID and some fees in cents and goes into [app/graphql/types/invoice.rb](https://github.com/dblock/graphql-invoices/blob/7649ba2bc46ce2003f2cab19826a5d032dd8a00c/app/graphql/types/invoice_type.rb).

{% highlight ruby %}
InvoiceType = GraphQL::ObjectType.define do
  name 'Invoice'
  description 'An Invoice'
  field :id, !types.Int
  field :fee_in_cents, types.Int
end
{% endhighlight %}

The GraphQL ID type is a string, so we use `Int`.

GraphQL defines a schema with queries (eg. get invoices) and mutations (eg. create an invoice), which typically goes into [app/graphql/schema.rb](https://github.com/dblock/graphql-invoices/blob/7649ba2bc46ce2003f2cab19826a5d032dd8a00c/app/graphql/schema.rb).

{% highlight ruby %}
Schema = GraphQL::Schema.define do
  query Query
  mutation Mutation
end
{% endhighlight %}

The query root returns an invoice by ID, implemented in [app/graphql/queries.rb](https://github.com/dblock/graphql-invoices/blob/7649ba2bc46ce2003f2cab19826a5d032dd8a00c/app/graphql/queries.rb). Notice that this takes an `Int` (ID) and returns our `InvoiceType`.

{% highlight ruby %}
Query = GraphQL::ObjectType.define do
  name 'Query'

  field :invoice, InvoiceType do
    argument :id, !types.Int
    description 'Get an invoice by ID.'
    resolve ->(_obj, args, _ctx) {
      OpenStruct.new(
        id: args[:id],
        fee_in_cents: 20_000
      )
    }
  end
end
{% endhighlight %}

A mutation creates invoices in [app/graphql/mutations/create_invoice_mutation.rb](https://github.com/dblock/graphql-invoices/blob/7649ba2bc46ce2003f2cab19826a5d032dd8a00c/app/graphql/mutations/create_invoice_mutation.rb). Use Relay, a data fetching framework, that makes it easy.

{% highlight ruby %}
CreateInvoiceMutation = GraphQL::Relay::Mutation.define do
  name 'createInvoice'

  input_field :fee_in_cents, !types.Int
  return_type InvoiceType

  resolve ->(_object, inputs, _ctx) {
    OpenStruct.new(
      id: 1231,
      fee_in_cents: inputs[:fee_in_cents]
    )
  }
end
{% endhighlight %}

This mutation was referenced from the root schema above and is linked from [app/graphql/mutations.rb](https://github.com/dblock/graphql-invoices/blob/7649ba2bc46ce2003f2cab19826a5d032dd8a00c/app/graphql/mutations.rb).

{% highlight ruby %}
Mutation = GraphQL::ObjectType.define do
  name 'Mutation'

  field :createInvoice, field: CreateInvoiceMutation.field
end
{% endhighlight %}

### GraphQL Controller

GraphQL accepts a single JSON payload via `POST` in a typical Rails controller in [app/controllers/graphql_controller.rb](https://github.com/dblock/graphql-invoices/blob/7649ba2bc46ce2003f2cab19826a5d032dd8a00c/app/controllers/graphql_controller.rb).

{% highlight ruby %}
class GraphqlController < ApplicationController
  def execute
    result = Schema.execute(
      query,
      variables: variables,
      context: context,
      operation_name: operation_name
    )
    render json: result
  end

  private

  def query
    params[:query]
  end

  def operation_name
    params[:operationName]
  end

  def context
    {}
  end

  def variables
    variables = params[:variables]
    variables = JSON.parse(variables) if variables && variables.is_a?(String)
    variables || {}
  end
end
{% endhighlight %}

The controlled needs to be routed to in [config/routes.rb](https://github.com/dblock/graphql-invoices/blob/7649ba2bc46ce2003f2cab19826a5d032dd8a00c/config/routes.rb).

{% highlight ruby %}
Rails.application.routes.draw do
  post '/graphql', to: 'graphql#execute'
end
{% endhighlight %}

### GraphQL IDEs

The best way to try our app out is to use a [GraphQL IDE](https://github.com/andev-software/graphql-ide). Run the Rails application with `rails s` and point the IDE to `http://localhost:3000/graphql`.

![]({{ site.url }}/images/posts/2017/2017-10-23-building-and-consuming-a-graphql-api-in-ruby-on-rails/ide.png)

You can use various clients to consume the API from our applications, including [graphlient](https://github.com/ashkan18/graphlient) or [graphql-client](https://github.com/github/graphql-client).

### Tests

Add [graphlient](https://github.com/ashkan18/graphlient), which is a small library built on top of [graphql-client](https://github.com/github/graphql-client) and that's a bit easier to use.

Define a shared client context in [spec/support/graphql/client.rb](https://github.com/dblock/graphql-invoices/blob/7649ba2bc46ce2003f2cab19826a5d032dd8a00c/spec/support/graphql/client.rb).

{% highlight ruby %}
require 'graphlient'

RSpec.shared_context "GraphQL Client", shared_context: :metadata do
  let(:client) do
    Graphlient::Client.new('https://api.example.org/graphql') do |client|
      client.http do |h|
        h.connection do |c|
          c.use Faraday::Adapter::Rack, app
        end
      end
    end
  end
end
{% endhighlight %}

The client can fetch the schema in [spec/graphql/schema_spec.rb](https://github.com/dblock/graphql-invoices/blob/7649ba2bc46ce2003f2cab19826a5d032dd8a00c/spec/graphql/schema_spec.rb).

{% highlight ruby %}
require 'rails_helper'

describe 'GraphQL Schema', type: 'request' do
  include_context 'GraphQL Client'

  it 'retrieves schema' do
    expect(client.schema).to be_a GraphQL::Schema
  end
end
{% endhighlight%}

Fetch an invoice in [spec/graphql/queries/invoice_query_spec.rb](https://github.com/dblock/graphql-invoices/blob/7649ba2bc46ce2003f2cab19826a5d032dd8a00c/spec/graphql/queries/invoice_query_spec.rb).

{% highlight ruby %}
require 'rails_helper'

describe 'Invoice Query', type: :request do
  include_context 'GraphQL Client'

  let(:query) do
    <<-GRAPHQL
      query($id: Int!) {
        invoice(id: $id) {
          id
          fee_in_cents
        }
      }
    GRAPHQL
  end

  it 'returns an invoice' do
    response = client.execute(query, id: 42)
    invoice = response.data.invoice
    expect(invoice.id).to eq 42
    expect(invoice.fee_in_cents).to eq 20_000
  end
end
{% endhighlight %}

Create an invoice in [spec/graphql/mutations/create_invoice_mutation_spec.rb](https://github.com/dblock/graphql-invoices/blob/7649ba2bc46ce2003f2cab19826a5d032dd8a00c/spec/graphql/mutations/create_invoice_mutation_spec.rb).

{% highlight ruby %}
require 'rails_helper'

describe 'Create Invoice Mutation', type: :request do
  include_context 'GraphQL Client'

  let(:query) do
    <<-GRAPHQL
      mutation($input: createInvoiceInput!) {
        createInvoice(input: $input) {
          id
          fee_in_cents
        }
      }
    GRAPHQL
  end

  it 'returns an invoice' do
    response = client.execute(query, input: { fee_in_cents: 42_000 })
    invoice = response.data.create_invoice
    expect(invoice.id).to eq 1231
    expect(invoice.fee_in_cents).to eq 42_000
  end
end
{% endhighlight %}

### Tooling

GraphQL comes with some impressive tooling and IDE integration, such as with [Visual Studio Code](https://code.visualstudio.com) via [graphql-for-vscode](https://github.com/kumarharsh/graphql-for-vscode).

Add a Rake task to dump the project's schema to [lib/tasks/graphql/schema.rake](https://github.com/dblock/graphql-invoices/blob/33545540b13188532aac67424c7723340ccb681b/lib/tasks/graphql/schema.rake).

{% highlight ruby %}
namespace :graphql do
  namespace :schema do
    directory 'data'
    desc 'Dump GraphQL API schema to data/schema.graphql.'
    task dump: [:environment, 'data'] do
      File.open('data/schema.graphql', 'w') do |f|
        f.write(Schema.to_definition)
        puts "Dumped schema to #{f.path}."
      end
    end
  end
end
{% endhighlight %}

Add a configuration file, [.gqlconfig](https://github.com/dblock/graphql-invoices/blob/33545540b13188532aac67424c7723340ccb681b/.gqlconfig)

{% highlight json %}
{
  "schema": {
    "files": "data/schema.graphql"
  },
  "query": {
    "files": [
      {
        "match": "spec/graphql/**/*.rb",
        "parser": ["EmbeddedQueryParser", { "startTag": "<<-GRAPHQL", "endTag": "GRAPHQL" }]
      }
    ]
  }
}
{% endhighlight %}

Install prerequisites for graphql-for-vscode.

{% highlight bash %}
brew update
brew install watchman
npm install @playlyfe/gql
{% endhighlight %}

Install graphql-for-vscode from the Visual Studio Code Marketplace, [here](https://marketplace.visualstudio.com/items?itemName=kumar-harsh.graphql-for-vscode).

![]({{ site.url }}/images/posts/2017/2017-10-23-building-and-consuming-a-graphql-api-in-ruby-on-rails/mutation.gif)

### Generating and Handling Errors

Read [Generating and Handling Errors in GraphQL in Ruby](/2017/10/30/generating-and-handling-errors-in-graphql-in-ruby.html) next.
