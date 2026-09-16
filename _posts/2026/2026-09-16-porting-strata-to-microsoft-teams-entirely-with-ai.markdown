---
layout: post
title: "Porting a Discord Bot to Microsoft Teams, Entirely With AI"
date: 2026-09-16
tags: [ai, ruby, strava, microsoft-teams]
comments: true
---

In 2023 I ported [slack-strava](https://github.com/dblock/slack-strava) to Discord by hand, evening by evening over about three weeks, and it took most of that stretch to get a working bot. This week I ported the same app to Microsoft Teams as [teams-strava](https://github.com/dblock/teams-strava) ("Strata"), and this time I wrote almost none of the code myself. [GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli) did.

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

A working bot (connect, disconnect, post activities, help) existed by the end of the first afternoon, roughly five and a half hours, most of which was me reading diffs and answering clarifying questions, not typing Ruby. The next two sessions, under an hour each, hardened it: a real Azure production deployment in a separate subscription, Teams Store submission prep, self-service sideloading, and a beta pricing pivot.

Copilot CLI's own [usage tracking](https://docs.github.com/en/copilot/how-tos/copilot-cli) gives a sense of scale for just that first session: 659 API calls, about 272,000 output tokens generated, and roughly 72.8 million input tokens processed, of which about 71 million were cache reads rather than fresh tokens (the CLI re-sends accumulated context on every turn, and prompt caching is what keeps that affordable). That's the token cost of a chatty pair-programming session where the "pair" reads the whole codebase back to itself before every reply. The session started on GPT-5.4 for the first 108 calls, then switched to Claude Sonnet 5 for the remaining 551, model choice is a CLI setting, not something baked into the port.

### This Isn't a Fair Fight, and That's the Point

I want to be upfront that this comparison isn't apples-to-apples. Discord's bot API is comparatively simple: a webhook, embeds, slash commands. Microsoft Teams brought its own pile of accidental complexity that the AI had to work through, not around: Bot Framework client-credentials auth against Entra ID, Adaptive Cards instead of embeds, a manifest/app-catalog model for distribution, and Teams Store submission requirements that don't exist for Discord at all. The scope of this port is arguably larger than the 2023 one, and it still took a fraction of the time.

Nor was the AI infallible. Two bugs from this week are worth calling out because they're exactly the kind of thing you'd expect a human to miss under similar time pressure, not because the AI was careless:

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

Both bugs shipped, passed a full green test suite, and only surfaced against the real Teams API and the real production environment. A 574-example spec suite and a clean rubocop run kept the AI honest about regressions, but they're not a substitute for hitting `send` against Microsoft's actual servers. It's not that AI writes bad code, it's the same lesson as every other engineering team learns eventually: tests validate what you thought to test, and there's no substitute for a production smoke test before you tell people the thing works.

### Links

* [teams-strava](https://github.com/dblock/teams-strava) — the new Microsoft Teams bot
* [discord-strava](https://github.com/dblock/discord-strava) — the 2023 manual port this is compared against
* [slack-strava](https://github.com/dblock/slack-strava) — the original
* [GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli)
