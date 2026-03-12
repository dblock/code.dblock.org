---
layout: post
title: "AI Slop: A Slack API Rate Limiting Disaster"
date: 2026-03-12
tags: [ai, api, rate-limiting, slack]
comments: true
---

Yesterday I [described]({{ site.url }}/2026/03/11/right-sizing-engineering-teams-for-ai.html) AI-generated code as "plausible-looking, locally coherent, globally wrong." Here's a concrete example from my own codebase.

I needed a cleanup job to close old Slack group DM conversations in my [slack-sup2](https://github.com/dblock/slack-sup2) app. The AI-generated solution looked perfectly reasonable:

```ruby
def close_old_sups!
  return 0 unless sup_close
  
  old_sups = sups.where(conditions)
  old_sups.each(&:close!)
  old_sups.count
end

def close!
  return unless conversation_id
  return if closed_at
  
  logger.info "Closing DM channel #{conversation_id}..."
  slack_client.conversations_close(channel: conversation_id)
  update_attributes!(closed_at: Time.now.utc)
end
```

This code looks pretty great and completely breaks the app. Slack's API has a [global rate limit of 1 request per second](https://api.slack.com/docs/rate-limits) for the `conversations.close` endpoint. So, when this job runs against a workspace with hundreds of old conversations, it immediately hits the rate limit. Worse, because rate limits are global across all endpoints, it takes down the entire application. Every other API call — posting messages, fetching user info, everything — starts failing.

I asked AI to address this. It made the fix catastrophically worse.

```ruby
def close!
  # ... existing code ...
  begin
    slack_client.conversations_close(channel: conversation_id)
  rescue Slack::Web::Api::Errors::TooManyRequests => e
    sleep_time = e.retry_after || 60
    sleep(sleep_time)
    retry
  end
  # ... rest of method ...
end
```

In [socketry/async](https://github.com/socketry/async), `sleep()` blocks the entire fiber and prevents other concurrent operations from executing. You should use `Async::Task.sleep()` instead, but that still doesn't solve the fundamental architectural problem of making hundreds of sequential API calls.

What made this particularly insidious is that the assistant wrote some pretty professional-looking code and seemingly handled obvious edge cases. Yet, it failed to consider the distributed system constraints or global invariants. The rate limiting problem wasn't visible in the local scope of the method - it was a system-wide concern that required human judgment.

So, how did I actually fix the problem? I used the initial A.I. implementation ([4c11b3a0](https://github.com/dblock/slack-sup2/pull/93/changes/4c11b3a01e795d23ae6742fc868229ee4d32a9af)), but moved the task into the 30 minute cron to avoid triggering global rate limits ([ab9e9518](https://github.com/dblock/slack-sup2/pull/93/changes/ab9e9518c1992fe76d7c8563a318a699bd84eddc)). I then put the feature behind a setting that is off by default and wrote a script to slow-drain the many thousands of unclosed DM channels for existing customers ([9feabd2c](https://github.com/dblock/slack-sup2/pull/93/changes/9feabd2c8fdea79e8e02e6e38c19b9b6517e76ee)). Finally, I ... ahem ... Copilot refactored the code to auto-close a limited number of DMs at any given time to avoid the rate limit altogether ([#94](https://github.com/dblock/slack-sup2/pull/94)).

For now, human oversight of A.I. assistants remains critical.
