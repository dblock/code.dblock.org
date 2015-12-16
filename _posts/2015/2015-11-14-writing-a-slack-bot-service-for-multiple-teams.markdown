---
layout: post
title: "Writing a Slack Bot Service for Multiple Teams"
date: 2015-11-14
tags: [slack, api]
comments: true
---
![slack platform]({{ site.url }}/images/posts/2015/2015-11-14-writing-a-slack-bot-service-for-multiple-teams/platform.png)

_Note: This post has been updated with Slack Button integration since the launch of the [Slack Developer Platform](https://medium.com/slack-developer-blog/launch-platform-114754258b91#.od3y71dyo)._

The [slack-ruby-bot gem](https://github.com/dblock/slack-ruby-bot) lets you roll out a bot for your team, but used to recommend a global Slack token configuration. How do we turn it into a full Slack bot service for multiple teams? How can we get a Slack Button to let teams install our service?

tl;dr Check out [github.com/dblock/slack-bot-server](https://github.com/dblock/slack-bot-server).

![demo]({{ site.url }}/images/posts/2015/2015-11-14-writing-a-slack-bot-service-for-multiple-teams/demo.gif)

### Concurrency in Slack-Ruby-Client

The initial implementation of Slack Real Time API support in [slack-ruby-client](https://github.com/dblock/slack-ruby-client) used [EventMachine](https://github.com/eventmachine/eventmachine) and embedded the run loop deeply inside the client itself. That helped users not worry about simple integration scenarios, but prevented you from instantiating multiple instances of `Slack::RealTime::Client`, which would require one global run loop. With the upcoming 0.5.0 release slack-ruby-client supports different concurrency models, including [Celluloid](https://github.com/celluloid/celluloid) or no concurrency at all. The latter effectively defers the implementation to the caller, which is what you want for a bot service.

### Multiple Slack Bots

The next hurdle is instantiating multiple instances of actual bots. Until now the implementation of [slack-ruby-bot](https://github.com/dblock/slack-ruby-bot) defined an easy-to-use `SlackRubyBot::App`, a singleton. With the upcoming 0.5.0 release I've extracted `SlackRubyBot::Server`, that can be instantiated multiple times.

Furthermore, the implementation now relies on websocket events to keep the bot up, restarting it as necessary. This means any single instance of `SlackRubyBot::Server` will survive everything from disconnects to having an integration disabled in the Slack UI, retrying a connection every 60 seconds or so without ever giving up.

### A Service to add Tokens

In order to maintain multiple bot servers you need a registry. I chose to make something simple, [SlackRubyBot::Service](https://github.com/dblock/slack-bot-server/blob/master/app/service.rb) that uses a lock for thread safety and adds instances of `SlackRubyBot::Service` to a `Hash`, with the API token as key. You can `SlackRubyBot::Service.start!(token)` and `SlackRubyBot::Service.stop!(token)`.

### A Web Interface and an API

The bot server isn't useful without a bit of UI. I implemented a [Grape API](https://github.com/dblock/slack-bot-server/tree/master/api) with some basic CRUD using MongoDB to store API tokens, along with a page that uses JQuery to add and remove new integrations.

### Slack Button Integration

To enable Slack button integration, I followed [Create a New Application](https://api.slack.com/applications/new) on Slack, noting the client ID and secret. The UI gives you the HTML code for a slack button. When a user clicks on the button they and OAuth completes successfully they are redirected back to your application with a `code` in the query string. That code is POSTed to Slack via the [Web API's oauth.access](https://api.slack.com/methods/oauth.access) which returns an actual API token that can be used with a Real Time API client.

![register]({{ site.url }}/images/posts/2015/2015-11-14-writing-a-slack-bot-service-for-multiple-teams/new.png)

### Your Turn

You can use [slack-bot-server](https://github.com/dblock/slack-bot-server) as a boilerplate to roll out a full Slack bot service to multiple teams. And hopefully Slack will soon make it easy to register a bot integration with a few clicks without having to ever copy-paste tokens.

### Source Code

Everything can be found at [github.com/dblock/slack-bot-server](https://github.com/dblock/slack-bot-server).

### Similar Projects

* [github.com/exciting-io/slack-bot-server](https://github.com/exciting-io/slack-bot-server): A server for running multiple slack bots using a Redis queue.
