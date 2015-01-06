---
layout: post
title: "Open-Source Roundup for Early January 2013"
redirect_from: "/open-source-roundup-for-early-january-2013/"
date: 2013-01-21 02:44:11
tags: [open source]
comments: true
---
Aside of all the posts about [recruiting](http://code.dblock.org/help-me-fix-tech-recruiting-become-a-recruiter) (recruiter spam dropped by 75%, amazing, thank you very much), [website performance](http://code.dblock.org/10-things-engineers-and-non-engineers-can-do-to-make-a-website-faster) and the [importance of source code](http://code.dblock.org/treat-every-line-of-code-as-if-its-going-to-be-thrown-away-one-day), I wrote a few posts recently on the [Artsy Engineering Blog](http://artsy.github.com/) and made some open-source gem releases and contributions. It feels really good and there’s a whole new week ahead!

I got very excited with getting my hands into em-proxy and writing [Beat Heroku’s 60 Seconds Application Boot Timeout with a Proxy](http://artsy.github.com/blog/2012/12/13/beat-heroku-60-seconds-application-boot-timeout-with-a-proxy/) using the [heroku-forward](https://github.com/dblock/heroku-forward) gem. I even [contributed to em-proxy](https://github.com/igrigorik/em-proxy/pull/31) itself, adding support for unix domain sockets. It’s exciting because em-proxy is written by [@igrigorik](mailto:i@igrigorik), who is one of those impressive people that I still don’t have the pleasure to know personally. The post was accompanied by a more philosophical piece on [Losing Control to the Heroku PaaS](http://code.dblock.org/losing-control-to-the-heroku-paas). Speaking of losing control, I annoyed the crap out of Heroku developers trying to figure out why an application was timing out during _bundle install_ on Heroku, which turned into an already well trafficked blog post on [Debugging Bundler Issues on Heroku](http://artsy.github.com/blog/2013/01/15/debugging-bundler-issues-with-heroku/). Sorry everyone.

Today I released [mongoid-cached-json 1.4](https://github.com/dblock/mongoid-cached-json) and [garner 0.2](https://github.com/artsy/garner) with some significant performance optimizations for the former, described in [today’s blog post](http://artsy.github.com/blog/2013/01/20/improving-performance-of-mongoid-cached-json/). This was some pretty exciting, although relatively basic CS work, that didn’t always turn out the way you’d expect from performance improvements. My first optimization ran 20% slower than the original – you cannot make assumptions about the runtime characteristics of theoretically better algorithms until you actually benchmark them.

[Grape](https://github.com/intridea/grape) got a lot of love with the release of 0.2.6 after a ton of formatter-related work and security fixes via [multi_xml](https://github.com/sferik/multi_xml) (upgrade!) and I plan to push 3.0 really soon. Generally, Grape is getting much skinnier, faster and lighter: I simplified a lot of internals and entities were taken out into the [grape-entity](https://github.com/agileanimal/grape-entity) gem by [@agileanimal](https://github.com/agileanimal).

Last week I released [guard-rack 1.3.1](https://github.com/dblock/guard-rack) in which [@viking](https://github.com/viking) got rid of .pid files and I finished by making it compatible with all versions of Ruby using the awesome [spoon](https://github.com/headius/spoon) gem (solid replacement for not-so-cross-platform [posix-spawn](https://github.com/rtomayko/posix-spawn)).

Finally, I posted [an amazing study of a horse by George Stubbs on Artsy](http://artsy.net/dblock/post/this-horse-is-a-fantastic-study-of). You can follow me there for all the art, and for my tech stuff, on [Twitter](https://twitter.com/dblockdotorg).
