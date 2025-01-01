---
layout: post
title: Harvesting the Low Hanging Fruit in Open Source Projects
date: 2024-12-18 01:00:00
tags: [open source]
comments: true
---
Every active open-source project grows a lot of low hanging fruit. Encouraging project users to harvest some of the yield can be a great way to engage and retain new contributors. Here are some ideas, mostly borrowed from [Barani](https://github.com/bbarani), for low-hanging work items that you can propose to anyone engaging in your project.

***

#### Help Wanted, Good First Issue and Summer of Code

Identify and tag issues that have an easy solution to attract first time contributors.

Good first issues, or issues that are part of programs such as [Summer of Code](https://summerofcode.withgoogle.com/), provide an entry point for new contributors who want to get involved with the project, but are intimidated or unsure where to start. These issues are typically well-defined, self-contained, and relatively straightforward, making them accessible to newcomers.

I could use help with [58 issues](https://github.com/issues?q=is%3Aopen+is%3Aissue+author%3Adblock+archived%3Afalse+label%3A%22good+first+issue%22%2C%22help+wanted%22) right now and there are [683](https://github.com/issues?q=is%3Aopen+is%3Aissue+archived%3Afalse+org%3Aopensearch-project+label%3A%22good+first+issue%22) issues labelled "good first issue" in the opensearch-project GitHub organization.

#### READMEs and Documentation

README.md, documentation and "Getting Started" for developers are often outdated or overlooked in open-source projects. Contributors can begin by fixing typos, improving clarity, or adding examples to existing documentation. This is a great way for new contributors to get familiar with the project's codebase and contribute without making significant code changes.

The recent [transfer of the OpenSearch Project to the Linux Foundation](/2024/09/17/opensearch-joins-the-linux-foundation.html) required a change the code-of-conduct violations e-mail address in `CODE_OF_CONDUCT.md` in [opensearch-project/.github#245](https://github.com/opensearch-project/.github/pull/245). The same, trivial change needs to happen in 116 repositories. We can get some help with [automation](https://github.com/opensearch-project/project-meta?tab=readme-ov-file#make-a-change-in-many-repos), but someone still needs to do it.

#### Updating Dependencies

Most code projects rely on external dependencies, and keeping them up-to-date is crucial for security and compatibility reasons. Contributors can help by identifying outdated dependencies and submitting pull requests to update them to the latest versions.

Almost all projects in the [mongoid GitHub organization](https://github.com/mongoid) would appreciate PRs that add support for newer versions of MongoDB, which is most likely no work other than adding new versions to the CI matrix similar to [mongoid-scroll#45](https://github.com/mongoid/mongoid-scroll/pull/45). Another example is upgrading Gradle in OpenSearch, such as [OpenSearch#16694](https://github.com/opensearch-project/OpenSearch/pull/16694), something that had to be done over 100 times over the last 3 years and could not be automated because it required minor code changes along the way.

#### Improving Test Coverage

Writing tests is an essential part of software development, but it's not uncommon for open-source projects to have gaps in their test coverage or not tests at all. Contributors can help by adding new test cases or improving existing ones, ensuring that the project's codebase is thoroughly tested. Adding code coverage is another easy contribution.

I have recently opened [statusphere-example-app#26](https://github.com/bluesky-social/statusphere-example-app/pull/26) that added tests to the atproto boilerplate example and [mongoid-scroll#47](https://github.com/mongoid/mongoid-scroll/pull/47) that added test coverage.

#### Refactoring Code

As projects evolve, their codebase can become messy and difficult to maintain. Contributors can help by identifying areas that need refactoring and submitting pull requests to improve code readability, maintainability, and performance.

[Eric](https://github.com/ericproulx), one of the maintainers of ruby-grape has been steadily improving the library performance such as in [grape#2513](https://github.com/ruby-grape/grape/pull/2513), or refactoring various parts such as [grape#2475](https://github.com/ruby-grape/grape/pull/2475).

#### Fixing Linting Errors

Most projects have automated linting rules in place to enforce coding standards and best practices. Contributors can help by identifying and fixing linting errors, ensuring that the codebase adheres to the project's coding standards.

You can begin by adding a linter if there isn't one such as [opensearch-api-specification#312](https://github.com/opensearch-project/opensearch-api-specification/pull/312), upgrade RuboCop in Ruby projects such as [grape#2497](https://github.com/ruby-grape/grape/pull/2497), or fix actual violations being ignored in `.rubocop_todo.yml` such as in [grape#2459](https://github.com/ruby-grape/grape/pull/2459).

#### Reporting and Engaging on Issues

Contributors can help by reporting new issues, reproducing existing ones, moving issues forward, or helping categorize issues to help maintainers prioritize their work.

For example, I figured out how to reproduce a rare bug in logstash-output-opensearch in [logstash-output-opensearch#207](https://github.com/opensearch-project/logstash-output-opensearch/issues/207#issuecomment-1688616636), and helped a user enable verbose logging to debug another problem in [logstash-output-opensearch#187](https://github.com/opensearch-project/logstash-output-opensearch/issues/187#issuecomment-1765055939).

#### Creating Examples or Tutorials

Providing examples and tutorials can make it easier for new users to understand and adopt a project. Contributors can create new examples, tutorials, or sample projects to help others get started with the project.

For example, as I was researching various vector database APIs, I [wrote a set of working samples](https://code.dblock.org/2023/06/16/getting-started-with-vector-dbs-in-python.html) for every database. I also implemented an example of using the OpenSearch async Python client with AWS in [opensearch-py#857](https://github.com/opensearch-project/opensearch-py/pull/857) when someone asked me for help.

#### Improving Project Infrastructure

Open-source projects often rely on various tools and infrastructure, such as continuous integration, deployment pipelines, or issue tracking systems. Contributors can help by identifying areas for improvement and submitting pull requests to enhance the project's infrastructure.

For example, I added a feature that makes CI fail when someone accidentally forgets to reference a test suite in the test matrix in [opensearch-api-specification#705](https://github.com/opensearch-project/opensearch-api-specification/pull/705) after someone else came up with this idea.

#### Reviewing Code

Reviewing other people's code could be easier to start with than actual coding. Even they may not have all the knowledge and review all the change, they may still be able to point out some common issues or raise good questions. If their review proves to be valuable to others and with more and more knowledge, they may think of starting contribution as well.

For example, an experienced PHP developer that has never contributed to the project found work in progress by another developer for a problem they had, and jumped in help review it [opensearch-php#233](https://github.com/opensearch-project/opensearch-php/pull/233). I gently nudge both the contributor and the reviewer to get that PR finally merged.

***

In conclusion, by proposing these low-hanging work items, we can encourage new contributors to get involved and make meaningful contributions to open-source projects. It's important to provide clear guidelines, support, and mentorship to help contributors navigate the project's codebase and contribution process. So go ahead, engage with a new project participant, ask them whether they would be interested in, and gently guide them to make their first contribution.