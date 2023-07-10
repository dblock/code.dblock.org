---
layout: post
title: "Jenkins AnsiColor 0.2.1 w/ Support for Conceal Codes"
redirect_from: "/jenkins-ansicolor-021-w-support-for-conceal-codes/"
date: 2012-02-03 13:26:50
tags: [jenkins, java]
comments: true
dblog_post_id: 314
---
I just released [AnsiColor 0.2.0](https://plugins.jenkins.io/ansicolor) that now supports the ANSI conceal code. Conceal code 0x8 is a hacky way to hide data inside text using ANSI sequences. Jenkins uses it to annotate output with something that looks like `ha:<long base64 string>`. You can see this implemented in [ConsoleNote.java](https://github.com/jenkinsci/jenkins/blob/master/core/src/main/java/hudson/console/ConsoleNote.java). The previous version of AnsiColor produced garbage by stripping the conceal sequence, therefore revealing the content inside the conceal block ([issue #3](https://github.com/dblock/jenkins-ansicolor-plugin/issues/3)). Fixed in [this commit](https://github.com/dblock/jenkins-ansicolor-plugin/commit/c804caf8f1f785a0bd0eaf47f231a1f22b8b0356). Also updated [Jansi](https://github.com/fusesource/jansi/) to 1.7 – Jansi makes this plugin possible.

Update your Jenkins.
