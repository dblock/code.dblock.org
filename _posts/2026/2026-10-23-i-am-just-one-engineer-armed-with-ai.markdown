---
layout: post
title: I Am Just One Engineer Armed with AI
date: 2026-10-23
tags: [ai, open-source, testing, ruby, rust, javascript]
---

I made 295 pull requests across 49 GitHub repos and did 30 project releases burning ~1.2 billion AI tokens in ten days. I am just one Engineer armed with AI. That is a lot of typing I did not do.

I certainly did not read or write any code.

This is a follow-up to [AI Wants to Eat Your Project Backlog](/2026/10/15/ai-wants-to-eat-your-project-backlog.html), where I described working through old Mongoid issues on two bus rides. I kept going. The work expanded into new spelling tools in three languages, library features, CI maintenance, releases, and application upgrades.

First, let's count what actually happened. Then let's talk about what these numbers mean, or don't.

## The Numbers

These are ten calendar dates, October 14 through October 23, 2026, with a cutoff of October 23 at 1:32 p.m. Eastern.

| measure | count | what it means |
| --- | ---: | --- |
| opened | 295 | authored by `dblock` |
| repositories | 49 | includes forks |
| merged | 257 | of the 295 opened |
| still open | 30 | awaiting review or further work |
| closed unmerged | 8 | includes superseded work and approaches I abandoned |
| all prs merged | 271 | includes 14 older PRs |
| releases | 30 | across 22 repositories |
| issues opened | 27 | new work and follow-ups |

The [complete PR inventory](/downloads/posts/2026-10-23-i-am-just-one-engineer-armed-with-ai/pull-requests.csv) includes every title, repository, URL, status, and category. The [release inventory](/downloads/posts/2026-10-23-i-am-just-one-engineer-armed-with-ai/releases.csv) includes all 30 release links. GitHub's [authored PR search](https://github.com/search?q=author%3Adblock+is%3Apr+created%3A2026-10-14..2026-10-23&type=pullrequests) and [merged PR search](https://github.com/search?q=author%3Adblock+is%3Apr+is%3Amerged+merged%3A2026-10-14..2026-10-23&type=pullrequests) are useful receipts, although their results will keep changing.

## The Work

I assigned every PR to one category based on its repository. This avoids counting a PR three times because it contains a bug fix, tests, and documentation.

| category | opened | merged | open | abandoned |
| --- | ---: | ---: | ---: | ---: |
| mongoid ecosystem | 119 | 97 | 19 | 3 |
| three new spelling tools | 60 | 60 | 0 | 0 |
| hashie | 31 | 27 | 0 | 4 |
| email libraries | 26 | 26 | 0 | 0 |
| danger and maintainer automation | 19 | 17 | 2 | 0 |
| upstream integrations, examples, and this blog | 16 | 6 | 9 | 1 |
| github issue action | 13 | 13 | 0 | 0 |
| bot application upgrades | 11 | 11 | 0 | 0 |
| **total** | **295** | **257** | **30** | **8** |

The work itself fell into several different kinds of engineering: new features, bug archaeology, regression coverage, compatibility testing, performance, API design, documentation, and the boring operational work required to ship. Here are some concrete examples.

## Three Spelling Tools

I've been wanting this one for a long time. When working in a Ruby project I don't want some JavaScript or Python tool and vice-versa. I'm so tired of watching endless installs of the entire world of ecosystems and programming languages just to lint a file. So I built and released [rubocop-spellcheck](https://github.com/dblock/rubocop-spellcheck), [dylint-spellcheck](https://github.com/dblock/dylint-spellcheck), and [markdownlint-rule-spellcheck](https://github.com/dblock/markdownlint-rule-spellcheck) for Ruby, Rust and JavaScript respectively, totaling sixty PRs across the three projects.

These share the same idea: spelling belongs in the lint workflow, with bundled English, explicit project vocabulary, and precise diagnostics.

The Ruby and Rust implementations use Kotoshu. The JavaScript rule uses CSpell. Each has to respect its host's parser, source positions, exclusions, and configuration. YAML front matter strings need different handling from keys or boolean values.

Checking this blog's 618 Markdown files went from over three minutes to 3.69 seconds. The [Ruby spelling post](/2026/10/21/introducing-rubocop-spellcheck.html) has the benchmark details.

