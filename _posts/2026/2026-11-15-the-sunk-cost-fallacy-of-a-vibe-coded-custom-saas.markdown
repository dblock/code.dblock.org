---
layout: post
title: "The Sunk Cost Fallacy of a Vibe-Coded Custom SaaS"
date: 2026-11-15
tags: [ai, open-source, ruby]
---

I organize a weekly figure-drawing session at [Enoch's Arts & Coffee](https://art.dblock.org/2026/05/25/figure-drawing-at-enochs.html) in Manhattan. It runs every Monday at 6:30pm and costs $20. It's regularly attended and we were even [written up in W42ST](https://w42st.com/post/pencil-me-in-hells-kitchen-artists-gather-for-a-weekly-dose-of-creative-zen/). Like any small event, it comes with the usual collection of emails, date juggling, private contact details, and calendar invitations.

So, I decided to build a custom SaaS called [Posebook](https://github.com/dblock/posebook) to automate all that.

![Posebook logo]({{ site.url }}/images/posts/2026/2026-11-15-the-sunk-cost-fallacy-of-a-vibe-coded-custom-saas/posebook-logo.png)

### The Plan

The original idea was that models would register, choose a date, and get a reminder a week before posing. I chose Rails and MongoDB because I already use both, and started with one venue and one recurring program. The application now organizes venues, recurring programs, organizers, invitations, bookings, attendance, and public schedules. It is open source, and the [hosted instance](https://posebook.dblock.org/) serves Enoch's, but could work for your event, too.

The organizer creates a venue, adds its location, and sets up one or more recurring programs. A program owns its schedule, booking rules, and managers. The organizer sends a private invitation link to a participant, who creates an account if needed and books an available date. The application checks that the booking is still available, retains its history when it changes, and keeps participant contact information private.

When a participant books, a configured Google Calendar integration creates one meeting with the participant and organizer on the guest list and the venue address in the location. Transactional emails go through a background worker. Cancellations, rescheduling, consent, opt-outs, retries, and acknowledgments all need to work together.

![Figure Drawing Mondays calendar at Enoch's]({{ site.url }}/images/posts/2026/2026-11-15-the-sunk-cost-fallacy-of-a-vibe-coded-custom-saas/calendar.png)

### Building It with an Agent

I used GitHub Copilot CLI as an implementation partner. I started by asking for a plan and a name, settled the product and data model, and then gave it bounded feature requests. The agent explored the Rails application, changed code and tests on task branches, and opened pull requests. I reviewed the behavior, corrected the requirements when the implementation got too specific, and kept the work moving in small changes.

The useful loop was to describe one user-visible outcome, inspect the proposed design, implement it with tests, review the pull request, and adjust the next task based on what the previous one taught us. I mostly reviewed screenshots.

### The Token Count

I looked at the local Copilot usage logs for five Posebook sessions recorded on November 14 and 15. They contain 4,071 model requests:

| Token Type       | Tokens       |
| ---------------- | -----------: |
| Non-cached input | 531,916,854  |
| Output           | 3,955,356    |
| Cached input     | 510,797,673  |
| Cache writes     | 21,102,359   |

### Maybe I Shouldn't Have

Posebook now handles a lot more than putting a date on a calendar. But for one weekly event, maybe it is too much software? Should I just be doing this with [Dots](https://openai.com/index/introducing-dots/) or [Muse](https://apps.apple.com/ca/app/muse-from-meta/id6760173601)? Maybe Posebook is already sunk cost.
