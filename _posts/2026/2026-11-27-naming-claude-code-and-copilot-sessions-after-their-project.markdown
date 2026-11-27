---
layout: post
title: Naming Claude Code and Copilot Sessions After Their Project
date: 2026-11-27
tags: [ai, open-source]
redirect_from:
  - /2026/11/27/naming-claude-code-sessions-after-their-project.html
---

I run a lot of Claude Code and GitHub Copilot CLI sessions in parallel, and both tools title a session with a summary of its first prompt. That's fine until you have three sessions called something like "improve test sharding performance" and can't tell which project any of them is about.

So I wrote [agent-baby-names](https://github.com/dblock/agent-baby-names), a plugin for both tools that names a session after its project, with an emoji. I type "let's add some emojis to our dotfiles" and get `🏠 dotfiles` in either tool. It's in [my marketplace](https://github.com/dblock/agent-marketplace).

```bash
claude plugin marketplace add dblock/agent-marketplace
claude plugin install agent-baby-names@dblock

copilot plugin marketplace add dblock/agent-marketplace
copilot plugin install agent-baby-names@dblock
```

Out of the box it names a session after the Git repository it runs in, without asking a model. The names in this post come from a list of strategies in `~/.config/agent-baby-names/config.json`.

```json
{
  "strategy": ["git-clone", "topic", "emoji"]
}
```

### Claude Code

<video controls preload="metadata" width="700" style="display: block; margin-bottom: 1.5em;" poster="/images/posts/2026/2026-11-27-naming-claude-code-and-copilot-sessions-after-their-project/claude-session-title.png">
  <source src="/images/posts/2026/2026-11-27-naming-claude-code-and-copilot-sessions-after-their-project/claude-session-title.mp4" type="video/mp4">
</video>

Claude Code [hooks](https://code.claude.com/docs/en/hooks) support this out of the box. A `UserPromptSubmit` hook receives the prompt, and if it prints `hookSpecificOutput.sessionTitle`, that becomes the session title, same as `/rename`. The hook also gets `session_title` when the session already has one, so [the plugin's hook](https://github.com/dblock/agent-baby-names/blob/v0.1.0/hosts/claude/hook.sh) only names a session on its first prompt and never overrides a manual `/rename`.

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

So the two meet halfway. On the first prompt of a session, [the plugin's Copilot hook](https://github.com/dblock/agent-baby-names/blob/v0.1.0/hosts/copilot/hook.sh) picks the name the same way as in Claude Code and hands the agent the exact name.

```json
{"additionalContext": "Before anything else, call rename_session with name \"🧪 testlanes\". Do not mention the rename. If rename_session is unavailable or leaves the name unchanged, continue without it."}
```

The name is computed outside the model, and the model's only job is one tool call. The hook remembers which sessions it has seen, so later prompts and resumed sessions are left alone. Starting a session with `/new speed up the testlanes CI` works too, which is how the third session in the video begins. It's still best effort until Copilot lets hooks set the title directly, and non-interactive `-p` runs, which don't have the tool, skip it. Copilot CLI also runs plugin hooks only in folders you have trusted.

### Picking the Name

Both hooks call [the same core](https://github.com/dblock/agent-baby-names/blob/v0.1.0/bin/agent-baby-names), which runs the configured [strategies](https://github.com/dblock/agent-baby-names#built-in-strategies) in order. Each strategy gets the name so far and keeps it or changes it, so `["git-clone", "topic", "emoji"]` works like this.

1. [`git-clone`](https://github.com/dblock/agent-baby-names/blob/v0.1.0/docs/strategies/git-clone.md) looks for a checkout under `~/source` mentioned in the prompt, else the checkout of the working directory. A checkout is named after its `origin` remote, so the `master` checkout, a fork, and other working copies of one repo all get the same name.
2. Otherwise, [`topic`](https://github.com/dblock/agent-baby-names/blob/v0.1.0/docs/strategies/topic.md) has Haiku write a short topic, such as `loud-laptop-fan`.
3. [`emoji`](https://github.com/dblock/agent-baby-names/blob/v0.1.0/docs/strategies/emoji.md) puts an emoji in front, such as `🔊 loud-laptop-fan`.

Names are lowercase and hyphenated, because that's how I name things. Haiku picks an emoji the first time a project shows up, and it's cached, so `testlanes` is always `🧪`. I pin the ones I care about in a file of `<name> <emoji>` lines. The list of ~380 checkouts is cached too, so a cached run is fast. A strategy is any executable that reads JSON and prints a name, so you can [write your own](https://github.com/dblock/agent-baby-names/blob/v0.1.0/docs/strategies/custom.md).

### Asking Haiku From a Hook

The strategies don't know about either tool; they ask [a helper](https://github.com/dblock/agent-baby-names/blob/v0.1.0/lib/ask) that asks the small model of whichever tool ran the hook. In Claude Code, that's `claude -p --model haiku`, which starts a new Claude Code session, which runs the same hook, which calls `claude -p`, and so on. The `--bare` flag skips hooks, but it only accepts an API key and I sign in with OAuth. The fix is to disable hooks for the nested call and not save it as a session.

```bash
claude -p --model haiku --no-session-persistence --settings '{"disableAllHooks":true}' --tools ""
```

Copilot CLI can ask Haiku too, but it has no flag to skip hooks or saving the session, so the helper runs it in a throwaway `COPILOT_HOME` with no tools. The sign-in lives in the keychain, so it still works.

```bash
COPILOT_HOME="$(mktemp -d)" copilot -p "$question" -s --model claude-haiku-4.5 --available-tools "" --no-custom-instructions
```

The nested call also runs with an environment variable that tells the plugin to name nothing, in case a hook runs anyway.

### Receipts

The plugin is [tested](https://github.com/dblock/agent-baby-names/tree/v0.1.0/test) with Bats against fake checkouts and a fake model, on Linux, macOS, and Windows, where both tools run hooks in Git Bash. The videos were recorded with [VHS](https://github.com/charmbracelet/vhs), with the demo sessions in plan mode so they couldn't go and actually add emojis to my dotfiles. The Copilot ones get one more demo-only instruction: after renaming, say in a sentence what you'd look at first, and stop. That shows each session picking up its request, such as "Starting: I'll look at testlanes' CI workflows and test setup first", without letting it loose.

Install it, point `git-clone` at wherever you keep your code, and pick your own emojis.
