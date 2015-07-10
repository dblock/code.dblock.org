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

### Use Slack Real Time Messaging Api

The Real Time Messaging API is a WebSocket-based API that allows you to receive events from Slack in real time and send messages as user. The hard part has been done for you in the [slack-api](https://github.com/aki017/slack-ruby-gem) gem. It's a bit in flux, so here's a working Gemfile add.

{% highlight ruby %}
gem 'slack-api', '~> 1.1.6', require: 'slack'
{% endhighlight %}

### Create a New Bot Integration

This is something done in Slack, under [integrations](https://slack.com/services). Create a [new bot](https://slack.com/services/new/bot), and note its API token.

![]({{ site.url }}/images/posts/2015/2015-04-28-slack-bot-real-time-messaging-api-integration-tutorial/bot.png)

### Verify Auth

Use the token to verify auth.

{% highlight ruby %}
Slack.configure do |config|
  config.token = ...
end

auth = Slack.auth_test
fail auth['error'] unless auth['ok']
{% endhighlight %}

The above code returns a hash with the user information, including _url_, _team_ and _team id_, _user_ and _user_id_.

### Start a Bot

The slack-api gem uses eventmachine to listen on events from Slack.

{% highlight ruby %}
client = Slack.realtime

client.on :hello do
  # Slack successfull connected ...
  logger.info 'Successfully connected.'
end

client.on :message do |data|
  # respond to messages
end

client.start
{% endhighlight %}

### Respond to Messages

{% highlight ruby %}
client.on :message do |data|
  case data['text']
    when 'gamebot hi'
      Slack.chat_postMessage channel: data['channel'], text: "Hi <@#{data.user}>!"
    when /^gamebot/
      Slack.chat_postMessage channel: data['channel'], text: "Sorry <@#{data.user}>, what?"
    end
  end
end
{% endhighlight %}

Slack automatically parses and translates things like `<@userid>`. That's it.

![]({{ site.url }}/images/posts/2015/2015-04-28-slack-bot-real-time-messaging-api-integration-tutorial/hi.png)

### Turning GameBot into an App

I turned GameBot into a runnable app with some bells and whistles, source code is at [github.com/dblock/slack-gamebot](https://github.com/dblock/slack-gamebot). It has tests and can be a decent boilerplate for your own Slack bot. Stay tuned for a complete game bot implementation that will work for ping-pong and other challenges.

### Update: Lita and Slack-Ruby-Bot

Someone pointed me to an interesting project, [Lita](https://www.lita.io), a generic bot environment that lets you create bot handlers for various tools without having to implement all the above-mentioned boilerplate. It seems to bring a lot of infrastructure in, such as Redis, that's not always what you want.

I've since worked on [slack-ruby-bot](https://github.com/dblock/slack-ruby-bot), a simpler bot boilerplate, and reimplemented the above using that. It made it really trivial to write a Slack bot in Ruby, so party on!
