---
layout: post
title: "Launch Agents for My AI Agents"
date: 2026-11-25
tags: [ai, osx, mongodb]
---

It started with too much email. Renovate kept opening and rebasing PRs like [discord-strava#151](https://github.com/dblock/discord-strava/pull/151), and every push was another GitHub notification. I already had an [update-dependencies](https://github.com/dblock/dotfiles/blob/master/agents/skills/update-dependencies/SKILL.md) skill that sweeps my projects with Claude Code and opens one PR per project, so Claude and I removed Renovate from five repos, closed eight of its PRs, and taught the skill to cover every project I'm actively working on. That left one problem: a skill only runs when I remember to ask for it.

The fix is boring. macOS has had a scheduler forever, `launchd`, and a LaunchAgent is a small XML file that runs a command on a schedule while you're logged in. I keep mine in [my dotfiles](https://github.com/dblock/dotfiles/tree/master/scripts/osx/LaunchAgents), next to the instructions and skills I share between [Copilot and Claude](/2026/11/22/teaching-my-copilot-and-claude-children-to-share.html). Here are three of them, and what each one taught me about jobs that run while you sleep.

### Setting Up

A LaunchAgent is a plist with a label, a command, a schedule, and where to send output. This one runs every Sunday at 3:00.

```xml
<key>Label</key>
<string>com.dblock.cargo-clean-all</string>
<key>ProgramArguments</key>
<array>
  <string>/Users/dblock/.cargo/bin/cargo-clean-all</string>
  <string>--yes</string>
  <string>--keep-days</string>
  <string>7</string>
  <string>/Users/dblock/source</string>
</array>
<key>StartCalendarInterval</key>
<dict>
  <key>Weekday</key>
  <integer>0</integer>
  <key>Hour</key>
  <integer>3</integer>
  <key>Minute</key>
  <integer>0</integer>
</dict>
```

Linking a plist into `~/Library/LaunchAgents` does nothing until it's loaded with `launchctl bootstrap`, and a sleeping Mac runs nothing at all. The jobs run when the Mac wakes up, which might be noon. So I wrote [schedule.sh](https://github.com/dblock/dotfiles/blob/master/scripts/osx/schedule.sh) for the day my Mac implodes. It installs the tools the jobs need with Homebrew, links and loads every LaunchAgent in my dotfiles, and schedules a wake.

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

It turns out that macOS keeps exactly one repeating wake schedule, and `pmset repeat` replaces whatever was there. I planned a Saturday wake for the weekly job, then moved the backup to 5:00 and needed a daily one. One daily wake at 4:55 covers both, because `launchd` runs a calendar job that the Mac slept through as soon as it wakes up.

### 1. Cleaning Up Rust Builds

Agents love worktrees. Every parallel task gets its own checkout, and every Rust checkout gets its own multi-gigabyte `target` directory. [cargo-clean-all](https://github.com/dnlmlr/cargo-clean-all) cleans build artifacts of projects untouched for a week, and its last Sunday run said this.

```text
Selected 9/13 projects, cleaning will free: 33.57 GB. Keeping: 18.23 GB
Starting cleanup...

Projects cleaned. Reclaimed 33.57 GB of disk space
```

One project alone had 15 GB of builds. This is the easy kind of LaunchAgent: one command, no credentials, nothing to break.

### 2. Backing Up MongoDB to Dropbox

All my bots share one MongoDB cluster on DigitalOcean, and I've wanted daily backups in Dropbox for years. I had a LaunchAgent for that too, set up ten days ago, and today I had a hunch and asked Claude whether it had been failing. `launchctl` said it had run ten times, with exit code 0 every time. The error log said this every night.

```text
./run.sh: line 3: /home/dblock/.bash_profile: No such file or directory
/Users/dblock/.bin/mongodb-dump: line 24: mongosh: command not found
```

The script sourced a Linux home directory, so `PATH` had no Homebrew and there was no `mongosh`. The dump ran at the end of a pipe that swallowed the error, so the job reported success. My older backups were all stamped at random times like 17:13 and 9:19, because I'd been running it by hand, never from the schedule. Ten green runs and zero backups. Honestly, wow.

Claude and I rewrote it as [mongodb-backup](https://github.com/dblock/dotfiles/blob/master/bash/bin/mongodb-backup).

- It finds clusters with `doctl databases list` on every run, so the cluster's address isn't written down anywhere, including my public dotfiles.
- It keeps 30 daily snapshots and the last snapshot of every month.
- It writes each dump to a temporary file and moves it into place only when it's complete, so a failure never overwrites a good backup.
- It reads the password from the macOS Keychain and keeps it off the command line.
- It exits non-zero when anything fails.

It backs up 15 databases, about 28 MB, in about 30 seconds. The first test run from the schedule failed authentication, because I had just deleted the database user it was using. The new script caught that on the spot instead of reporting success for ten more days.

Failures should be loud, so I tried [terminal-notifier](https://github.com/julienXX/terminal-notifier), which can open the log when you click a notification. On macOS 26 the Homebrew build is ad-hoc signed and never gets permission to post notifications. A failed job now shows a plain `osascript` alert instead. It stays on screen until I dismiss it, and its **Open** button opens the error log.

### 3. Running Claude Code Every Other Saturday

The third job is the reason for all of this. Every other Saturday at 3:00, [update-dependencies.sh](https://github.com/dblock/dotfiles/blob/master/scripts/osx/update-dependencies.sh) runs the update-dependencies skill with Claude Code in headless mode.

```bash
caffeinate -i claude -p "/update-dependencies Unattended scheduled run: nobody can answer questions. ..." \
  --permission-mode auto --permission-prompts none --output-format json > "$json"
```

Nothing about this worked on the first try.

- `launchd` can't express "every other week", so the job runs every Saturday and the script exits on odd weeks. My first version used ISO week numbers, which would have skipped three weeks in a row at New Year, because both week 53 and week 1 are odd. It now counts weeks since the Unix epoch.
- A headless `claude -p` [waits for background subagents](https://code.claude.com/docs/en/headless) for only 10 idle minutes by default. A sweep starts one agent per project and takes hours, so the script raises `CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS` to 8 hours.
- The docs reserve `bypassPermissions` for [isolated containers and VMs](https://code.claude.com/docs/en/permission-modes). Auto mode with `--permission-prompts none` approves routine actions with a classifier and denies the rest instead of waiting for me to click something at 3:00.
- The first dry run died in `cd`, because my login shell loads `gvm`, which redefines `cd`, and it crashes under `set -u`. The script now calls `builtin cd`.
- It also left a lock directory behind, which would have blocked every future run. The lock now records a process ID and clears itself when that process is gone.

A dry run that discovers projects and changes nothing took 3 minutes and an estimated $0.62. It found 330 repositories I can push to, not counting forks and archived ones, with 125 active, 11 dormant, and 195 I haven't touched in a year. The first real sweep is on December 5, and could open up to 125 PRs. I'm on a $100 Claude Max subscription, so the dollar figure is an estimate rather than a bill, and the real limit is how much of my weekly usage one sweep eats. I'll set `--max-budget-usd` after I see the first one.

### Make It Loud

All three jobs live in my dotfiles, and `schedule.sh` brings them back on a new Mac. The one rule I'd copy is to make a scheduled job fail loudly and test it from the scheduler itself. A job that exits 0 and does nothing will happily do so for ten days, or ten years.

I'll report back after December 5.
