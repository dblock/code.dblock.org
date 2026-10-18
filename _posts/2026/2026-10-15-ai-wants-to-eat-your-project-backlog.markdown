---
layout: post
title: AI Wants to Eat Your Project Backlog
date: 2026-10-15
tags: [ai, open-source, ruby, testing]
---

You can clear the backlog of your open-source projects with AI now. It's really great at reproducing bugs, implementing reasonable features, adding the tests you never had time to write, and responding to user issues that have been open forever.

Copilot and I worked through a dozen projects in the [Mongoid organization](https://github.com/mongoid) on two 4-hour bus rides to visit my son in college (go Lions!). I picked the work, questioned the implementations, reviewed the results, and merged changes. The agent did all the typing, archaeology, environment setup, and testing.

The most satisfying result was an issue about MongoDB sharding that had been open since September 2013: [mongoid-locker #19](https://github.com/mongoid/mongoid-locker/issues/19) reported that acquiring a lock failed on collections sharded by `_id`. The original discussion included _"not sure how easy it will be to replicate that in a test environment"_.

That is exactly the kind of issue that becomes permanent. You need a MongoDB configuration server, a shard, replica sets, a router, the right collection configuration, and enough understanding of all of them to know whether your test is testing anything. You also need to find the motivation to do this for somebody else's production problem.

Copilot opened [PR #112](https://github.com/mongoid/mongoid-locker/pull/112) in under four minutes. The result was a real sharded-cluster integration test. A Docker bootstrap started a configuration-server replica set, a shard replica set, and `mongos`. The tests checked that they were talking to the router, explicitly sharded a collection by ranged and hashed `_id`, and exercised lock acquisition, contention, expiration, release, and cleanup when the block raised an exception. CI ran the tests against MongoDB 6.0 and 8.0. The PR did not reproduce the problem, so [PR #114](https://github.com/mongoid/mongoid-locker/pull/114) tried again with dependencies available when the issue was reported. That built Ruby 2.0.0p247 with MongoDB 2.4.6, Mongoid 3.1.0, and the published mongoid-locker 0.2.1. This time we used two shards and verified that each sharded collection actually had documents on both, rather than trusting the configuration. The failure still didn't reproduce - the issue reported had likely nothing to do with sharding.

An issue that used to mean _"I need to spend an afternoon remembering how to set up MongoDB sharding"_ now means _"I need to review whether this is a meaningful test."_

Those are very different backlogs.

In total I was able to [close 81 issues](https://github.com/search?q=org%3Amongoid+is%3Aissue+is%3Aclosed+closed%3A2026-10-14..2026-10-18&type=issues) and merge [101 PRs](https://github.com/search?q=org%3Amongoid+is%3Apr+is%3Amerged+merged%3A2026-10-14..2026-10-18&type=pullrequests) across 17 repositories. These fell roughly into the following categories: modernized CI through Ruby 4.0, Mongoid 9, and MongoDB 8.0, retaining representative legacy combinations (17 PRs), replaced retired coverage integrations with SimpleCov and Coveralls reporting (11 PRs), expanded behavior and integration coverage, including real legacy/modern driver runs, Rails reloading, and fixes exposed by the tests (17 PRs), modernized Danger workflows and automated PR/changelog checks (7 PRs), cleaned up historical changelogs, linting, gem metadata, and overcomplicated version tests (8 PRs), and added features, fixed bugs, refactored implementation, and documented or reproduced reported behavior (42 PRs).

Where to Start?

Pick an old issue. Ask the agent to reproduce it against the current release. Require a real test. If it is already fixed, preserve the reproduction as regression coverage where useful. If the feature is reasonable, implement it. If it isn't, explain why and close it. If that works well, ask AI to go over all the open issues and feature requests and work on them (it will know what to do).

The same applies when you're the person reporting a bug or asking for a feature. Come with a PR: a failing test that reproduces the bug and a proposed fix, or an implementation that demonstrates the feature you want. Use an agent to investigate, run the tests yourself, and explain what you verified. There is little reason to defer all that work to an open-source maintainer when you can do it where the need originated. Maintainers are here to exercise taste, not to clear tickets.
