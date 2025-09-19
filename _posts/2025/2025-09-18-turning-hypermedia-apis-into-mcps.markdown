---
layout: post
title: Turning Hypermedia APIs into MCPs
date: 2025-09-18 09:00:00
tags: [ai, mcp, hypermedia]
---
I've [written](https://code.dblock.org/2014/07/18/serving-hypermedia-with-a-grape-api-and-roar.html) and [talked](https://www.slideshare.net/slideshow/designing-a-hypermedia-api-with-grape-roar/41151492) extensively about Hypermedia APIs for about a decade. The [HATEOAS](https://en.wikipedia.org/wiki/HATEOAS) constraints in representing resources for a RESTful API has numerous advantages in API design, readability, discoverability, and performance over a hand-rolled REST API. Unfortunately, adoption of Hypermedia APIs is very low compared to, for example GraphQL, but I find the implementation a lot simpler and continue adding Hypermedia APIs to my pet projects.

At its root a Hypermedia API looks like so.

```json
{
  "_links": {
    "self": {
      "href": "https://sup2.playplay.io/api"
    },
    "status": {
      "href": "https://sup2.playplay.io/api/status"
    },
    "team": {
      "href": "https://sup2.playplay.io/api/teams/{id}",
      "templated": true
    },
    ...
  }
}
```

The above example is an extract from [this API](https://sup2.playplay.io/api). For this post we will use [one of my Slack bots called S'Up](https://sup2.playplay.io/), which generates fresh triads of team members in Slack to meet for coffee every week in an informal standup. The bot is [open-source](https://github.com/dblock/slack-sup2) and you can try it [here](https://sup2.playplay.io/).

Because the Hypermedia API structure is fixed with only "resources" and "links" (and similar to API frameworks such as GraphQL) you don't need an application-specific client to interact with the API. In Ruby, the most popular generic Hypermedia client is [Hyperclient](https://github.com/codegram/hyperclient).

With the API above, a client can retrieve the bot status, and using an API token obtained from an existing installation some team information.

```ruby
api = Hyperclient.new('https://sup2.playplay.io/api') do |client|
  client.headers['X-Access-Token'] = ENV.fetch('TOKEN', nil)
end

status = api.status
puts "Bot is #{status.ping['presence']['presence']}."

team = api.team(id: '1234')
puts "Team name is '#{team.name}'."
```

This will output _"Bot is online."_ and _"Team name is 'dblock'."_ for my installation.

In this case, the generic client knew nothing about "team" - it was discovered programmatically and was, in a way, self-documenting. Unsurprisingly, this idea of templated resources is reused almost exactly the same way in the model context protocol (MCP). Therefore, we can easily turn any Hypermedia API into an MCP server generically with a new gem called [hyperclient-mcp](https://github.com/dblock/hyperclient-mcp).

```bash
gem install hyperclient-mcp
1 gem installed
```

Start by using the command-line `hyperclient-mcp` to discover resources.

```bash
$ hyperclient-mcp --api=https://sup2.playplay.io/api resources

Hyperclient::Mcp::Resources::Root
Hyperclient::Mcp::Resources::Status
Hyperclient::Mcp::Resources::Subscriptions
Hyperclient::Mcp::Resources::CreditCards
Hyperclient::Mcp::Resources::Teams
Hyperclient::Mcp::Resources::Channels
Hyperclient::Mcp::Resources::Users
Hyperclient::Mcp::Resources::Rounds
Hyperclient::Mcp::Resources::Sups
Hyperclient::Mcp::Resources::Stats
Hyperclient::Mcp::Resources::User
Hyperclient::Mcp::Resources::Channel
Hyperclient::Mcp::Resources::Team
Hyperclient::Mcp::Resources::Round
Hyperclient::Mcp::Resources::Sup
Hyperclient::Mcp::Resources::Data2
```

Then run the MCP server.

```bash
hyperclient-mcp --api=https://sup2.playplay.io/api --header X-Access-Token=$TOKEN start

Listening on http://0.0.0.0:9292
```

Add the MCP to Claude.

```bash
claude mcp add --transport sse local http://127.0.0.1:9292/mcp/sse
```

Ensure it works.

```bash
$ claude mcp list
Checking MCP server health...

local: http://127.0.0.1:9292/mcp/sse (SSE) - ✓ Connected
```

Try `claude` with _"use the local mcp and find out the bot status"_ or _"use the local mcp to find the name of the team with ID 1234"_.

![]({{ site.url }}/images/posts/2025/2025-09-18-turning-hypermedia-apis-into-mcps/mcp.gif)

While this was interesting, Claude actually supports Hypermedia APIs natively. It might need help with passing the access token, which can be forced by telling to _"just use curl"_. YMMV.

```bash
╭───────────────────────────────────────────────────╮
│ ✻ Welcome to Claude Code!                         │
│                                                   │
│   /help for help, /status for your current setup  │
│                                                   │
│   cwd: /Users/dblock/source/hyperclient-mcp       │
╰───────────────────────────────────────────────────╯

> given a hypermedia api in https://sup2.playplay.io/api what are available resources

⏺ I'll help you discover the available resources in the hypermedia API at https://sup2.playplay.io/api.

⏺ Fetch(https://sup2.playplay.io/api)
  ⎿  Received 1.4KB (200 OK)

⏺ The hypermedia API at https://sup2.playplay.io/api provides the following resources:

  Collection Resources:
  - Status - API status endpoint
  - Subscriptions - Subscription management
  - Credit Cards - Payment method management
  - Teams - Team collections with filtering
  - Channels - Channel collections with filtering
  - Users - User collections with filtering
  - Rounds - Round collections with filtering
  - Sups - Sup collections with filtering
  - Stats - Statistics with filtering

  Individual Resources:
  - User - Individual user by ID
  - Channel - Individual channel by ID
  - Team - Individual team by ID
  - Round - Individual round by ID
  - Sup - Individual sup by ID
  - Data - Individual data by ID

  Most collection endpoints support query parameters like cursor, size, sort, offset, total_count, and
  filtering by team_id, channel_id, round_id, and active status.

> find out the bot status

⏺ Fetch(https://sup2.playplay.io/api/status)
  ⎿  Received 378 bytes (200 OK)

⏺ The bot status shows:

  Authentication: ✅ Connected
  - Team: dblock
  - User: sup2

  Presence: 🔴 Away
  - Online: No
  - Connection count: 0
  - Manual away: No
  - Auto away: No

  The bot is authenticated but currently offline/away with no active connections.

> find the name of the team with ID 1234

⏺ Bash(curl -H "X-Access-Token: ...."
      https://sup2.playplay.io/api/teams/...)
  ⎿ {"id":"...","team_id":"T04KB5WQH","name":"dblock","active":true,                   
    "subscribed":true,"created_at":"2023-03-15T22:46:33.517Z","updated_at":"2025-09-10T14:17:18.698Z","_l
    inks":{"channels":{"href":"https://sup2.playplay.io/api/channels?team_id=..."},"
    … +6 lines (ctrl+o to expand)

⏺ dblock
```

Hyperclient-mcp is [on GitHub](https://github.com/dblock/hyperclient-mcp).
