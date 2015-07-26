---
layout: post
title: "Slack Bot Real Time Messaging API Integration in Ruby Tutorial"
date: 2015-04-28
tags: [slack, api, ping-pong]
comments: true
---
I've been recently contributing to [slack-pongbot](https://github.com/andrewvy/slack-pongbot), a node.js Slack bot for setting up ping-pong matches at Artsy.

![]({{ site.url }}/images/posts/2015/2015-04-28-slack-bot-real-time-messaging-api-integration-tutorial/duel.gif)

The endless levels of callback hell and promises have driven me sufficiently crazy to try and rewrite this in Ruby. Let's get a basic Ruby Slack integration going, using the [Slack Real Time Messaging API](https://api.slack.com/rtm) this time.

### Slack-Ruby-Client

A quick note to readers. If you come here from [slack-ruby-gem](https://github.com/aki017/slack-ruby-gem) this tutorial no longer uses it. That library was slow to evolve and wasn't clearly separating the Slack Web API with the Slack RealTime Messaging API. I've rewritten much of the implementation in [slack-ruby-client](https://github.com/aki017/slack-ruby-client).

I do want to thank [@aki017](https://github.com/aki017), the author of the former gem, for getting me started.

### Use Slack Real Time Messaging Api

The Real Time Messaging API is a WebSocket-based API that allows you to receive events from Slack in real time and send messages as user. The hard part has been done for you in the [slack-ruby-client](https://github.com/aki017/slack-ruby-client) gem.

{% highlight ruby %}
gem 'slack-ruby-client', '~> 0.1.0'
{% endhighlight %}

### Create a New Bot Integration

This is something done in Slack, under [integrations](https://slack.com/services). Create a [new bot](https://slack.com/services/new/bot), and note its API token.

![]({{ site.url }}/images/posts/2015/2015-04-28-slack-bot-real-time-messaging-api-integration-tutorial/bot.png)

### Verify Auth

Use the token to verify auth via the Web API.

{% highlight ruby %}
Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

client = Slack::Web::Client.new

client.auth_test
{% endhighlight %}

The above code returns a hash with the user information, including _url_, _team_ and _team id_, _user_ and _user_id_.

### Start a Bot

The slack-api gem uses eventmachine to listen on events from Slack.

{% highlight ruby %}
client = Slack::RealTime::Client.new

client.on :hello do
  puts 'Successfully connected.'
end

client.on :message do |data|
  # respond to messages
end

client.start!
{% endhighlight %}

### Respond to Messages

{% highlight ruby %}
client.on :message do |data|
  case data['text']
  when 'bot hi' then
    client.message channel: data['channel'], text: "Hi <@#{data['user']}>!"
  when /^bot/ then
    client.message channel: data['channel'], text: "Sorry <@#{data['user']}>, what?"
  end
end
{% endhighlight %}

Slack automatically parses and translates things like `<@userid>`. That's it.

![]({{ site.url }}/images/posts/2015/2015-04-28-slack-bot-real-time-messaging-api-integration-tutorial/hi.png)

### Turning GameBot into an App

I turned GameBot into a runnable app with some bells and whistles at [github.com/dblock/slack-gamebot](https://github.com/dblock/slack-gamebot).
