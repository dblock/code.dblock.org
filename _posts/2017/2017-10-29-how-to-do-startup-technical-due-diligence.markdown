---
layout: post
title: "How To Do Startup Technical Due Diligence"
date: 2017-10-29
tags: [technology, vcs]
comments: true
---
As CTO I've gone through many rounds of technical due diligence with venture capital firms, and have done a few of these from the other side as a consultant. There's a lot of information online, including [this excellent blog post](https://blog.pasker.net/2007/08/28/a-high-tech-entrepreneurs-guide-to-surviving-technical-due-diligence) by Bob Pasker on the former, but not much on the latter other than [this old checklist](http://glemak.pbworks.com/w/page/5500952/techdd) by Mike Dunn, both industry veteran CTOs.

If you're doing technical due diligence for a VC for an investment or an M&A process from the acquiring side, this post is for you.

## What is technical due diligence?

Technical due diligence is a process by which the investor attempts to answer one or more specific questions related to a company's technology capabilities, before making an investment. I personally find the _question_ aspect of due diligence very important for a successful process, even if such questions are often quite generic. VCs typically want to know the following.

* Are the claims made by the team in the areas of technology accurate?
* Is the team technically credible and competent?
* Is the organization capable of executing on their current roadmap?
* What are the technical strengths, weaknesses and risks of the company?

Sometimes CEOs will also make wild statements about proprietary algorithms, special people or data, so a VC may want to get an independent opinion about such claims.

## Why do due diligence?

I believe that due diligence, including technical, is a VC's _duty and responsibility to their own investors_, and not just a box to check. And due diligence should be obvious if you're buying a company - know what you're getting!

There's a high rate of execution failures in startups, yet many VCs skip technical due diligence or have non-technical partners talk to the CTO for an hour or two. At best they see this process as educational. In my opinion, technology must be evaluated at par with financial discipline before giving a company money, so I find it fascinating that VCs will put cash into teams after incredibly thorough audits of their books, but without really looking at what's under the hood. Technical due diligence establishes a more realistic view of the company's technology and easily highlights cultural qualities and dysfunctions in technical teams by asking important questions. It avoids a lot of surprises during the first board meeting after the investment. It also usually costs less than the lawyers involved in any deal.

## Who should do technical due diligence?

At the risk of being self-serving, I recommend a current or former CTO and entrepreneur. It's very important that this person has served as a very senior individual contributor for many years, is not overly opinionated about solutions and architectures, has seen many successful and unsuccessful ventures, is intellectually curious, thinks pragmatically and knows that there exist many great ways to build a successful technology company. More importantly, you want hire someone who can explain technology to a non-technical person and someone you can trust.

Don't just count on the individual's track record as a technologist or entrepreneur based on company outcomes - do their references and probe specific areas that will serve the needs of _your_ due diligence process.

## Terms of Engagement

Before doing any work I recommend agreeing on the high level objectives and the length and size of the engagement.

For seed round investments I will take a meeting or a call as a service to a VCs I already have a relationship with for free, but for anything more serious I will commit a day of paid work. Due diligence can be potentially done remotely for a large seed or a Series A, and a few days, including an on-site visit, for Series B and anything bigger than that.

My typical due diligence process consists of the following.

1. Preliminary research into the company's business and people.
2. Interviews with senior staff members, on-site or remotely.
3. A thorough overview of the technology implementation and assets made available by the company.
4. A quick first impressions summary of each conversation throughout the process.
5. A final report detailing technology and people.

I often break down the expected hours into phone interviews, travel and on-site visits, summaries of findings, asset evaluation, reports, debrief, and follow-up on various questions, charge my usual hourly rate for actual work and expect all transportation and accommodation to be organized and paid for by the venture firm.

## Due Diligence Interviews

#### CEO

Once a letter of engagement, NDAs and any other required paperwork is done, you can kick off the due diligence process. Typically the VC should introduce you to the CEO and the CTO, first. My standard reply includes a thank you and an invitation to talk, eg. _What's a good time to have a talk, probably 45 minutes or so? I'll try to accommodate your schedule at best, give me some options. I'm in New York on EST._

For remote due diligence I setup a video call, then add the following.

> While I mostly have a technical background I spend equal amounts of time across people, technology and business. When I am on the other side of due diligence (I currently work for [a post Series D company](https://www.artsy.net)) I often refer to [this article](https://blog.pasker.net/2007/08/28/a-high-tech-entrepreneurs-guide-to-surviving-technical-due-diligence/amp/).
>
> Things I look forward to hearing about and discussing:
>
> - A very brief overview of the company, what you did prior and how you ended up here.
> - The problem you're trying to solve, the solution and how that solution becomes a business.
> - The very early history of your team, how you ended up having your CTO in their current role.
> - Company culture and the role technology plays in it.
> - Your view of your technical operation as a non-technical executive, strengths, weaknesses and risks.
>
> Please don't hesitate to send me any material upfront so we can make this efficient and a useful conversation for both of us!

At the very least I get back an investor deck.

I drive the call with questions, but try to speak as little as possible and take a lot of notes. Then, I write up a quick summary of the most interesting findings in an e-mail to the VC. Ultimately the one question I am trying to answer is whether _I would work for this CEO_. I've been impressed by quite a few and it's very inspiring to talk to bright, often younger and more ambitious entrepreneurs.

I always follow-up with a standard _Thanks for taking the time for the call today, it was very informative and educational. Please don't hesitate to reach out if there's anything I can be helpful with._

#### CTO, VP of Engineering or Head of Engineering

A well prepared, transparent and open process says a lot about the maturity of the organization and its leaders. The CTO conversation needs to quickly dig deep into technology, therefore my list of items to discuss changes significantly. For larger organizations with multiple Engineering leads I will cherry-pick from the following list of items and always set expectations in e-mail 24 hours in advance.

> Things I look forward to hearing about and discussing:
>
> - The company you joined, the challenge as you saw it then, how you feel about it now, and what has changed.
> - Your understanding of the problem the company is trying to solve, the solution you're trying to implement and how that solution becomes a business.
> - History of the company's software and systems and how that is evolving.
> - Developer and other workflows and processes.
> - Infrastructure and architecture of your systems, including network, data, software and hardware systems, platforms and tools.
> - Operations, COGS, budgets.
> - Technology roadmap, plans and major initiatives.
> - Your own team, people you rely on, general technical staffing, hiring, training, organization and plans around people.
> - The relationship between the Engineering team and other teams.
> - Company culture and the role technology plays in it.
> - A personal view of your technical operation, weaknesses, strengths and risks.

I like to see the CTO and the VP of Engineering have their acts together and to send me a lot of information upfront, including links to internal documents that weren't created yesterday for this specific due diligence process. And as with the CEO I take lots of notes during the conversation and gather highlights in an e-mail to the VC immediately after each interview.

The 3 most important questions I am trying to answer are the following.

* Would I trust this CTO or VP of Engineering with my own company?
* Do I respect the technical and organizational abilities of the technology leadership?
* Would I theoretically want to hire any of the technical people into my own Engineering team?

#### CPO, CMO and Heads of Product, Marketing and Design

When given the opportunity I like to spend time with other executives. These are likely to be the heads of Product, Marketing or Design, which are often the biggest areas of contention. The relationships between these teams are critical for the success of the company.

The 3 most important questions I am trying to answer are the following.

* Where are ideas born, how are requirements driven and how are they designed and turned into product features?
* What kind of relationships does the Product, Design, Marketing and Engineering organizations have and do they have respect for each-other?
* How technical are the non-technical organizations and do they understand and consider internal challenges of Engineering, such as technical debt?

## Evaluating Assets

Some companies will provide me with read-only access to internal systems, such as Github or Confluence. This often requires some back-and-forth and not everyone agrees to show their source code, because it's often their biggest liability. I personally think that's a mistake, but I don't insist, and generally work with what is given to me. Unless I get to see the code I am going to assume that the software is of a typical startup version of the "ball of mud" variety and quality.

It's critical to highlight to the VC the limitations of technical due diligence in absence of assets, such as source code, but it doesn't make this process useless. An experienced technical evaluator will easily see holes in a technical story and ask all the right questions that will surface the biggest areas of risk.

I go through code the same way I evaluate open-source software written by an Engineering candidate. I am looking for consistency in implementation, open dialog about technical choices and issues, velocity of the entire team, evidence of agile approaches, levels of quality, testing or clarity in documentation. I imagine being on-boarded into an actively developed system and try to think about how I would feel as a new or an existing team member. Finally I seek evidence of the operational infrastructure of the product, the practices around deployment, security, monitoring and general scale.

The 3 most important questions I am trying to answer are the following.

* Are processes, systems, collaboration and code at par with what I would typically see in a company at this stage?
* How much time is the team actually spending maintaining the software vs. producing value for the customers of the company?
* Is the executive management over or under-selling its technical capabilities and are there solid foundations for any future growth?

## Final Report

The final report is a lengthy document that includes a summary of the technology developed by the company and its underlying infrastructure, technology advantages and risks, external dependencies, an evaluation of whether the technology is best in class and its future roadmap, a summary of the organization and the team’s technical credibility and capability across all product and technical areas, product quality and development process and the degree at which future plans seem viable.

I use the following structure.

#### Overview

A high level overview of the process followed, the level of access provided, and the amount of time spent talking to people and evaluating assets. The takeaway from this section is _what I had to work with_.

#### Objective

The purpose of the technology due diligence report, typically _to determine whether the company is in a position to execute on its roadmap and objectives from the technology point of view, evaluate the software and hardware platform, determine technical debt, understand and uncover technical risks, highlight technical advantages and provide an independent evaluation of the team in place and its relationships within the larger company organization_.

#### Executive Summary

A description of the business problem and typical technical challenges of such business. An end-to-end explanation of how the product works from the technical point of view, whether the proposed idea works and a summary of the current state of the systems and people involved, including a take on senior leadership, its track record and current progress. The company in its context and time line, compared to other enterprises of similar size, scale and stage. A clear evaluation of confidence in the overall ability of the team.

The important takeaway from this section is whether _this report will express a fairly high level of confidence in the team’s ability to continue delivering on the company’s product roadmap, while incrementally improving the underlying technology_.

#### Technology Platform

A detailed overview of the current technology platform, architecture diagrams and as much detailed information as possible along with an evaluation of the system. The important takeaway from this section is whether _the current system is messy or clean and whether it's typical to see such a system at a startup in this stage_.

An overview of the next technology platform iteration. The important takeaway for this section is whether _the team has a clear idea of what to do next from the technology point of view_.

#### Technology Organization

A walk-through of the organizational chart. The important takeaway for this section is whether _the distribution of the team makes sense, whether the team is too small or too large, how the team grows, promotes, develops and hires and whether organizational plans seem reasonable_.

#### Technology Collaboration

A deep dive into how the CEO and other teams collaborate with the technology organization, company culture around technology, where ideas are born, how they are turned into code and how they make it into the production production used by customers. The important takeaway from this section is whether _the team is standing in its own way to enable success_.

#### Risks

Risks from the technology perspective. The takeaways from this section are the _possible scenarios that would cause the organization to fail to execute_ and some basics, such as _whether the code contains any polluting GPL-licensed software_.

#### Conclusion

A recommendation on the overall solidity of the technology organization. The takeaways from the entire report include _the level of risks and my personal confidence in the leadership team, based on the conversations and available data_.

## Debrief

There's a lot of information in the report and it's natural to expect that the VC will want to understand better one or the other aspect in-depth. In my experience it's important to diligently answer all questions, not to overemphasize the conclusions of the due diligence report, and to help the VC answer _their_ questions. Ultimately, technical due diligence is about gathering more information.

## Why do I do due diligence?

I have limited time to do things like due diligence outside of my job, but I find it benefits my current employer and is extremely rewarding as a learning process. Every technical due diligence is an amazing opportunity for me to look under the hood of an entire company. While the actual information is always under NDA, I have often brought the best high level technical and organizational ideas back to my own teams.

If you're interested in working with me, please [reach out](/about/) over e-mail and I can send you a generic sample.
