---
layout: post
title: "Writing a Slack Bot running on Rails (with React)"
date: 2015-11-28
tags: [slack, bot, rails, react]
comments: true
---
I cooked up a little demo of a Slack bot running on Rails with React, that displays messages that you send to Slack, on a web page.

tl;dr Check out [github.com/dblock/slack-bot-on-rails](https://github.com/dblock/slack-bot-on-rails).

![demo]({{ site.url }}/images/posts/2015/2015-11-28-writing-a-slack-bot-running-on-rails-with-react/tattletale.gif)

We start with a vanilla Rails app created via `rails new slack-bot-on-rails --skip-activerecord -T`, in [@d092f4ed](https://github.com/dblock/slack-bot-on-rails/commit/d092f4ed7f16aee27cdfde837a3a420df182f81a).

Add [slack-ruby-bot](https://github.com/dblock/slack-ruby-bot) that responds to `say something`, in [@a93877ae](https://github.com/dblock/slack-bot-on-rails/commit/a93877ae77d0fa1935b1c847af61dab346a46b78).

Slap on top a React app that displays messages sent to Slack, in [@9632e9f1](https://github.com/dblock/slack-bot-on-rails/commit/9632e9f157bc97eab15c5588bc493550eb2ac5ba).
