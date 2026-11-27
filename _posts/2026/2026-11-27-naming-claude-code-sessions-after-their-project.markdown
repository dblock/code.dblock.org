---
layout: post
title: Naming Claude Code Sessions After Their Project
date: 2026-11-27
tags: [ai, open-source]
---

I run a lot of Claude Code sessions in parallel, and the agent view (`claude agents`) is where I spend my day. By default, Claude Code titles each session with a short summary of its first prompt, written by Haiku. That's fine until you have three sessions called something like "improve test sharding performance" and you can't tell which project any of them is about.

So I asked Claude to make sessions name themselves after the project, with an emoji. I type "let's add some emojis to our dotfiles" and get `🏠 dotfiles`.

<video controls preload="metadata" width="700" style="display: block; margin-bottom: 1.5em;" poster="/images/posts/2026/2026-11-27-naming-claude-code-sessions-after-their-project/session-title.png">
  <source src="/images/posts/2026/2026-11-27-naming-claude-code-sessions-after-their-project/session-title.mp4" type="video/mp4">
</video>

### Implementation

Claude Code [hooks](https://code.claude.com/docs/en/hooks) can do this out of the box. A `UserPromptSubmit` hook receives the prompt, and if it prints `hookSpecificOutput.sessionTitle`, that becomes the session title, same as `/rename`. The hook also gets `session_title` when the session already has one, so it only renames on the first prompt and never fights with a manual `/rename`.

```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "sessionTitle": "🧪 testlanes"
  }
}
```

The hook is [a bash script](https://github.com/dblock/dotfiles/blob/master/agents/claude/hooks/session-title/session-title.sh) that picks a name in this order.

1. A project under `~/source` mentioned in the prompt, longest match first, so "excalc-rs" beats "excalc". My checkouts live in a few different layouts (`~/source/testlanes/master`, `~/source/mongoid/mongoid_fulltext/upstream-mongoid_fulltext`), so top-level folders and the repos inside organization folders count as projects, while `master`, `upstream-*`, and `dblock-*` checkouts don't.
2. The project of the working directory.
3. Otherwise, Haiku writes a short topic, such as `🔊 loud-laptop-fan`.

Names are always lowercase and joined by hyphens, because that's how I name things.

The emoji is picked by Haiku the first time a project shows up, and cached in `~/.cache/claude-session-title/emojis.txt`, so `testlanes` is always `🧪` and `gmail-toggle` is always `📧`. I pin the ones I care about in a [`session-emojis.txt`](https://github.com/dblock/dotfiles/blob/master/agents/claude/hooks/session-title/session-emojis.txt) file. The list of ~380 projects is cached too, so a cached run takes 40ms.

### Calling Claude from a Claude Hook

Asking Haiku from inside a hook is `claude -p --model haiku`, which starts a new Claude Code session, which runs the same `UserPromptSubmit` hook, which calls `claude -p`, and so on. The obvious `--bare` flag skips hooks, but it only accepts an API key and I sign in with OAuth. The fix is to disable hooks for the nested call and not save it as a session.

```bash
claude -p --model haiku --no-session-persistence --settings '{"disableAllHooks":true}' --tools ""
```

The script also exits early when it sees `SESSION_TITLE_NESTED`, just in case.

### Receipts

The hook comes with [a test script](https://github.com/dblock/dotfiles/blob/master/agents/claude/hooks/session-title/session-title.test.sh) that runs it against a fake `~/source` and a fake `claude` that answers 🦀 to everything. The video above was recorded with [VHS](https://github.com/charmbracelet/vhs) from [a tape](https://github.com/dblock/dotfiles/blob/master/agents/claude/hooks/session-title/session-title.tape), with the demo sessions in plan mode so they couldn't go and actually add emojis to my dotfiles.

The whole thing is [one commit in my dotfiles](https://github.com/dblock/dotfiles/commit/7d2ce562512ae56d1b636521e9104f971f909842). Copy it, change `~/source` to wherever you keep your code, and pick your own emojis.
