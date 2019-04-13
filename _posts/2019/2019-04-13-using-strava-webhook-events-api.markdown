---
layout: post
title: "Using Strava Webhook Events API"
date: 2019-04-13
tags: [strava, api]
comments: true
---
[Strava Webhook Events API](https://developers.strava.com/docs/webhooks) seems to give developers trouble. Last year I wrote a [new Strava Ruby client](/2018/11/27/writing-a-new-strava-api-ruby-client.html) that made things significantly easier and came with some handy tools.

Here is how to run a full loop locally using `strava-webhooks` from [strava-ruby-client](https://github.com/dblock/strava-ruby-client#webhooks).

#### Install

Install [any recent version of Ruby](https://www.ruby-lang.org) to get started, then install the gem.

{% highlight sh %}
$ gem install strava-ruby-client
Successfully installed strava-ruby-client-0.3.1
{% endhighlight %}

#### Settings

Get a client ID and secret from [Strava Settings, My API Application](https://www.strava.com/settings/api) and set these as environment variables. You can also create a `.env` file in the current directory with these settings and the strava-webhooks tool will pick that up, `export` or specify these on the command line. YMMV.

#### Show Existing Subscriptions

Try `strava-webhooks` without any arguments. It should show you existing subscriptions, aka none.

{% highlight sh %}
$ STRAVA_CLIENT_ID=12345 STRAVA_CLIENT_SECRET=... strava-webhooks
request: GET https://api.strava.com/api/v3/push_subscriptions?...
response: Status 200
{% endhighlight %}

#### Handler

Run a local webhook handler that responds to Strava pushing events with `strava-webhooks handle`.

{% highlight sh %}
$ STRAVA_CLIENT_ID=12345 STRAVA_CLIENT_SECRET=... strava-webhooks handle
  WEBrick 1.4.2
  ruby 2.5.1 (2018-03-29) [x86_64-darwin17]
  WEBrick::HTTPServer#start: pid=53701 port=4242
{% endhighlight %}

Note that it starts on port 4242 by default.

Since your local machine is not addressable from the Internet, use [ngrok](https://ngrok.com/), in another terminal.

{% highlight sh %}
ngrok http 4242
{% endhighlight %}

This creates an HTTPs forwarding URL, eg. `https://d3d0c6c4.ngrok.io`.

#### Subscribe

Create a webhook subscription with `strava-webhooks create [url]`.

{% highlight sh %}
$ STRAVA_CLIENT_ID=12345 STRAVA_CLIENT_SECRET=... strava-webhooks create https://d3d0c6c4.ngrok.io
  Subscribing to https://d3d0c6c4.ngrok.io ...
  request: POST https://api.strava.com/api/v3/push_subscriptions
  response: Status 201

#<Strava::Webhooks::Models::Subscription
  application_id=12345
  callback_url="https://d3d0c6c4.ngrok.io"
  created_at=2019-04-13 14:06:16 UTC
  id=136021
  resource_state=2
  updated_at=2019-04-13 14:06:16 UTC
>
{% endhighlight %}

The response contains a subscription ID of `136021`.

Notice that the handler had to respond to a hub challenge.

{% highlight sh %}
GET /?hub.challenge=399037be828d8cd0&hub.mode=subscribe&hub.verify_token=token HTTP/1.1
{% endhighlight %}

#### Handle Events

Start by creating a manual activity for the same user. This will trigger an event that you can see in the handler window.

{% highlight sh %}
#<Strava::Webhooks::Models::Event
  aspect_type="create"
  event_time=2019-04-13 10:08:33 -0400
  object_id=2286689609
  object_type="activity"
  owner_id=29323238
  subscription_id=136021
  updates={}
>
{% endhighlight %}

Delete the activity.

{% highlight sh %}
#<Strava::Webhooks::Models::Event
  aspect_type="delete"
  event_time=2019-04-13 10:09:04 -0400
  object_id=2286689609
  object_type="activity"
  owner_id=29323238
  subscription_id=136021
  updates={}
>
{% endhighlight %}

#### Authorized User Activities

To see other users' events these must authorize your application. See [Strava Authentication](https://developers.strava.com/docs/authentication/) for implementation details.

#### Delete the Subscription

Delete the subscription with `strava-webhooks delete [id]`.

{% highlight sh %}
$ STRAVA_CLIENT_ID=12345 STRAVA_CLIENT_SECRET=... strava-webhooks delete 136021
  request: DELETE https://api.strava.com/api/v3/push_subscriptions/136021?client_id=...&client_secret=...
  response: Status 204
{% endhighlight %}

#### Code

The complete source code for strava-webhooks is [here](https://github.com/dblock/strava-ruby-client/blob/master/bin/strava-webhooks).
