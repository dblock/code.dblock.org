---
layout: post
title: "The Easiest Way to Write a Slack Bot in Ruby"
date: 2015-07-18
tags: [slack, api]
comments: true
---
I've extracted and improved upon common code from [slack-gamebot](https://github.com/dblock/slack-gamebot) and [slack-mathbot](https://github.com/dblock/slack-mathbot) and made [slack-ruby-bot](https://github.com/dblock/slack-ruby-bot). It's probably the easiest way to make a Slack bot in Ruby today.

Here's a minimal example.

![]({{ site.url }}/images/posts/2015/2015-07-18-the-easiest-way-to-write-a-slack-bot-in-ruby/demo.gif)

{% highlight ruby %}
require 'slack-ruby-bot'

class PongBot < SlackRubyBot::Bot
  command 'ping' do |client, data, _|
    client.say(channel: data.channel, text: 'pong')
  end
end

PongBot.run
{% endhighlight %}

Add `gem 'slack-ruby-bot'` to your *Gemfile* and party on. Unlike [Lita](https://github.com/jimmycuadra/lita) it's not trying to be anything other than a Slack bot boilerplate. Source code [on Github](https://github.com/dblock/slack-ruby-bot).

### Update: Integration with Rails

If you're trying to integrate Slack with Rails, check out [Writing a Slack Bot running on Rails (with React)](/2015/11/28/writing-a-slack-bot-running-on-rails-with-react.html).
