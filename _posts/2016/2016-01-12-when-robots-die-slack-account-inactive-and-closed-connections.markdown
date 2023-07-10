---
layout: post
title: "When Robots Die - Slack account_inactive and Closed Connections"
date: 2016-01-12
tags: [slack, bot]
comments: true
---
One of the things you have to be aware when writing a bot is disabled integrations and closed connections. The first case is simple - when someone disables a bot integration, Slack closes a Real Time connection's WebSocket without an explanation.

![server side closed connection]({{ site.url }}/images/posts/2016/2016-01-12-when-robots-die-slack-account-inactive-and-closed-connections/disable.gif)

Using [slack-ruby-client](https://github.com/slack-ruby/slack-ruby-client), you would want to handle `:close`.

{% highlight ruby %}
client.on :close do |_data|
  puts 'Connection closed, exiting.'
  EM.stop
end
{% endhighlight %}

The next time you invoke [rtm.start](https://api.slack.com/methods/rtm.start), Slack will return `account_inactive`. Other possible errors include `invalid_auth`, which is when someone removes an integration instead of disabling it.

{% highlight bash %}
~/examples/hi_real_time (master)$ ruby hi.rb
slack-ruby-client-0.5.2/lib/slack/web/faraday/response/raise_error.rb:9:
  in `on_complete': account_inactive (Slack::Web::Api::Error)
    from faraday-0.9.2/lib/faraday/response.rb:9:in `block in call'
    from faraday-0.9.2/lib/faraday/response.rb:57:in `on_complete'
    from faraday-0.9.2/lib/faraday/response.rb:8:in `call'
    from faraday-0.9.2/lib/faraday/request/url_encoded.rb:15:in `call'
    from faraday-0.9.2/lib/faraday/request/multipart.rb:14:in `call'
    from faraday-0.9.2/lib/faraday/rack_builder.rb:139:in `build_response'
    from faraday-0.9.2/lib/faraday/connection.rb:377:in `run_request'
    from faraday-0.9.2/lib/faraday/connection.rb:177:in `post'
    from slack-ruby-client-0.5.2/lib/slack/web/faraday/request.rb:25:in `request'
    from slack-ruby-client-0.5.2/lib/slack/web/faraday/request.rb:10:in `post'
    from slack-ruby-client-0.5.2/lib/slack/web/api/endpoints/rtm.rb:21:in `rtm_start'
    from slack-ruby-client-0.5.2/lib/slack/real_time/client.rb:74:in `build_socket'
    from slack-ruby-client-0.5.2/lib/slack/real_time/client.rb:38:in `start!'
{% endhighlight %}

The same thing happens when you _remove_ an application (the _Remove App_ button below) that was setup via [Slack Button Integration](https://api.slack.com/docs/slack-button).

![remove app]({{ site.url }}/images/posts/2016/2016-01-12-when-robots-die-slack-account-inactive-and-closed-connections/remove.png)

A bot framework should handle this gracefully. For example, [slack-bot-server](https://github.com/slack-ruby/slack-ruby-bot-server), used in [playplay.io](http://playplay.io) will [attempt to restart](https://github.com/slack-ruby/slack-ruby-bot-server/blob/693a5c4887b19ca030a6a244e639ed9acf77f5fe/slack-bot-server/service.rb#L46) a bot on any error, then handle `account_inactive` or `invalid_auth` by deactivating the team and not trying to reconnect again. It will also [try reactivate the team](https://github.com/slack-ruby/slack-ruby-bot-server/blob/693a5c4887b19ca030a6a244e639ed9acf77f5fe/slack-bot-server/api/endpoints/teams_endpoint.rb#L49) upon re-registration via Slack Button, too.
