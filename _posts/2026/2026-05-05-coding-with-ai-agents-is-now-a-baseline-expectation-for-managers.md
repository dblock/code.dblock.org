---
layout: post
title: "Coding with AI Agents is Now a Baseline Expectation for Managers"
date: 2026-05-05
tags: [ai, management, people]
comments: true
---
AI-first Engineering is now the operating default in many organizations, including mine. Developers have kept up. Vibe coding became agentic engineering, and the race towards truly autonomous engineering isn't slowing.

But what are we, managers, to do?

A manager job continues to include recruiting and retaining people, setting clear goals and expectations, fostering communication, owning team workflows, and coaching daily behaviors. To this list we must now add driving AI transformation.

Being a passive advocate is not enough. Unlike other subjects, no amount of AI training will help you keep up with the pace of evolution of this technology. Therefore, one cannot drive AI transformation without being an active AI practitioner. But what does being an active AI practitioner look like for a manager?

To find out, I landed myself into a small Engineering team (7 people) within my 100+ people organization five weeks ago. This small group develops an essential internal Microsoft system used by every single Engineer at the company. I wanted to learn firsthand about their challenges by onboarding into the project, and maybe contribute 2-3 PRs myself. I decided to dedicate my Copious Free Time™ to this work, to only use Copilot (you can use Claude, or another CLI, too), and to attend the team's daily standup.

Before I talk about what I did or learned, I must apologize to the team for giving them a heart attack upon my arrival. It's rare that a VP of Engineering, many levels "above", inserts themselves into any team unless there's some huge, urgent, problem. This wasn't an issue with the specific team, but transforming the way we work remains absolutely urgent, and it's my responsibility to do everything I can to make it happen.

Initially, I expected to make 2-3 pull requests. Instead, I was able to make 89 (!), broke at least two production features, but also shipped some meaningful improvements. These fell into several categories.

1. Improved developer experience. I fixed several issues in local dev, wrote a new CONTRIBUTING guide, added a script to start and shutdown various services together, and added an AGENTS.md to make the repo AI-agent-ready.
1. Did batch dependency upgrades to address CVEs. Major upgrades required rework of the actual code. Two of these silently broke features in very subtle ways, showing gaps in integration testing, but also taking a lot of team's time to debug unexpectedly.
1. Increased test coverage and overall repo quality. I wrote a number of missing unit and integration tests and fixed a few flaky ones. A clear win.
1. Improved CI/CD pipeline. I was able to bring the CI time down from over an hour to ~30 minutes, mostly by not building projects without code changes, and disabling the many checks and guards that didn't need to run on every pull request.
1. Executed some overdue modernization. I finished a Webpack to Vite migration that another engineer stalled on because of conflicting priorities, significantly improving local build time, upgraded TypeScript 4 to 5, Node.js 16 to 20, LESS to SCSS, MSTest 2.x to 3.x. All these upgrades were on the team's backlog, but nobody ever had time to do them.
1. Fixed many minor bugs. Other than bugs reported by users, I paid attention to warnings during build or in the JavaScript console, and asked Copilot to address them. I improved error display, corrected dark mode CSS, addressed sass deprecation warnings and ESLint errors.

Here's what I learned.

1. This AI sh*t is wild. Driving Copilot is like holding the reins of a Russian winged troika. The only limitation was my own time, memory, and the amount of changes I was able to keep active in my head in parallel at one given time. I'd come up with a thing to do, tell Copilot to do it, it would make the change, open a pull request, get it reviewed by another AI, address comments, and iterate to green. I would intervene once this loop was finished, review the change, and mark it as ready to be reviewed by another Engineer.
2. We are absolutely not ready for the onslaught of agent-generated changes. Human attention quickly became the bottleneck. If a manager with a full-time job can open 20+ pull requests per week that pass CI and accomplish a positive change, a group of 5 full-time engineers plus an army of autonomous agents will be generating hundreds. The team immediately wondered whether they would go from being developers to full-time code reviewers, while real breaking changes slipped through otherwise trivial updates.
3. Copilot is the new rubber duck, developer social, and software architect. It's now much faster to ask Copilot to explain a problem and then to fix an issue than to discuss any of it with teammates. It's faster to design and implement 3 versions of a feature than to discuss which approach is cleaner ahead of time. You can now truly lead with code.

But the most interesting thing that happened during this experiment is that the team's PR velocity doubled without counting mine. Using Copilot became contagious. I am confident this is permanent — I never want to write code by hand again. There's no turning back.

If you manage a team of any size and have never coded with AI at work, become the janitor of one of your team's repos. Start by improving onboarding docs and CI/CD time. Doing this work was both impactful and a lot of fun. Feel the energy!
