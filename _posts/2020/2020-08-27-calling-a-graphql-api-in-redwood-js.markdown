---
layout: post
title: "Calling a GraphQL API in Redwood.js"
date: 2020-08-27
tags: [graphql, javascript]
comments: true
---
I recently needed to stand up a demo app that invoked an [AWS AppSync](https://aws.amazon.com/appsync/) GraphQL API. The existing endpoint (not available publicly) returned restaurant data for a given zip with the following schema.

{% highlight javascript %}
type ZipData {
  zip: String
  timezone: String
  restaurants: [RestaurantData]
}

type RestaurantData {
  name: String
  latitude: String
  longitude: String
}

type Query {
  get_restaurants_by_zip(zip: String!): ZipData
}

schema {
  query: Query
}
{% endhighlight %}

The app I wanted to build was throwaway, and my goal was to make it happen effortlessly, during a single lunch break. I was told to try [Redwood.js](https://redwoodjs.com/), [AWS Amplify](https://aws.amazon.com/amplify/), [Sanity.io](https://www.sanity.io/), [Next.js](https://nextjs.org/) via [prisma-examples](https://github.com/prisma/prisma-examples), and some zero-code tools, including [ReTool](https://retool.com/).

## Redwood.js

Let's start with Redwood.js ...

### Create an App

{% highlight bash %}
nvm use 12
yarn create redwood-app ./redwood-js-appsync-graphql-demo
cd ./redwood-js-appsync-graphql-demo
{% endhighlight %}

### Add a Homepage

{% highlight bash %}
yarn redwood generate page home /
{% endhighlight %}

### Add an Input Box for the Zip Code

When the form is submitted, state (including zip code) will change.

{% highlight react %}
import { Link, routes } from '@redwoodjs/router'
import { useState } from 'react'
import { Form, TextField, Submit } from '@redwoodjs/forms'

const HomePage = () => {
  const [zip, setZip] = useState()

  const onSubmit = (data) => {
    setZip(data.zip)
  }

  return (
    <div>
      <Form onSubmit={onSubmit}>
        <TextField name="zip" placeholder="Zip code" maxLength="5" />
        <Submit>Go</Submit>
      </Form>
    </div>
  )
}

export default HomePage
{% endhighlight %}

### Add graphql-request

{% highlight bash %}
yarn add -W graphql-request
{% endhighlight %}

### Add the GraphQL Query

{% highlight react %}
import { GraphQLClient } from 'graphql-request'

export const getRestaurantsByZip = async (zip) => {
  const endpoint = process.env.APPSYNC_API_ENDPOINT_URL

  const graphQLClient = new GraphQLClient(endpoint, {
    headers: {
      'x-api-key': process.env.APPSYNC_API_KEY
    },
  })

  const query = gql`query GetZip($zip: String!) {
    get_restaurants_by_zip(zip: $zip) {
      zip
      timezone
      restaurants {
        name
      }
    }
  }`

  return graphQLClient.request(query, { zip: zip })
}
{% endhighlight %}

### Wire Up GraphQL Results

{% highlight react %}
const onSubmit = (data) => {
  getRestaurantsByZip(data.zip).then(rc => {
    setZip(rc.get_restaurants_by_zip.zip)
  })
}

return (
  <div>
    ...
    <div>
      {zip &&
        <div>
          <h2>{zip.zip}</h2>
          <h3>{zip.timezone}</h3>
        </div>
      }
      {zip && zip.restaurants.map(r =>
        <div>{r.name}</div>
      )}
    </div>
  </div>
)
{% endhighlight %}

### Not Taking Advantage of Redwood.js

So far I used Redwood.js similarly to how one would use Rails without models, views or controllers, just to host some Ruby code on a web page. Redwood has lots of features, including cells and side-loading. Seems like a missed opportunity! So I asked the Redwood.js community to [help me leverage Redwood.js better](https://community.redwoodjs.com/t/how-can-i-wire-up-a-graphql-api-to-redwoodjs/1112). The answer is more generally described in the documentation under [Server-Side API Integration](https://redwoodjs.com/cookbook/using-a-third-party-api#server-side-api-integration).

### Expose Restaurants Side-Loading

Add `api/src/graphql/restaurants.sdl.js` with the schema that our Redwood.js service will return.

{% highlight javascript %}
import gql from 'graphql-tag'

export const schema = gql`
  type Restaurant {
    name: String
    longitude: String
    latitude: String
  }
  type Zip {
    zip: String
    timezone: String
    restaurants: [Restaurant]
  }
  type Query {
    restaurants(zip: String!): Zip
  }
` 
{% endhighlight %}

### Fetch Data from the AppSync API

Wire up calls to the AppSync endpoint in `api/src/lib/db.js`.

{% highlight javascript %}
import { GraphQLClient } from 'graphql-request'

export const request = async (query, variables) => {
  const endpoint = process.env.APPSYNC_API_ENDPOINT_URL

  const graphQLClient = new GraphQLClient(endpoint, {
    headers: {
      'x-api-key': process.env.APPSYNC_API_KEY
    },
  })

  return await graphQLClient.request(query, variables)
} 
{% endhighlight %}

Add `api/src/services/restaurants.js` that loads restaurant data using the above endpoint.

{% highlight javascript %}
import { request } from 'src/lib/db'
import { gql } from 'graphql-request'

export const restaurants = async (args) => {
  const query = gql`query GetZip($zip: String!) {
    get_restaurants_by_zip(zip: $zip) {
      zip
      timezone
      restaurants {
        name
        longitude
        latitude
      }
    }
  }`

  var data = await request(query, args)
  return data.get_restaurants_by_zip
} 
{% endhighlight %}

### Add a Restaurants Cell

{% highlight bash %}
yarn redwood generate cell restaurants
{% endhighlight %}

The cell makes a query to the Redwood.js service to fetch restaurants.

{% highlight react %}
export const QUERY = gql`query($zip: String!) {
  restaurants(zip: $zip) {
    zip
    timezone
    restaurants {
      name
      longitude
      latitude
    }
  }
}`

export const Loading = () => <div>Loading ...</div>

export const Empty = () => <div>No zip yet!</div>

export const Failure = ({ error, zip }) => {
  return <div>Error loading zip {zip}: {error.message}</div>
}

export const Success = ({ restaurants }) => {
  return <div>
    <div>
      <h2>{restaurants.zip}</h2>
      <h3>{restaurants.timezone}</h3>
    </div>
    {restaurants.restaurants.map(r =>
      <div>
        <div>{r.name}</div>
      </div>
    )}
  </div>
}
{% endhighlight %}

Wire up the cell in the homepage.

{% highlight react %}
const HomePage = () => {
  const [zip, setZip] = useState()

  const onSubmit = (data) => {
    setZip(data.zipCode)
  }

  return (
    <div>
      {zip && <RestaurantsCell zip={zip} />}
    </div>
  )
}
{% endhighlight %}

### Put it All Together

Create a `.env` file with `APPSYNC_API_ENDPOINT_URL` and `APPSYNC_API_KEY` and run the app with `yarn redwood dev`.

See [github.com/dblock/redwood-js-appsync-graphql-demo](https://github.com/dblock/redwood-js-appsync-graphql-demo) for the complete, working code, along with some Google maps.

![](https://github.com/dblock/redwood-js-appsync-graphql-demo/raw/master/demo.png)