---
layout: post
title: How to Grow Open-Source Contributors and Maintainers
date: 2024-12-14 01:00:00
tags: [open source]
---
I've been very active in open source since around 2008 and have become very passionate about growing contributors and maintainers in the projects I am involved in. The health of an open-source project can easily be measured by the number of actively engaged participants in its code, which cannot happen without maintainers. Maintainers are leaders driving open-source projects. The best maintainers contribute significant code, have the responsibility to review other people's contributions, and perform the release process. In my experience, the best ones are experts in the system they are developing. They are prolific coders, and are able to collaborate with contributors that don't work for the same business, maintain a high quality bar, sweat the small stuff, and recognize behaviors that earn trust in others. The goal of a project maintainer is to always improve the project, ensure it stays the course of its core mission, and to work themselves out of the job by promoting contributors to maintainer positions. This is often referred to as _meritocracy_.

I hold two possibly controversial opinions. First, to attract long lasting contributors that can become maintainers a project needs **an owner**, sometimes known as a benevolent dictator. Second, contributors need to have **a business need**, or an unusually strong personal interest to stick around.

I have yet to see it work differently, and I will illustrate this with some examples from my own experience.

In 2010 I was working a database security analytics product. We were paying an exorbitant amount of money for a software license to get basic hardware information. To save costs I created [OSHI](/2010/06/23/introducing-oshi-operating-system-and-hardware-information-java.html), an operating systems hardware information library written in Java. The first contributor to the project came in 2013, a handful in 2015, 8 became project co-maintainers, and one emerged as the defacto benevolent dictator by 2018, with 201 people contributing to 158 releases as of today. It is the defacto cross-platform standard for enumerating hardware components in Java.

The same year our Enterprise product needed a single-sign-on solution for our Java web application, so I created and open-sourced [Waffle](/2010/03/01/waffle-windows-authentication-functional-framework-le.html), which is based on [Java Native Access](https://github.com/java-native-access/jna) that I began contributing to, quickly becoming JNA's co-maintainer. Today, waffle has 4 maintainers, a new benevolent dictator since 2014, and 52 people have contributed to 22 releases. The JNA project is hugely popular, used in anything from OpenSearch to IntelliJ, but only has 9 maintainers, is on its 4th benevolent dictator, and 166 people have contributed to 65 releases.

In 2011, while building Artsy, we standardized on [Grape](https://github.com/ruby-grape/grape), a RESTful API framework alternative to Ruby-on-Rails. I began contributing to the project and earned maintainer rights to it around 2013, eventually becoming the benevolent dictator. I created [the ruby-grape organization](/2015/08/04/ruby-grape.html), and brought in a number of related projects together in 2015. The core Grape project has 7 maintainers today, and 426 people have contributed to 73 releases.

Finally, in 2019 I joined the [OpenSearch Project](https://opensearch.org/) team at Amazon to work on the fork that powers the Amazon Managed and Serverless OpenSearch service. The project is now part of the [Linux Foundation](/2024/09/17/opensearch-joins-the-linux-foundation.html). I am an active co-maintainer of 24 out of 116 repositories in the opensearch-project org on GitHub and benevolent dictator in a few. It has 257 maintainers today, and 1,402 people have contributed to hundreds of releases across the distribution of OpenSearch and OpenSearch Dashboards, ingestion tools, and clients.

To understand the patterns behind these stories, let's examine how projects attract contributors and grow them into maintainers.

Early this year I reached out to the existing maintainers across opensearch-project that did not work for Amazon, and asked them questions about how they became maintainers. 20 have replied. I learned that most came to the project as their businesses were migrating from Elasticsearch to OpenSearch, often because their employer had business needs in OpenSearch, and remained active because they were pleased with how well-maintained, healthy, and high quality these projects were.

This is the recipe that we have followed for 3 years in the repos that I have been involved in.

1. At least one highly engaged maintainer that acts as the project owner or benevolent dictator, and routinely commits code to the repo.
2. Open-source basics including a license, code-of-conduct, security and copyright files and statements.
3. A well-written README.md, project documentation, and a developer guide that one can easily follow to begin contributing without help.
4. High test coverage, code linters, and a reliably passing CI/CD.
5. Engagement from at least one maintainer on every single issue, pull request or comment within 24 hours.
6. Visible recent commit activity, even if just from a dependency manager such as dependabot.
7. Regular releases, a CHANGELOG or release notes.

I often step up to do this in repos I am engaged in and, naturally, in all repos I create. My job as a maintainer is to make all the above points happen as a prerequisite to anyone engaging in a project.

A user with a business need will typically open an issue before contributing code. As a maintainer, I will respond to their inquiry in a way that encourages contribution, even a minimal one. For example, if a user opens a bug, I do not jump in to fix it, especially if it's an easy fix. My typical response is: _Thank you for reporting this issue! Looks like a bug. Would you like to help? Maybe write a (failing) test that reproduces this issue?_ Contributors that write a test often also fix the bug. If a user asks how to do something, I help them and ask them to contribute a sample or additional documentation.

When reviewing pull requests (always within 24 hours) my goal is to get the contribution merged. How can I say _yes_ more often? I try to make sure I am clear about what change is a _must have_, _should have_, or _nice to have_. I reserve must have's for critical misses (e.g. poor APIs that will be hard to change later), and always sweat the small stuff and insist on highest standards (e.g. tests and documentation are always required). This is because one's contribution is never allowed to create more work or technical debt for me or other participants in the project. Finally, I often thank contributors profusely for hanging in there with me through multiple iterations, and apologize for my excessive OCD over periods at the end of sentences. In my experience people take this attention to detail really well and are motivated to contribute to a project that keeps the quality high, often higher than their projects at work that make catastrophic technical compromises to reduce time to market.

At last, if you made any significant, high quality, contribution to one of my open-source projects, and have a decent contribution history on Github, I will ask you to join as a co-maintainer quickly. The bar is quite low, I just need to see that you can be trusted to exhibit the behavior described above as a maintainer. In some ways, this ask is a non-automated, higher touch, softer implementation of the [Moya Contributing Guidelines](https://github.com/Moya/contributors), which I wrote about [here](/2020/06/08/i-ve-asked-you-to-become-an-open-source-project-co-maintainer.html). When people step up I usually step out and let them take over, working myself out of the job. Thus, a strong community of contributors grows around the project, which is the real measure of success.

Do you follow a similar recipe? Have you see open-source projects emerge and succeed in different ways? Let me know!
