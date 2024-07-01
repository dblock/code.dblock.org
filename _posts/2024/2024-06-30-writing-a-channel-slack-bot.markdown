---
layout: post
title: "Writing a Channel Slack Bot with Granular Permissions"
date: 2024-06-30
tags: [ruby, slack]
comments: true
---
In 2020 Slack [introduced granular permissions](https://medium.com/slack-developer-blog/more-precision-less-restrictions-a3550006f9c3) and has begun enforcing that legacy applications use them. I've [previously migrated](/2020/11/30/migrating-classic-slack-ruby-bots-to-granular-permissions.html) a simple bot to use those in-place, but it has come time to rewrite my larger, more complex [S'Up for Slack Teams](https://sup2.playplay.io/) and [GameBot Leaderboard](https://gamebot2.playplay.io/) bots. Furthermore, the previous versions of the bots only allowed one S'Up group and one leaderboard per team, so I decided to take this opportunity to add support for actions and user settings in both DMs and individual channels. 

Here's a rundown of the [code of Slack Gamebot](https://github.com/dblock/slack-gamebot2). It's MIT-licensed, open-source. Install it from [gamebot2.playplay.io](https://gamebot2.playplay.io/).

![]({{ site.url }}/images/posts/2024/2024-06-30-writing-a-channel-slack-bot/everything.gif)

### Components

The bot consists of several major components.

#### Models

The [database models](https://github.com/dblock/slack-gamebot2/tree/main/lib/models) include `Admin` (a Slack user outside of a channel), `Channel`, and `User` (a user that belongs to a Slack channel). While users in Slack are global, my bots store different information for each user in every channel. Other models are specific to the business logic of the bots.

#### Commands

The Slack [commands](https://github.com/dblock/slack-gamebot2/tree/main/lib/commands) are handlers of [mentions from slack-ruby-bot-server-events-app-mentions](https://github.com/slack-ruby/slack-ruby-bot-server-events-app-mentions). In addition to the out-of-the-box functionality provided by that library, I wrapped my commands with [mixins](https://github.com/dblock/slack-gamebot2/blob/main/lib/commands/mixins/) that create or fetch existing user and channel information from the database on every request.

#### APIs

Slack sends events to a set of API endpoints which are implemented using [Grape](https://github.com/ruby-grape/grape) in the [slack-ruby-bot-server-events](https://github.com/slack-ruby/slack-ruby-bot-server-events) library. My bot also exposes a complete [Hypermedia REST API for its own data](https://github.com/dblock/slack-gamebot2/tree/main/lib/api/endpoints). Together these endpoints are [mounted](https://github.com/dblock/slack-gamebot2/blob/main/lib/api/endpoints/root_endpoint.rb#L23) under `/api`.

#### Website

Users first land on an [ERB template website](https://github.com/dblock/slack-gamebot2/tree/main/public) that is [served](https://github.com/dblock/slack-gamebot2/blob/main/lib/api/middleware.rb#L27) using [rack-server-pages](https://github.com/migrs/rack-server-pages).

### Configuration

The bot [configuration](https://github.com/dblock/slack-gamebot2/tree/main/config) includes configuration files for [MongoDB](https://github.com/dblock/slack-gamebot2/blob/main/config/mongoid.yml) and [NewRelic](https://github.com/dblock/slack-gamebot2/blob/main/config/newrelic.yml), as well as various initializers, such as OAuth scopes for [for slack-ruby-bot-server](https://github.com/dblock/slack-gamebot2/blob/main/config/initializers/slack_ruby_bot_server.rb), [Stripe](https://github.com/dblock/slack-gamebot2/blob/main/config/initializers/stripe.rb), and [Giphy](https://github.com/dblock/slack-gamebot2/blob/main/config/initializers/giphy.rb). There's a funny [wrapper for slack-ruby-client](https://github.com/dblock/slack-gamebot2/blob/main/config/initializers/slack_ruby_client.rb) that injects animated GIFs into everything the bot says.

### Bot Startup

The bot starts from [config.ru](https://github.com/dblock/slack-gamebot2/blob/main/config.ru) with `foreman start`. All above-mentioned components are required from [app.rb](https://github.com/dblock/slack-gamebot2/blob/main/app.rb). The code executes pre-start bot actions with `SlackGamebot::App.instance.prepare!`, prepares the API with `SlackRubyBotServer::Service.start!`, and finally runs the middleware that responds to HTTP requests with `run SlackGamebot::Api::Middleware.instance`. Basically, the bot startup ends with exposing a Rack web server on port 5000 when run locally.

### Bot Installation

Users that click "Add to Slack" on the public website are redirected to a Slack OAuth v2 workflow, allow the bot to be installed, and are redirected back with a `code`parameter that is then [`POSTed`](https://github.com/dblock/slack-gamebot2/blob/main/public/js/register.js) to the bot API, which [creates](https://github.com/dblock/slack-gamebot2/blob/main/lib/api/endpoints/teams_endpoint.rb#L41) a `Team`. Slack then begins sending events to the API endpoints.

### Slack Interactions

#### Bot Mentions

Slack sends mention events to the bot which are handled by the [slack-ruby-bot-server-events-app-mentions](https://github.com/slack-ruby/slack-ruby-bot-server-events-app-mentions) library. The payload includes the current user and channel, and the library routes the request to the appropriate command handler. My bot [wraps](https://github.com/dblock/slack-gamebot2/blob/main/lib/commands/mixins/subscribe.rb#L10) mentions in a mixin to check for a valid paid subscription (bots are free to try for 2 weeks) and fetch user and channel information from a database as mentioned above.

#### Members Joining and Leaving Slack Channels

Slack sends events to the bot every time users join or leave a channel, handled by the [slack-ruby-bot-server-events](https://github.com/slack-ruby/slack-ruby-bot-server-events) library. My bot handles that [here, in a callback](https://github.com/dblock/slack-gamebot2/blob/main/lib/events.rb#L17).

#### Users Opening App Home Tab in Slack

This is a special interaction that happens when a user opens the bot home tab, handled [in a callback](https://github.com/dblock/slack-gamebot2/blob/main/lib/events.rb#L47). We want to send a message to the user the first time they do that, so the handler creates a `Channel` and a `User` record and only sends a welcome message if those don't exist.

#### Users Mentioning the Bot without @

This is an interesting pattern that is not natively supported by Slack events. I want users to be able to give the bot aliases. For example, instead of always having to type `@gamebot` (a Slack mention), users can type `pongbot` or `pp`. To implement this, I subscribe the bot to [`message` events](https://api.slack.com/events/message) (requires `channels:history`), [parse](https://github.com/dblock/slack-gamebot2/blob/main/lib/events.rb#L71) every message for one of the known bot names or aliases stored in the database, and hand the results back to the command handlers as if they were typical app mentions.

### Links

Code for Slack GameBot is [here](https://github.com/dblock/slack-gamebot2), and the code for S'Up is [here](https://github.com/dblock/slack-sup2). Try the bots out from [sup2.playplay.io](https://sup2.playplay.io/) and [gamebot2.playplay.io](https://gamebot2.playplay.io/).

