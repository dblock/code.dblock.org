---
layout: post
title: "Migrating Classic Slack Ruby Bots to Granular Permissions"
date: 2020-11-30
tags: [ruby, slack]
comments: true
---
Slack recently [introduced granular permissions](https://medium.com/slack-developer-blog/more-precision-less-restrictions-a3550006f9c3) and is now requiring all new apps to use those. The old apps are called _classic_ apps, and new apps are called ... apps. Slack also provided a [migration guide](https://api.slack.com/authentication/migration).

> As of December 4th, 2020 Slack no longer accept resubmissions from apps that are not using granular permissions. On November 18, 2021 Slack will start delisting apps that have not migrated to use granular permissions. So you better get going with a migration ASAP.

I found the migration quite challenging for my [many real-time bots](https://www.vestris.com) with existing customers. New bots cannot use real-time, and there's no way to automatically migrate existing installations - users must reinstall a newer version of the bot. I chose to avoid a data migration and picked a path of upgrading the bot to granular permissions, then operating both the old and the new version on top of the same database.

To support migrations I've recently extracted [slack-ruby-bot-server-rtm](https://github.com/slack-ruby/slack-ruby-bot-server-rtm) out of [slack-ruby-bot-server](https://github.com/slack-ruby/slack-ruby-bot-server), and created [slack-ruby-bot-server-events](https://github.com/slack-ruby/slack-ruby-bot-server-events) for handling events with granular permissions. I've also implemented [slack-ruby-bot-server-events-app-mentions](https://github.com/slack-ruby/slack-ruby-bot-server-events-app-mentions) to help migrate existing slack-ruby-bot commands.

> The migration effectively involves replacing `slack-ruby-bot-server-rtm` with `slack-ruby-bot-server-events`.

### Upgrade to Slack-Ruby-Bot-Server 1.2.0 and Slack-Ruby-Bot-Server-Rtm

Upgrade to the latest version of `slack-ruby-bot-server-rtm` , which extracts real-time components. Practically, replace `SlackRubyBotServer::Server` by `SlackRubyBotServer::RealTime::Server`.

Upgrade to `slack-ruby-bot-server` 1.2.0. This version introduces two new `Team` fields, `oauth_version` and `oauth_scope` to store which version of the bot performed the install. This allows slack-ruby-bot-server-rtm to ignore newer bots and only boot RTM for legacy bots.

See [UPGRADING](https://github.com/slack-ruby/slack-ruby-bot-server/blob/master/UPGRADING.md#upgrading-to--120) for more information on ActiveRecord database migrations.

See [slack-shellbot@db40cb59](https://github.com/slack-ruby/slack-shellbot/commit/db40cb592a3416ce1bd04bb04dd5828c33adc6d7) and [slack-shell@bda862ce](https://github.com/slack-ruby/slack-shellbot/commit/bda862ced477d57d720f885703435b1eb3819f0e) for an example.

Deploy your bot and make sure everything is working without any changes.

### Create a New Slack App

In order not to affect existing users, [create a new Slack app](https://api.slack.com/apps) with new granular permissions and scopes. For example, to send messages to Slack you will need `chat:write`. To read messages in public channels, `channels:history`. To receive bot mentions you'll need `app_mentions:read` and to receive DMs, `im:history`.

### Respond to Slack Events

#### App Mentions

A typical bot may want to respond to mentions, which is made very easy by the new [slack-ruby-bot-server-events-app-mentions](https://github.com/slack-ruby/slack-ruby-bot-server-events-app-mentions) gem.

{% highlight ruby %}
SlackRubyBotServer.configure do |config|
  config.oauth_version = :v2
  config.oauth_scope = ['app_mentions:read', 'im:history', 'chat:write']
end
{% endhighlight %}

{% highlight ruby %}
class Ping < SlackRubyBotServer::Events::AppMentions::Mention
  mention 'ping'

  def self.call(data)
    client = Slack::Web::Client.new(token: data.team.token)
    client.chat_postMessage(channel: data.channel, text: 'pong')
  end
end
{% endhighlight %}

See a [complete sample](https://github.com/slack-ruby/slack-ruby-bot-server-events-app-mentions-sample) for more details.

#### Other Messages

More advanced bots may want to handle all kinds of messages. For example, [slack-shellbot#22](https://github.com/slack-ruby/slack-shellbot/pull/22) configures scopes to receive the kitchen sink of events, then handles them carefully avoiding handling its own messages.

{% highlight ruby %}
SlackRubyBotServer.configure do |config|
  config.oauth_version = :v2
  config.oauth_scope = ['chat:write', 'im:history', 'mpim:history', 'channels:history', 'groups:history']
end
{% endhighlight %}

{% highlight ruby %}
SlackRubyBotServer::Events.configure do |config|
  config.on :event, 'event_callback', 'message' do |event|
    # SlackShellbot::Commands::Base.logger.info event

    next true if event['event']['subtype'] # updates, etc.
    next true if event['authorizations'][0]['user_id'] == event['event']['user'] # self

    team = Team.where(team_id: event['team_id']).first
    next true unless team

    data = Slack::Messages::Message.new(event['event'])

    # handles event data here

    true
  end
end
{% endhighlight %}

### Deploy

Create a new app deployment, use the same database as your production bot. I operate my bots on Digital Ocean and follow [this post](/2016/02/08/running-slack-bots-on-digital-ocean-with-dokku.html). The new bot needs a configuration with the `SLACK_CLIENT_ID`, `SLACK_CLIENT_SECRET` and `SLACK_SIGNING_SECRET` from the new app with granular permissions. I use the same database as my old RTM bot. Deploy the new app.

Now there are two versions of the app running on top of the same database: one is the legacy one, and the other is the granular scopes app. The old app will ignore new bot installations that use granular permissions. The new app should ignore any old bot installations. Thus both apps should work.

### Switch DNS

Switch DNS, new bot registrations can use the new granular scopes app. Make sure in Slack the event URLs are configured properly to point to this DNS.

### Slow Migration for Existing Teams

Existing teams can uninstall the old bot and re-install the new one. The old real-time implementation will stop working once the token has been switched, but the data will remain intact and the team will get reactivated using the new bot with granular permissions.

### Upgraded Apps

So far I've upgraded [slack-shellbot](https://github.com/slack-ruby/slack-shellbot). The new version is available at [shell.playplay.io](https://shell.playplay.io).

Leave comments on this migration guide here, or in [slack-ruby-bot-server#134](https://github.com/slack-ruby/slack-ruby-bot-server/issues/134).
