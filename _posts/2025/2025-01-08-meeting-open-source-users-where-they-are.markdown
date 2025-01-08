---
layout: post
title: Meeting Open Source Users Where They Are
date: 2025-01-08 01:00:00
tags: [open source]
comments: true
---
Most paying customers expect a certain level of (paid) support. One opens a ticket, gets a response, and any issue can be resolved.

But how does "support" work in open-source? My rule of thumb is to meet users _where they are_.

GitHub projects have issues, but opening an issue to ask a question is generally frowned upon. Therefore, in JNA, we have a [mailing list](https://groups.google.com/g/jna-users), and in OpenSearch, we have [a forum](https://forum.opensearch.org) and [Slack](https://opensearch.org/slack.html). StackOverflow is quite popular, too.

For a small project I choose **GitHub issues** as the preferred and only channel. It keeps things well organized and is the least amount of overhead for both users and maintainers. Most questions can be turned into either an issue (e.g. _"I have tried this, and did not get the expected results."_), or a feature request (e.g. _"Would it be possible to add a feature that works as follows?"_). I like to use templates, such as [these](https://github.com/opensearch-project/.github/tree/main/.github/ISSUE_TEMPLATE) to help guide users in opening issues with enough information to get meaningful help.

For a larger project that has multiple areas of interest I like **Slack** with dedicated channels for various areas, such as the [#clients](https://opensearch.slack.com/archives/C051XNH62KB) channel on the OpenSearch public Slack. As a (co)maintainer of OpenSearch clients my responsibilities are as follows.

1. **Create the channel**. This is a public channel so that anyone in the workspace can join and participate, someone has to make one.
2. **Set channel purpose and topic**. Clearly define the purpose and topic of the channel. For example, the purpose could be _"A space for discussing contributions to our project, including bug reports, feature requests, and code contributions."_ The topic can provide a brief overview of the contribution guidelines and processes.
3. **Pin important messages**. Pin any important messages or documents related to contributing to the project, such as the contribution guidelines, code of conduct, or relevant links to your project's repository or issue tracker.
4. **Encourage participation**. Announce the new channel to community members in #general and encourage everyone to join and actively participate in the conversation. You can share the channel link or invite them directly.
5. **Moderate and respond**. Monitor the channel regularly. Respond to questions, provide guidance, and ensure that discussions remain constructive and aligned with project's contribution guidelines. I usually sweep my channels bi-weekly and respond to any message that has not been answered by someone else.
6. **Triage and assign issues**. When contributors report bugs or suggest new features, ask them to create issues in project's issue tracker, and share the links in the channel to close the loop. Work with the members of the channel to try and assign someone to investigate and address these issues when they are willing to help.
7. **Celebrate contributions**. Recognize and celebrate contributions from community members. Share updates on merged pull requests, thank contributors, or highlight notable contributions in the channel.
8. **Provide feedback**. Encourage contributors to share their experiences and provide feedback on the contribution process. Use this feedback to improve the guidelines, documentation, or processes as needed.
9. **Share updates and announcements**. Use the channel to share releases, updates, announcements, or changes related to your project's contribution processes or guidelines.

An interesting aspect of the open-source OpenSearch is that it's also offered as a paid managed service on AWS. Therefore, it's common for an AWS customer to ask a question about using OpenSearch in the managed environment, which is mostly identical to using the open-source product. Many such customers are willing to do some work and will often help narrow the problem down by trying the open-source version. Such customers always appreciate the closer feedback loop of the developer community on Slack, and the ability to resolve their issues in code by themselves, which is another example of meeting your ~~users~~ customers where they are.
