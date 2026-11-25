---
layout: post
title: "Launch Agents for My AI Agents"
date: 2026-11-25
tags: [ai, osx, open-source]
---

I got 691 email notifications from [Renovate](https://docs.renovatebot.com/) and 740 from [Dependabot](https://github.com/dependabot) in 2026. Dependabot is great as it automatically PRs dependency updates for you, but it quickly gets too noisy and needs constant rebases. Renovate improves upon Dependabot by letting you group many dependency upgrades into a single PR. At some scale, the amount of attention these notifications require all day long is just too much, and I am not quite ready to roll out [auto-merge of Dependabot PRs](https://docs.github.com/en/code-security/tutorials/secure-your-dependencies/automate-dependabot-with-actions). I wanted to group the work in ways that I can adjust and control across the hundreds of repos I'm involved with.

My fix is boring. I use the macOS scheduler, `launchd`, and a LaunchAgent to run a [dependency update skill](https://github.com/dblock/dotfiles/blob/master/agents/skills/update-dependencies/SKILL.md) every other Saturday. Claude Code sweeps every project I'm actively working on and opens one PR per project with all the minor and patch updates already tested, stacks PRs on top for the major upgrades it can manage, and lists the rest.

### Implementation Details

A LaunchAgent is a plist with a label, a command, a schedule, and where to send output. I keep mine in [my dotfiles](https://github.com/dblock/dotfiles/tree/master/scripts/osx/LaunchAgents), next to the instructions and skills I share between [Copilot and Claude](/2026/11/22/teaching-my-copilot-and-claude-children-to-share.html). This one runs every Saturday at 3:00, through a login shell, so that `rvm`, `nvm`, and `claude` are on the `PATH`.

```xml
<key>Label</key>
<string>com.dblock.update-dependencies</string>
<key>ProgramArguments</key>
<array>
  <string>/bin/bash</string>
  <string>-l</string>
  <string>/Users/dblock/source/dotfiles/scripts/osx/update-dependencies.sh</string>
</array>
<key>StartCalendarInterval</key>
<dict>
  <key>Weekday</key>
  <integer>6</integer>
  <key>Hour</key>
  <integer>3</integer>
  <key>Minute</key>
  <integer>0</integer>
</dict>
```

The plist runs [update-dependencies.sh](https://github.com/dblock/dotfiles/blob/master/scripts/osx/update-dependencies.sh), which runs the skill with Claude Code in headless mode and saves its report.

```bash
caffeinate -i claude -p "/update-dependencies Unattended scheduled run: nobody can answer questions. ..." \
  --permission-mode auto --permission-prompts none --output-format json > "$json"
```

Nothing about this worked on the first try.

- `launchd` can't express "every other week", so the job runs every Saturday and the script exits on odd weeks. My first version used ISO week numbers, which would have gone three weeks without a sweep at New Year, because both week 53 and week 1 are odd. It now counts weeks since the Unix epoch.
- A headless `claude -p` [waits for background subagents](https://code.claude.com/docs/en/headless) for only 10 idle minutes by default. A sweep starts one agent per project and takes hours, so the script raises `CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS` to 8 hours.
- The docs reserve `bypassPermissions` for [isolated containers and VMs](https://code.claude.com/docs/en/permission-modes). Auto mode with `--permission-prompts none` approves routine actions with a classifier and denies the rest instead of waiting for me to click something at 3:00.
- The first dry run died in `cd`, because my login shell loads `gvm`, which redefines `cd`, and it crashes under `set -u`. The script now calls `builtin cd`.
- It also left a lock directory behind, which would have blocked every future run. The lock now records a process ID and clears itself when that process is gone.

Linking a plist into `~/Library/LaunchAgents` does nothing until it's loaded with `launchctl bootstrap`, and a sleeping Mac runs nothing at all. So I wrote [schedule.sh](https://github.com/dblock/dotfiles/blob/master/scripts/osx/schedule.sh) for the day my Mac implodes. It installs the tools the jobs need with Homebrew, links and loads every LaunchAgent in my dotfiles, and schedules a wake.

```bash
for plist in "$dir"/LaunchAgents/*.plist; do
  label="$(/usr/libexec/PlistBuddy -c 'Print :Label' "$plist")"
  link="$agents_dir/$(basename "$plist")"
  ln -sfn "$plist" "$link"
  launchctl bootout "$domain/$label" 2>/dev/null || true
  launchctl bootstrap "$domain" "$link"
done

sudo pmset repeat wakeorpoweron MTWRFSU 04:55:00
```

It turns out that macOS keeps exactly one repeating wake schedule, and `pmset repeat` replaces whatever was there. Other jobs need a daily wake, so the Mac wakes at 4:55 every day, and `launchd` runs a 3:00 sweep that the Mac slept through as soon as it wakes up.

When a sweep fails, I want to know. I tried [terminal-notifier](https://github.com/julienXX/terminal-notifier), which can open the report when you click a notification, but on macOS 26 the Homebrew build is ad-hoc signed and never gets permission to post notifications. A failed sweep now shows a plain `osascript` alert instead. It stays on screen until I dismiss it, and its **Open** button opens the report.

### Project Management

Deciding what "every project I'm actively working on" means took a few rounds. The skill looks at every repository I can push to, whether it's mine, an organization's, or someone else's where I'm a collaborator, and skips forks and archived ones. A project is active when its default branch has a commit that wasn't made by a bot in the last 3 months, because bots pushing their own branches would make everything look active. Projects untouched for 3 to 12 months are listed in the report for me to pick from, and older ones are skipped. A [projects.yml](https://github.com/dblock/dotfiles/blob/master/agents/skills/update-dependencies/projects.yml) in my dotfiles includes what discovery misses, such as [create-a-github-issue](https://github.com/dblock/create-a-github-issue), a fork that I maintain as a project of its own, and excludes organizations and repositories I don't want swept, such as everything in `opensearch-project`, which I no longer work on. My dotfiles are public, so private repositories go into an untracked `projects.local.yml` next to it.

### The First Sweep

A dry run with `update-dependencies.sh --dry-run` discovers projects, locates their checkouts, and changes nothing. It took 3 minutes, and this is the top of its report.

```text
## Discovery

- Sources: 330 writable repositories (not archived, not forks), plus 16 App Platform apps
  backed by 16 repositories, plus the one include-list entry, `dblock/create-a-github-issue`.
  That entry is a fork, but it's included explicitly.
- Excluded: 9 writable `opensearch-project/*` repositories, matched by the `exclude` list.
- Counts:
  - Active: 125.
  - Dormant: 11. Normally I'd ask which of these to sweep.
  - Inactive: 195.
- Activity rule: a project's age is its newest default-branch commit not made by a bot,
  counted from today (2026-11-25). "Active" means a commit since 2026-08-25. "Inactive"
  means none since 2025-11-25.

## Active Projects and Checkouts

118 of the 125 have a checkout ...
```

The first real sweep is on December 5, and could open one PR for each of up to 125 projects, plus stacked major upgrades. If the first run holds up, I'll add instructions to merge those PRs on green.

I'll report back after December 5.
