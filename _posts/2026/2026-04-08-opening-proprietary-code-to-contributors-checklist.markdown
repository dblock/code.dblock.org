---
layout: post
title: "Opening Proprietary Code to Contributors Checklist"
date: 2026-04-08
tags: [engineering, open-source, contributions, ai]
comments: true
---

Before AI coding assistants, a typical engineering team built expertise with the years: new team members joined, contributed small bug fixes, then were given more ambitious tasks over time as they became more comfortable in a codebase, to ultimately become experts. This process took years.

In contrast, today, almost every engineer, and many non-engineers, have access to tools that can gather context from any codebase, and produce a large volume of high-quality code in a day. This lowers the bar for contributing meaningful changes to the software we build and enables many more individuals without domain or codebase expertise with good ideas to see them to light.

At work, I asked my team to actively seek contributions from our customers with an active engagement for our proprietary code. Inspired by the open-source model, we are reviewing our systems from the angle of a newcomer easily contributing to them.

Here's a checklist to apply to any repo.

1. **Create a single landing `CONTRIBUTING.md`** that welcomes contributors and encourages them to contribute while insisting on higher standards, such as needing to write automated tests with every contribution.

2. **Make your source code repo discoverable.** Your source code README, and your product or tool should have a visible link to your single `CONTRIBUTING.md`.

3. **Include a simple to follow "Getting Started" checklist** in `CONTRIBUTING.md` that enables any developer at the company to make a trivial change in the application and submit a pull request.

4. **Ensure that your project has an automated test suite** that runs in CI, is trivial to run locally, has few to no dependencies, and has enough coverage to give confidence to any new contributor that they did not break key functionality.

5. **Evolve every project to a state where a minimum viable version of it can run locally** without the need to ask for permissions, certificates, or keys, install or get access to unnecessary dependencies, removing those barriers from the new contributor path. Describe how to run the project locally in `CONTRIBUTING.md`.

6. **Ensure safe CD** by making the project's deployment model self‑describing, clearly signaling where changes land first, what approvals and gates exist, and how regressions are detected and rolled back, so both new and existing contributors can ship changes with confidence.

7. **Prefer GitHub fork/PR model** where contributors do not need permissions to your source code and protect source such that contributors cannot accidentally force push an update to main.

8. **One should be able to open a PR without ever needing to contact your team** that owns the project.

9. **Enable and encourage contributors to open bugs and feature requests directly** and triage new issues weekly. Engage customers publicly within these systems rather than offline or e-mail.

10. **Establish a publicly accessible channel** for your own developers and for contributors to meet and ask technical questions and link it from `CONTRIBUTING.md`.

11. **Create a daily short standup for your team that is open to others** actively contributing to your repo to drop into and make it easily discoverable. Use the standup to socialize external contributions across the team.

12. **Create a habit of all team members reviewing and approving PRs** and delegate repetitive requests, such as needing tests, to A.I. reviewers. Ensure that both team PRs and PRs made by external contributors are engaged within one day, and that all team members are reviewing and approving each other's PRs regularly, not just one person.

13. **Create an automated CHANGELOG or a Release Notes process** that highlights both team and external contributors, and that is discoverable from your product or tool. Take the time to directly highlight one's contribution to their manager when impactful.

14. **Make the repo AI-friendly with `AGENTS.md`** that contains instructions for AI that help humans collaborate with AI to produce a feature.

15. **Continue prioritizing most impactful features to be shipped by your own team** while actively engaging your customers by inviting them to contribute the features that you cannot deliver quickly. Highlight external contributions in business reviews.

And if nobody volunteers to contribute to our projects, most of these steps will also make it easier and more efficient for my own team members to work on the codebase, to enable partner teams to do work, and reduce the time needed to onboard new engineers joining my organization.

Level up!
