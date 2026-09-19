---
layout: post
title: "Porting a Discord Bot to Microsoft Teams, Entirely With AI"
date: 2026-09-16
tags: [ai, ruby, strava, microsoft-teams]
---

[Slava](https://slava.playplay.io) ([slack-strava](https://github.com/dblock/slack-strava)) connects a Strava account to a chat and posts a card for every activity, complete with map, pace, and elevation, plus commands like connect, disconnect, stats, and leaderboard. In 2023 I ported Slava to Discord by hand, evening by evening over about three weeks, and it took most of that stretch to get a working bot called [Strada](https://strada.playplay.io) ([discord-strava](https://github.com/dblock/discord-strava)). This week I ported the same app to Microsoft Teams as [Strata](https://strata.playplay.io) ([teams-strava](https://github.com/dblock/teams-strava)) in 3 days instead of the 3 weeks the Discord port took, using time carved out during the [Microsoft Global Hackathon](https://www.microsoft.com/en-us/garage/hackathon/). By "I", I mean [GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli) and I.

![Strata posting a Strava activity to a Teams channel](/images/posts/2026/2026-09-16-porting-strata-to-microsoft-teams-entirely-with-ai/activity-card.png)

### The 2023 Baseline

[discord-strava](https://github.com/dblock/discord-strava)'s git history is a fair record of how long a manual port takes. The first commit, "Initial fork from slack-strava," landed July 30, 2023. "Most interactions working" was three days later. Getting install/help/error-handling polish took through August 20:

```
2023-07-30 23:56  Initial fork from slack-strava.
2023-08-02 23:46  Most interactions working.
2023-08-03 06:18  Remove PNG retrieval, Discord displays redirects correctly.
2023-08-03 06:26  Removed clubs.
2023-08-03 08:28  Fixed model specs.
2023-08-03 18:20  Fix API specs.
2023-08-04 19:44  Fix command specs.
...
2023-08-08 10:34  Countinously poll with 1 minute intervals.
2023-08-20 22:59  Improved install button and text.
```

20 commits spread across 9 evenings over roughly three weeks (there's a real job and a life in between those timestamps). All hand-typed, with GitHub Copilot's inline autocomplete helping the way it helped everyone in 2023, but no agent driving the actual porting work.

### The 2026 Port

teams-strava's git history is a single continuous [Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli) session, 107 conversational turns over three calendar days, and the timestamps compress dramatically:

```
2026-09-14 11:05  Initial port of discord-strava to Microsoft Teams
2026-09-14 16:39  Fix local dev setup and personal-scope install handling
2026-09-14 16:43  Fix 400 error replying to personal-scope install notice
2026-09-15 08:29  Document CLI-only local dev workflow in DEV.md
2026-09-15 08:41  Fix Graph permission GUIDs and add missing CLI setup steps in DEV.md
2026-09-15 09:03  Fix Strava webhook subscription errors and threaded channel posts
2026-09-15 09:11  Send the Strava connect link via a private 1:1 message
2026-09-15 09:15  Fix broken help rendering in Teams
2026-09-15 09:18  Revert connect to posting in-channel; drop personal-scope DM for now
2026-09-16 08:33  Document production Azure Bot/Entra setup in DEV.md, fix --endpoint flag
2026-09-16 08:46  Add script/verify_production.rb production sanity check
2026-09-16 08:49  Point manifest at production bot, bump version to 1.0.0
2026-09-16 09:10  Make Strata free during beta and fix homepage app download
2026-09-16 09:16  Fix production NameError: rubyzip is a test-only transitive dependency
2026-09-16 09:26  Fix 'Activity resulted into multiple skype activities' error on update
```

A working bot (connect, disconnect, post activities, help) existed by the end of the first day: five and a half hours elapsed between the first and last commit, but roughly three of those were actually spent hands-on-keyboard, in bursts, with breaks for a normal workday in between.

The next two sessions were where I was genuinely out of my depth: registering an Entra app, wiring up Bot Framework client-credentials auth, building and validating a Teams app manifest, getting the bot into a tenant's app catalog, and eventually standing up a separate production Azure subscription. I'd never touched any of it before this week. Copilot CLI ran the `az` and `m365` CLI commands, read the error messages back to me, and looked things up (multi-tenant bot registration being deprecated, a missing service principal, a renamed `--endpoint` flag) faster than I could have found them myself reading Microsoft Learn cold. That's arguably the bigger win over the 2023 Discord port: not "wrote the Ruby faster" but "got me through an unfamiliar cloud platform's auth and app-distribution model without me having to become an expert in it first." Either way, GitHub Copilot CLI got the whole port done in 3 days instead of the 3 weeks the Discord one took, roughly 7x faster.

Copilot CLI's own [usage tracking](https://docs.github.com/en/copilot/how-tos/copilot-cli) gives a sense of scale for just that first session: 659 API calls, about 272,000 output tokens generated, and roughly 72.8 million input tokens processed, of which about 71 million were cache reads rather than fresh tokens (the CLI re-sends accumulated context on every turn, and prompt caching is what keeps that affordable). That's the token cost of a chatty pair-programming session where the "pair" reads the whole codebase back to itself before every reply. The session started on GPT-5.4 for the first 108 calls, then switched to Claude Sonnet 5 for the remaining 551, model choice is a CLI setting, not something baked into the port.

Copilot CLI usage isn't metered per token, it's included in a Copilot subscription, so there's no invoice to point at. But pricing it out at today's public list prices for comparable models (roughly $3/$15 per million input/output tokens, with cache reads discounted to a fraction of that, cache writes at a slight premium) puts that first session at somewhere around $25-30 of raw model spend, almost all of it cache reads.

### This Isn't a Fair Fight

There's zero reason to still do this kind of work by hand in 2026. Discord's bot API is comparatively simple: a webhook, embeds, slash commands. Microsoft Teams brought its own pile of accidental complexity that the AI had to work through, not around: Bot Framework client-credentials auth against Entra ID, Adaptive Cards instead of embeds, a manifest/app-catalog model for distribution, and Teams Store submission requirements that don't exist for Discord at all. The scope of this port is arguably larger than the 2023 one, and it still took a fraction of the time.

AI of course still makes mistakes:

```ruby
# TeamsStrava::CardRenderer used to render one Adaptive Card per embed
# (activity + one per photo). Teams' update API rejects an activity
# update with more than one attachment:
#
#   400 BadSyntax: "Activity resulted into multiple skype activities"
#
# Fixed by combining every embed into a single card/attachment.
body = embeds.flat_map { |embed| card_body(embed) }
activity.add_card(::Teams::Cards::AdaptiveCard.new(*body)) unless body.empty?
```

```ruby
# rubyzip was only ever required as a transitive, test-only dependency
# of selenium-webdriver, so `zip -j` worked in every spec run and then
# raised NameError: uninitialized constant ...::Zip the first time a
# real user hit the download endpoint in production.
gem 'rubyzip', require: 'zip'
```

Both bugs shipped, passed a full green test suite, and only surfaced against the real Teams API and the real production environment. That's not an argument against AI-driven development, it's an argument for test coverage: when you're merging on green because you trust the AI wrote the code, and largely didn't review every line yourself, your test suite is the only thing standing between a passing build and a broken production. A 574-example spec suite at 87.95% line coverage and a clean rubocop run caught plenty, but no test suite covers what it doesn't know to test, and there's still no substitute for a production smoke test before you tell people the thing works.

### Try It Out

Strata is in beta and not yet listed in the Teams Store, but it's real and running in production. Head to [strata.playplay.io](https://strata.playplay.io) to download the app manifest and sideload it into your own tenant. This is temporary while I go through Teams Store submission; once that's done, installing will be a one-click affair.

### Links

* [teams-strava](https://github.com/dblock/teams-strava) — the new Microsoft Teams bot, install from [strata.playplay.io](https://strata.playplay.io)
* [discord-strava](https://github.com/dblock/discord-strava) — the 2023 manual port this is compared against, install from [strada.playplay.io](https://strada.playplay.io)
* [slack-strava](https://github.com/dblock/slack-strava) — the original, install from [slava.playplay.io](https://slava.playplay.io)
