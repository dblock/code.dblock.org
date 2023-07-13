---
layout: post
title: "The AlexaJS Community Organization"
date: 2017-01-16
tags: [alexa, amazon, echo]
comments: true
---
![alexa-js]({{ site.url }}/images/posts/2017/2017-01-16-the-alexa-js-community-organization/echo-dot.png)

You may have seen my previous posts on [Bringing Artsy to Amazon Echo](https://artsy.github.io/blog/2016/11/30/bringing-artsy-to-amazon-echo-alexa) and [Hacking on Multiple Alexas](/2016/12/15/hacking-on-multiple-amazon-echo-alexas.html).

I found the Amazon JavaScript ecosystem around Alexa too terse and the independent efforts to address that somewhat spread out, despite some excellent open-source libraries, such as [alexa-app](https://github.com/alexa-js/alexa-app). Over the past couple of weeks I tried to help out by creating a home for the many Alexa Javascript projects. The new home for these is [github.com/alexa-js](https://github.com/alexa-js) and the many library maintainers have kindly agreed to move their projects into it.

* [alexa-app](https://github.com/alexa-js/alexa-app): The place to start, a framework for Alexa (Amazon Echo) apps, written and maintained by [Matt Kruse](https://github.com/matt-kruse).
* [alexa-app-server](https://github.com/alexa-js/alexa-app-server): An Alexa app server hosted on Express.js for multiple instances of alexa-app skills, also written by Matt.
* [alexa-utterances](https://github.com/alexa-js/alexa-utterances): A library that generates expanded utterances for Amazon Alexa from a template string, heavily relied upon by alexa-app, written by [Mike Reinstein](https://github.com/mreinstein).
* [alexa-verifier](https://github.com/alexa-js/alexa-verifier): Verifies that HTTP requests sent to an Alexa skill were sent from Amazon, also written by Mike.
* [alexa-verifier-middleware](https://github.com/alexa-js/alexa-verifier-middleware): A middleware that helps integrate alexa-verifier into an Express.js application, used by alexa-app-server and written by [Tejas Shah](https://github.com/tejashah88).
* [alexa-app-router](https://github.com/alexa-js/alexa-app-router): A router for alexa-app, written by [Nick Coury](https://github.com/nickcoury).
* [alexa-home-server](https://github.com/alexa-js/alexa-home-server): A library that enables self-hosting of an alexa-app server, written by [Ray Zane](https://github.com/rzane).

The new organization reduces bus factor, but doesn't impose any kind of structure. Having these libraries in one place helps visibility and has already paid off with such examples as Tejas contributing almost full test coverage and lots of bug fixes into alexa-app-server via [alexa-app-server#32](https://github.com/alexa-js/alexa-app-server/pull/32) and [alexa-app-server#34](https://github.com/alexa-js/alexa-app-server/pull/34).

I encourage you to move projects into the alexa-js org if they fit. Just open an issue in your own repo like [this one](https://github.com/alexa-js/alexa-utterances/issues/18), cc-ing @dblock. This enables continuity when you decide that you no longer want to be involved in your project. It also allows project maintainers (you) to designate other project maintainers, something you cannot currently do on a personal project on Github, effectively requiring followers to fork the project in case you disappear.

This effort is not sponsored or affiliated with Amazon in any way, of course.