The [Rust integration](/2026/10/22/introducing-dylint-spellcheck.html) went into an actual application, `excalc-rs`. The [Markdown integration](/2026/10/22/introducing-markdownlint-rule-spellcheck.html) became an npm package, with [0.2.0](https://github.com/dblock/markdownlint-rule-spellcheck/releases/tag/v0.2.0) using the native front matter API in markdownlint instead of the original workaround.

Building the 3rd JavaScript spellchecker was almost 1-shot, inspired by the first two and I spent most of my effort sweating the shape of the configuration to make the tools extensible and ready for a future onslaught of AI-generated features.

## Features and Releases

Hashie got [lazy property loading](https://github.com/hashie/hashie/pull/636), [key transformation](https://github.com/hashie/hashie/pull/620), [nested pattern searches](https://github.com/hashie/hashie/pull/618), serialization fixes, and executable documentation. I published [5.2.0](https://github.com/hashie/hashie/releases/tag/v5.2.0), then moved the breaking changes into the next major version, 6.0. Hashie is a very popular library, built by 137 contributors and used by 170K projects. AI ate the entire Hashie backlog in a day.

The email libraries got different work: [provider-aware address parsing](https://github.com/dblock/canonical-emails/pull/11), [cached canonical model readers](https://github.com/dblock/canonical-emails/pull/15), and [HTML-to-text parsing with `Nokogiri`](https://github.com/dblock/actionmailer-text/pull/13). Both shipped 0.2.0 releases.

The [create-a-github-issue action](https://github.com/dblock/create-a-github-issue/releases/tag/v3.5.0) got cross-repository issue creation, issue types, reopening, bounded rate-limit retries, exact-title duplicate searches, and workspace template includes. I also [removed unreleased Projects v2 support](https://github.com/dblock/create-a-github-issue/pull/213), rather than ship an API and token-permission story I did not want.

Danger got configurable changelog and table-of-contents checks, provider-aware links, better diagnostics, and release work.

## Maintenance

The mongoid org had fallen behind. I replaced retired coverage integrations, ran actual legacy and modern Mongoid combinations, exercised Rails initialization and reloading, and fixed bugs exposed by those tests.

Examples include [incorrect relevance scores](https://github.com/mongoid/mongoid_search/pull/156), [embedded document ordering](https://github.com/mongoid/mongoid_orderable/pull/92), [history ancestry](https://github.com/mongoid/mongoid-history/pull/279), and [false values disappearing from cached JSON](https://github.com/mongoid/mongoid-cached-json/pull/38). The coverage work included [99.56% for mongoid-rspec across Mongoid 6 and 9](https://github.com/mongoid/mongoid-rspec/pull/263) and [100% line coverage for mongoid-geospatial](https://github.com/mongoid/mongoid-geospatial/pull/79). [81 existing open issues were closed](https://github.com/search?q=org%3Amongoid+is%3Aissue+is%3Aclosed+closed%3A2026-10-14..2026-10-23&type=issues).

## System Upgrades

Eleven Slack, Discord, and Teams bot applications got Ruby 4.0.9 and refreshed dependencies after [new CVEs were published](https://www.ruby-lang.org/en/news/2026/10/23/regexp-fixes-for-gitlab-cves/).

## How Many Tokens?

I asked Copilot to query its own local usage history. I use `auto`. The records cover three top-level sessions and 35 distinct delegated agent contexts during the window. After removing ten duplicated usage records, they contain 10,256 model calls and 1,196,146,380 input-plus-output tokens, with 97.4% of input tokens being cache reads.

| model identifier in local telemetry | calls | input tokens | output tokens | cached input reads |
| --- | ---: | ---: | ---: | ---: |
| `gpt-6.1-sol` | 9,806 | 1,154,324,205 | 3,409,582 | 1,125,723,845 |
| `gpt-6-luna` | 399 | 34,653,956 | 260,782 | 33,225,701 |
| `claude-sonnet-5` | 44 | 3,257,935 | 24,855 | 2,491,423 |
| `claude-opus-5.5` | 7 | 210,846 | 4,219 | 175,767 |
| Total | 10,256 | 1,192,446,942 | 3,699,438 | 1,161,616,736 |

Excluding cache reads leaves 34,529,644 tokens. The separately recorded reasoning count was 841,908.

## The Job

I did this in the background of my day job, taking a look at what's next around lunch, then with more hands on sessions in the evenings. I picked the work, asked whether the reproduction was real, rejected unnecessary abstractions, preserved behavior, separated breaking changes from patch releases, decided that a feature should not ship, reviewed the README and CHANGELOG diffs.

Typing got cheap. Still, the more decisions I made, the more I think I relied on my 35 years of programming experience and familiarity with these libraries and tools to steer AI, which remains valuable.
