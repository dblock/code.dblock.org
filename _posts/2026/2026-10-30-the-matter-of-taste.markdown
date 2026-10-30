---
layout: post
title: The Matter of Taste
date: 2026-10-30
tags: [ai, api, open-source]
---

While working on [`Svet`](https://github.com/dblock/svet), a Git and filesystem linter, I had a conversation with GitHub Copilot CLI about a flag.

The tool checks files. We were [adding automatic fixes](https://github.com/dblock/svet/pull/27). Naturally, I wanted to preview changes before allowing the tool to write them.

The first suggestion was `--fix-dry-run`. I preferred a global `--dry-run` that could apply to both checking and fixing.

Simple enough. Except checking already doesn't write anything. What should a dry run of a check do?

One answer is that a dry run prohibits writes. Run all the checks, report the findings, and leave the files alone. With `--fix`, calculate the fixes but don't apply them. Without `--fix`, the flag changes nothing.

That's a consistent definition. It also makes the flag redundant for the default operation.

I wanted another definition: preview the operation I asked for.

```sh
# Check files.
svet

# Check files, fix what can be fixed, and check again.
svet --fix

# Show which files and checks would be involved, without running checks.
svet --dry-run

# Run checks and prepare fixes, without changing files.
svet --fix --dry-run
```

In the checking case, the preview stops before running checks. In the fixing case, it has to run checks to discover what needs fixing, then stops before writing.

You could object that `--dry-run` now does different things. You could also say it does the same thing: shows what the selected operation would do.

Copilot suggested calling the checking preview `--plan`.

I don't like to `--plan`.

I find the `--plan`, `--fix`, and `--fix-dry-run` interface horrible, even though each flag names something specific. I don't like to repeat myself and I am a human capable of calculating the 2x2 matrix of options in my head. I opt for a smaller vocabulary using my decades of experience making and using developer tools.

AI can explain both designs and implement either one. It can point out that checking is already read-only, suggest another flag, and produce the tests. I still have to decide which interface I want to use and every such decision is the difference between an elegant solution and AI slop.

Sometimes there is a concrete constraint that settles a design question. Sometimes there are two coherent choices, and elegance is how one of them feels to you.

This choice isn't obvious. It's a matter of taste.
