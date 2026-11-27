---
layout: post
title: Naming Claude Code and Copilot Sessions After Their Project
date: 2026-11-27
tags: [ai, open-source]
redirect_from:
  - /2026/11/27/naming-claude-code-sessions-after-their-project.html
---

I run a lot of Claude Code and GitHub Copilot CLI sessions in parallel, and both tools title a session with a summary of its first prompt. That's fine until you have three sessions called something like "improve test sharding performance" and can't tell which project any of them is about.

So I made sessions name themselves after their project, with an emoji. I type "let's add some emojis to our dotfiles" and get `🏠 dotfiles` in either tool.

### Claude Code

<video controls preload="metadata" width="700" style="display: block; margin-bottom: 1.5em;" poster="/images/posts/2026/2026-11-27-naming-claude-code-and-copilot-sessions-after-their-project/claude-session-title.png">
  <source src="/images/posts/2026/2026-11-27-naming-claude-code-and-copilot-sessions-after-their-project/claude-session-title.mp4" type="video/mp4">
</video>

Claude Code [hooks](https://code.claude.com/docs/en/hooks) support this out of the box. A `UserPromptSubmit` hook receives the prompt, and if it prints `hookSpecificOutput.sessionTitle`, that becomes the session title, same as `/rename`. The hook also gets `session_title` when the session already has one, so it only renames on the first prompt and never overrides a manual `/rename`.

```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "sessionTitle": "🧪 testlanes"
  }
}
```

### GitHub Copilot CLI

<video controls preload="metadata" width="700" style="display: block; margin-bottom: 1.5em;" poster="/images/posts/2026/2026-11-27-naming-claude-code-and-copilot-sessions-after-their-project/copilot-session-title.png">
  <source src="/images/posts/2026/2026-11-27-naming-claude-code-and-copilot-sessions-after-their-project/copilot-session-title.mp4" type="video/mp4">
</video>

Copilot CLI [hooks](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/use-hooks) can't set a title; a `userPromptSubmitted` hook can only add context for the model. The agent, however, can rename its own session with `rename_session` once you enable the session management tools. The tool leaves user-chosen names alone.

```bash
copilot config sessionManagementTools.scope in-process
copilot config sessionManagementTools.enabled on
```

So the two meet halfway. On the first prompt of a session, [a hook](https://github.com/dblock/dotfiles/blob/master/agents/copilot/hooks/session-title/session-title.sh) runs the same title script as Claude Code and hands the agent the exact name.

```json
{"additionalContext": "Before anything else, call rename_session with name \"🧪 testlanes\". Do not mention the rename. If rename_session is unavailable or leaves the name unchanged, continue without it."}
```

The name is computed outside the model, and the model's only job is one tool call. The hook remembers which sessions it has seen, so later prompts and resumed sessions are left alone. Starting a session with `/new speed up the testlanes CI` works too, which is how the third session in the video begins. It's still best effort until Copilot lets hooks set the title directly, and non-interactive `-p` runs, which don't have the tool, skip it.

### Picking the Name

Both hooks call [one shared bash script](https://github.com/dblock/dotfiles/blob/master/agents/session-title/session-title.sh) that prints a name, picked in this order.

1. A project under `~/source` mentioned in the prompt, longest match first, so "excalc-rs" beats "excalc". Repos inside organization folders count, while `master`, `upstream-*`, and `dblock-*` checkouts don't.
2. The project of the working directory.
3. Otherwise, Haiku writes a short topic, such as `🔊 loud-laptop-fan`.

Names are lowercase and hyphenated, because that's how I name things. Haiku picks an emoji the first time a project shows up, and it's cached, so `testlanes` is always `🧪`. I pin the ones I care about in [`session-emojis.txt`](https://github.com/dblock/dotfiles/blob/master/agents/session-title/session-emojis.txt). The list of ~380 projects is cached too, so a cached run takes 40ms.

### Asking Haiku From a Hook

The shared script doesn't know about either tool; each hook hands it a command that asks Haiku. In Claude Code, that's `claude -p --model haiku`, which starts a new Claude Code session, which runs the same hook, which calls `claude -p`, and so on. The `--bare` flag skips hooks, but it only accepts an API key and I sign in with OAuth. The fix is to disable hooks for the nested call and not save it as a session.

```bash
claude -p --model haiku --no-session-persistence --settings '{"disableAllHooks":true}' --tools ""
```

Copilot CLI can ask Haiku too, but it has no flag to skip hooks or saving the session, so [its helper](https://github.com/dblock/dotfiles/blob/master/agents/copilot/hooks/session-title/ask-haiku.sh) runs it in a throwaway `COPILOT_HOME` with no tools. The sign-in lives in the keychain, so it still works.

```bash
COPILOT_HOME="$(mktemp -d)" copilot -p "$question" -s --model claude-haiku-4.5 --available-tools "" --no-custom-instructions
```

### Receipts

The [shared script](https://github.com/dblock/dotfiles/blob/master/agents/session-title/session-title.test.sh) is tested against a fake `~/source` and a fake model, and the [Claude](https://github.com/dblock/dotfiles/blob/master/agents/claude/hooks/session-title/session-title.test.sh) and [Copilot](https://github.com/dblock/dotfiles/blob/master/agents/copilot/hooks/session-title/session-title.test.sh) hooks against a fake title script. The videos were recorded with [VHS](https://github.com/charmbracelet/vhs) from tapes saved next to the hooks, with the demo sessions in plan mode so they couldn't go and actually add emojis to my dotfiles. The Copilot ones get one more demo-only instruction: after renaming, say in a sentence what you'd look at first, and stop. That shows each session picking up its request, such as "Starting: I'll look at testlanes' CI workflows and test setup first", without letting it loose.

It's all in my dotfiles: [the Claude Code hook](https://github.com/dblock/dotfiles/commit/7d2ce562512ae56d1b636521e9104f971f909842), [the Copilot hook](https://github.com/dblock/dotfiles/commit/f3adf0b7d3e6edbfb15af121315a6bd222c2440b), and [the shared script](https://github.com/dblock/dotfiles/commit/2af6bee1aaedc56e75e57c3ff69dcfeb810a9195). Copy them, change `~/source` to wherever you keep your code, and pick your own emojis.
