---
layout: post
title: "Why does Slack API rtm.start send you all this data?"
date: 2016-02-03
tags: [slack, api]
comments: true
---
Like many, I found it easy to immediately criticize the [Slack Web and RealTime API](https://api.slack.com) design. I would have wanted a RESTful implementation and not an RPC one. I would have liked for it to use HTTP and fail with an HTTP error code instead of sending clients JSON with an `ok` field to yield errors. I would have liked to use HTTP verbs for CRUD and not make everything `GET` or `POST`. I would be excited for calling the Web API a lot less and seeing a lot more functionality available via the RealTime API.

But as I iterated on what has become the de facto standard [Slack Ruby client](https://github.com/dblock/slack-ruby-client) I learned to enjoy more and more aspects of the Slack API design. I spent a bit of time reading the source code of the [Slack Node.js client](https://github.com/slackhq/node-slack-client), especially the 2.0 rewrite, and concluded that many of the API's choices were remarkably well-suited to the API's primary goal - enabling rich RealTime clients.

One of the most interesting design choices is to send a ton of data to a RealTime client on `rtm.start` (one of my small teams gets 43Kb, bigger ones probably easily get a megabyte). This includes an initial set of team metadata and a message server WebSocket URL. This is a big JSON blob, with team information, all channels, groups, users, bots, recent channel messages, and more. The method supports some interesting arguments, including `simple_latest: true` or `no_unreads: true`, obviously aimed at reducing the size of the response.

In slack-ruby-client 0.6.0 (and in the node client), this data is being saved in a local store.

{% highlight ruby %}
data = web_client.rtm_start(start_options)
@store = Slack::RealTime::Store.new(data)
{% endhighlight %}

The store exposes `users`, `channels`, `teams`, etc.

Every time data changes in Slack, [an event](https://api.slack.com/events) is delivered to every connected client. For example, when a channel is renamed a [channel_rename](https://api.slack.com/events/channel_rename) event is sent.

{% highlight json %}
{
    "type": "channel_rename",
    "channel": {
        "id":"C02ELGNBH",
        "name":"new_name",
        "created":1360782804
    }
}
{% endhighlight %}

This is handled by a `channel_rename` handler.

{% highlight ruby %}
channel = client.channels[data.channel.id]
channel.name = data.channel.name
{% endhighlight %}

What's in this for you? With the 0.6.0 release of slack-ruby-client you can access an up-to-date local store with all the information otherwise available via slow Web API calls. Instead of calling `client.web_client.user_info(user: 'U1234567')` to get user information, do `client.users['U1234567']`. It's a table lookup, so this is obviously a lot faster. A store can also be disabled with specifying `store_class: nil` to the `Slack::RealTime::Client` initializer, as the amount of data stored in memory can become fairly onerous and isn't always necessary.

What about the store getting out of sync? Slack maintains a queue of events server-side and seems to either guarantee or try it's best to deliver all messages, regardless of network conditions. This means that as long as the client was able to maintain a websocket connection, all events will eventually arrive in-order.

You probably also don't want a store backed by a database without doing additional work - you want an in-memory one for the duration of the RealTime session. There're a few methods that can help rewind events and catch up, including `channels.history`, `groups.history`, `im.history` and `mpim.history`, which call for a more sophisticated implementation.

Give slack-ruby-client 0.6.0 a try from Github HEAD, `gem 'slack-ruby-client', github: 'dblock/slack-ruby-client'`. It will ship shortly.
