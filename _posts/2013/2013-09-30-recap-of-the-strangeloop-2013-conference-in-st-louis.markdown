---
layout: post
title: "Recap of the StrangeLoop 2013 Conference in St. Louis"
redirect_from: "/recap-of-the-strangeloop-2013-conference-in-st-louis/"
date: 2013-09-30 13:27:30
tags: [learning, conferences]
comments: true
dblog_post_id: 395
---
[StrangeLoop](https://thestrangeloop.com), takes place in St. Louis, MO. I would describe it as a conference of emerging languages, attracting engineers from all over the world. The breadth of thought process, technologies and creativity is probably only second to arts and tech conferences (I’m particularly excited about the upcoming [LISA](http://softwareandart.com/?page_id=1161) conference in NYC). People that go to StrangeLoop seem like a diverse set, although I ran into far too many Enterprise-y developers and even a banker (to be fair, he was attending a vampire symposium in the same hotel).

My all time favorite talk was _Creative Machines_, by [@josephwilk](https://twitter.com/josephwilk). Can we distinguish between a machine’s creative attempts and human’s? The talk, illustrated with code and music touched a lot of profound questions and I felt truly immersed into its message.

My second favorite was about performance in Dynamic Languages by [@love2code](https://twitter.com/love2code). Maxime gave an overview of the dynamic language history, including Fortran and LISP, including a very interesting foray into LISP machines. Another related talk was "Why Ruby isn’t Slow" by [@alex_gaynor](https://twitter.com/alex_gaynor), who was pretty hilarious. Did you know that JavaScript’s _toString_ doesn’t have to return a String? I am sprinkling this all over our massive JavaScript codebase as we speak. More seriously, this means the + operator has to deal with many types, which can be optimized away with a JIT compiler.

My third favorite talk was about machine learning by [@jrfinkel](https://twitter.com/jrfinkel) from Prismatic. There were a lot of similarities with the kinds of things we deal with at [Artsy](http://artsy.net), starting with how to measure _serendipity_. Prismatic decided on targeting user-engagement and settled on an interaction-based metric: who clicks what. Whereas we make this a nearest neighbor problem, they bent it into an ML one. The training set is a model of articles-to-user-interactions (how likely a user is to respond to a document) and the features include the topics that a user follows, the number of times a user clicked on a publisher, whether an article has a picture or the number of other users who have liked this article. These are weighted and the total score is the dot product of features and weights. User session logs are used to come with weights. Jenny also talked about presentation bias, where things that appear on top are most frequently clicked. All-in-all this was a very thorough, strong talk in which I learned about a practical and completely different approach to a problem I am well familiar with.

Finally, I want to acknowledge the work by the organizers. This was a very well run conference and I’ll likely be back next year.
