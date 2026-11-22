---
layout: post
title: "Teaching My Copilot and Claude Children to Share"
date: 2026-11-22
tags: [ai, open-source]
---

I use both [GitHub Copilot CLI](https://docs.github.com/copilot/how-tos/copilot-cli) with tokens paid for by Microsoft where I work, and [Claude Code](https://claude.com/claude-code) using my own subscription. I run Claude on a personal laptop and Copilot at work and use both almost every day, occasionally on the same projects, sometimes at the same time. Both read personal instructions and skills from my home directory, and I keep those in [my dotfiles](https://github.com/dblock/dotfiles), linked into `~/.copilot` and `~/.claude`.

Copilot got there first. I am happy with Copilot, but I want to keep learning, so more recently I have begun using Claude for personal projects almost exclusively. When I added Claude, I took a shortcut in [2f19eb4](https://github.com/dblock/dotfiles/commit/2f19eb4d95aea02e2890fbfd50efaba3afcdbc12): Claude's `CLAUDE.md` imported Copilot's instructions with `@~/...` and then listed exceptions.

```markdown
@~/source/dotfiles/.copilot/copilot-instructions.md

## Claude-Specific Overrides

- In AI-assisted commits, use `Co-Authored-By: Claude <noreply@anthropic.com>`
  instead of the Copilot co-author trailer.
- The shared instructions refer to a `pr-stack` skill. If no such skill is installed, ...
- Shared skills live in `~/source/dotfiles/.copilot/skills` ...
```

This wasn't fair to Claude. Every session started by reading another tool's instructions, including a line telling it to credit Copilot in commits, followed by a note saying not to. Skills lived under `.copilot/skills` and were linked into Claude from there. Every new rule I added had to be phrased for Copilot first and then patched for Claude. I'd rather not pick a side in the event of a [thermonuclear war](https://www.imdb.com/title/tt0086567/) between Copilot and Claude.

So I asked Claude to propose a layout where neither tool reads the other's files and it reorganized everything in [5503674](https://github.com/dblock/dotfiles/commit/5503674e859cb43aec26ebfdc5ca9cf9a9869b73).

### What Each Tool Actually Loads

Before moving files around, Claude and I checked what each tool reads instead of guessing. Claude Code reads `~/.claude/CLAUDE.md`, which can import other files with `@path`, and skills from `~/.claude/skills/<name>`. Copilot CLI doesn't document a way to import other files from its instructions, but it has a command that lists every instruction source a session would load.

```text
$ copilot instruction list
Personal instructions:
  • Home copilot-instructions.md
      from /Users/dblock/.copilot/copilot-instructions.md
```

To find out what else Copilot would pick up, we pointed `COPILOT_HOME` at a scratch directory, dropped in a few candidate files, and listed the sources again.

```text
$ mkdir -p /tmp/copilot-home/instructions
$ echo '# base' > /tmp/copilot-home/copilot-instructions.md
$ echo '# o' > /tmp/copilot-home/instructions/copilot.instructions.md
$ echo '# a' > /tmp/copilot-home/AGENTS.md
$ COPILOT_HOME=/tmp/copilot-home copilot instruction list
Personal instructions:
  • Home copilot-instructions.md
      from /tmp/copilot-home/copilot-instructions.md
  • copilot.instructions.md
      from /tmp/copilot-home/instructions/copilot.instructions.md
```

Turns out Copilot loads `~/.copilot/copilot-instructions.md` plus every `~/.copilot/instructions/*.instructions.md`, and ignores an `AGENTS.md` sitting in its home directory. The `instructions` folder is the missing piece: it gives Copilot a place for its own overrides, the same way Claude has its own section in `CLAUDE.md`. We also tried `COPILOT_CUSTOM_INSTRUCTIONS_DIRS`, which only loaded `.github/instructions/*.instructions.md` from the extra directory, so I didn't use it.

### The Layout

Everything agent-related moved into a tool-neutral `agents` folder.

```text
agents/
|-- README.md
|-- instructions.md                # shared, tool-neutral
|-- skills/
|   |-- create-project/SKILL.md
|   `-- update-dependencies/SKILL.md
|-- claude/
|   |-- CLAUDE.md                  # @imports instructions.md, Claude overrides
|   `-- settings.json
`-- copilot/
    `-- copilot.instructions.md    # Copilot overrides
```

Each tool now gets the same two layers: the shared instructions, then a small file of its own.

| Local Path                                        | Points To                                |
| ----------                                        | ---------                                |
| `~/.claude/CLAUDE.md`                             | `agents/claude/CLAUDE.md`                |
| `~/.copilot/copilot-instructions.md`              | `agents/instructions.md`                 |
| `~/.copilot/instructions/copilot.instructions.md` | `agents/copilot/copilot.instructions.md` |
| `~/.claude/skills/<name>`                         | `agents/skills/<name>`                   |
| `~/.copilot/skills/<name>`                        | `agents/skills/<name>`                   |

The shared file had to stop talking about either tool. “Include `Co-authored-by: Copilot`” became “include the co-author trailer that your tool's instructions specify”, and each overrides file spells out its own. A reference to a `pr-stack` skill that was never installed, which Claude had been told to work around, became the actual workflow both tools use: `gh stack link` and a check of the `.stack` field in the GitHub API.

The shared file is called `instructions.md` and not `AGENTS.md` on purpose. Copilot loads `AGENTS.md` files under the working directory as repository instructions, so while I work in the dotfiles repository it would load the same file twice.

### Linking Skills One at a Time

The obvious next question was whether to link the whole skills folder instead of each skill. That doesn't work for Claude: `~/.claude/skills` also contains a `synced` folder, which Claude Code manages itself, with the skills from my Claude account (`pdf`, `docx`, `xlsx`, `deep-research`, and so on).

I asked whether we could link the whole folder into the repository anyway and `.gitignore` the `synced` part. We tested that with Copilot first, by nesting a fake skill two levels down in a scratch skills directory.

```text
$ COPILOT_HOME=/tmp/copilot-home copilot skill list
Personal skills:
  create-project - Create a Ruby gem or JavaScript package ...
  synced-pdf-test - test nested synced skill
```

Copilot discovers skills recursively, so a single shared folder would have handed it all of Claude's account skills, including `computer-use` and `chrome-browser`. So each skill gets its own link, and `setup.sh` creates them.

```bash
link_agent_file() {
  local target="$1" link="$2"
  mkdir -p "$(dirname "$link")"
  if [[ -L "$link" && "$(readlink "$link")" == "$DOTFILES_DIR"/* ]]; then
    ln -sfn "$target" "$link"
  elif [[ -e "$link" || -L "$link" ]]; then
    echo "Skipping $link: it exists and does not point into $DOTFILES_DIR."
  else
    ln -s "$target" "$link"
  fi
}

for skill_dir in "$DOTFILES_DIR"/agents/skills/*; do
  [[ -f "$skill_dir/SKILL.md" ]] || continue
  link_agent_file "$skill_dir" "$HOME/.copilot/skills/$(basename "$skill_dir")"
  link_agent_file "$skill_dir" "$HOME/.claude/skills/$(basename "$skill_dir")"
done
```

The script re-points links that already point into the dotfiles repository, and leaves anything else alone. One run moved all 7 links on my machine and added Copilot's new overrides link. A second run changed nothing.

### Rules for Working Together

Sharing is caring, but we need rules that help two agents not step on each other's toes.

Repositories keep their agent instructions in `AGENTS.md`, which Copilot loads automatically. Claude now has an explicit instruction to read the repository's `AGENTS.md`, and any in subdirectories, before changing anything, so both follow the same project rules without a duplicate `CLAUDE.md` in every project.

Working trees need a home they can share. One of my projects had 6 working trees besides the main one, including stale ones in `/private/tmp`, one inside Copilot's own session-state folder, two inside Claude Code's `.claude/worktrees`, and branches checked out in multiple places. The shared instructions now say to create working trees only as siblings under `~/source`, never in temporary or tool-managed folders, and to remove them when the work is done. For Claude, `CLAUDE.md` tells it to create a sibling with `git worktree add` and enter it by path instead of nesting it under `.claude/worktrees`. Both changes are in [3490fb4](https://github.com/dblock/dotfiles/commit/3490fb44eb2deef9ce4d8e607be63fd860cd4b32).

Here's what that looks like for my fork of [doctl](https://github.com/digitalocean/doctl) next to its upstream checkout, with a working tree for one task.

```text
~/source/
`-- doctl/
    |-- upstream-doctl/          # digitalocean/doctl
    |-- dblock-doctl/            # my fork, dblock/doctl
    `-- dblock-doctl-<topic>/    # working tree, created with git worktree add
```

Finally, the dotfiles themselves. They're linked into the live configuration, so a topic branch or a working tree hides the change from both tools until it merges. Agents now work directly on `master` in `~/source/dotfiles` ([0a32071](https://github.com/dblock/dotfiles/commit/0a32071e4dbf186e2160a66e92195a2b15281cb7)). That made me nervous about a rule change landing in both agents' heads without me reading it, so they also have to show me the diff and wait for approval before committing ([3968845](https://github.com/dblock/dotfiles/commit/3968845655123fa6c21655d89b5af3655f2a8381)). Claude committed the first of those two rules without asking, which is exactly why the second one exists.

### I Am an Only Child

I am an only child, but have two of my own (four if you count Copilot and Claude). So I put the shared rules in one tool-neutral file and gave each child a small file of its own. Now when I teach either agent something that applies to both, it goes into `agents/instructions.md` and they both learn it.
