---
layout: post
title: Right-Sizing Engineering Teams for AI
date: 2026-03-11
tags: [ai, people, teams]
comments: true
---
Before AI coding assistants, a typical engineering team of 8-10 people might have been lucky to have one or two "10x engineers", or "workhorses", the kind of engineer that both keeps project quality and feature velocity high.

AI tools have solved the workhorse half of this equation, enabling massive raw output. Today, almost every engineer can produce a high volume of code with GitHub Copilot, Claude, or Cursor.

But the quality half of the equation has not kept up. Teams are shipping more code, but a greater fraction of it is AI slop: plausible-looking, locally coherent, globally wrong. Code review remains a human activity. Until that changes, AI assistants cannot substitute for the senior engineer. If AI triples output but the number of senior reviewers stays the same, the ratio of experienced judgment to code produced has gotten roughly 3x worse.

The instinctive response to higher individual productivity is to hire fewer people, which is correct directionally but wrong in practice if you cut experience rather than volume. The difference is not in lines of code produced; it is in the accumulated judgment applied at every decision point. A team of four or five senior engineers with AI assistants will, in my experience, outperform a team of ten mixed-experience engineers with the same tools because the ratio of judgment to output stays healthy.

This has implications for how engineering leaders should think about headcount planning. A well-functioning engineering team today should be five to seven people, with at most one junior. A reliable signal that you've gotten this wrong: pull requests that sit unreviewed for days, not because people are busy, but because no one feels confident enough to approve them.

Smaller, more experienced engineering teams are not a new idea - Fred Brooks noted that you cannot make a late project earlier by adding people. What AI has done is make the argument sharper and more urgent. When every engineer can produce the volume that once required three, the scarcest resource is no longer effort; it is experience. Optimize for that.
