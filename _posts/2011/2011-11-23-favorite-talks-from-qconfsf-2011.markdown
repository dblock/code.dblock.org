---
layout: post
title: "Favorite Talks from QConfSF 2011"
redirect_from: "/favorite-talks-from-qconfsf-2011/"
date: 2011-11-23 04:41:52
tags: [conferences, technology, architecture, people]
comments: true
dblog_post_id: 295
---
![]({{ site.url }}/images/posts/2011/2011-11-23-favorite-talks-from-qconfsf-2011/image_5.jpg)

My first QCon, [QConSF ‘11](http://qconsf.com/sf2011/) was very good. I’ve been watching [InfoQ](http://infoq.com) for a very long time and wanted to go to QCon ever since.

What I loved about this conference is that it was mostly technical in nature and that the best speakers were hands-on industry practitioners. I also greatly enjoyed the fact that most attendees were architect-level engineers, which made for well balanced conversations over the frequently supplied drinks. The rare talks that I didn’t like were given by sponsoring companies’ PMs. Yawn.

The first day was like climbing a mountain of infinite wisdom. It started with a panel of software gurus that [put objects on trial](http://qconsf.com/sf2011/presentation/Objects+On+Trial). I’ve been unlearning OOP for the last year of writing Ruby, hence I found myself completely in sync with the prosecution. Along with a number of Russians in the crowd I was particularly touched by the Souz capsule vs. the U.S.A. Shuttle analogy on class reuse. I lived near the Gagarin Square in Moscow. Tears were shed. The Russian space program was a great example of throw-away technology that turned out to be a lot cheaper to manufacture and enabled faster innovation.

There was an entire track dedicated to the concept of beautiful code. I got my Ruby CR/LF alignment porn at [guilhermecaelum's](http://twitter.com/guilhermecaelum) talk and disagreed with about everything else during that track. In general, I think that code is more like a child than a painting. Code might first be cute, but it eventually grows into a complete being with evolved needs that requires additional complexity and structure. You can still teach it new things, but it gets incrementally harder. In contrast, each extra minute you put into a baby’s early days pays off big dividends in the long term.

I frowned during most of [Rod Johnson’s keynote](http://qconsf.com/sf2011/presentation/Things+I+Wish+I%27d+Known) on Thursday. I certainly didn’t expect to hear a call to entrepreneurship at QCon. Much like great engineers often make terrible managers, they often make awful CEOs and CTOs. Running a business is a people, not a technology problem.

Then I went to the [Lean Startup](http://qconsf.com/sf2011/speaker/Joshua+Kerievsky) talk, where [@joshuakerievsky](http://twitter.com/joshuakerievsky) confirmed that lean principles work well for the kind of social location-based coupon technology that thousands are building these days, because most of it will be thrown away anyway as these companies crash and burn. More seriously, I assume some of lean concepts speak poorly to many experienced engineers. Should we validate an idea without writing any code when possible? Yes. Should we write the bare minimum to produce a prototype that learns about the market? No. Prototypes turn into real products much faster in the hands of a business than engineers turn them into solid implementations. Pain, suffering, famine and death ensue. We need to both build high quality code from day one, and build it fast, in order to succeed when we hit product-market fit and the business explodes. That’s also why you should be hiring fewer people from the highest grade of software developer A-list.

I watched [@emcooke's](http://twitter.com/emcooke) excellent [Web API talk](http://qconsf.com/sf2011/presentation/Building+a+Great+Web+API) next. Evan came to [GA](http://generalassemb.ly) a few weeks ago and gave a short version of the talk from a couch to a few techies. This is exactly the kind of talks I wanted to see more of. The guy had his hands in the code. He succeeded at building an API that people loved. He had priceless advice on each and every slide.

I really enjoyed [@stevevinoski’s](http://fr.twitter.com/#!/stevevinoski) the [talk on Webmachine](http://qconsf.com/sf2011/presentation/Webmachine%3A+a+practical+executable+model+of+HTTP). I’ve never written anything in Erlang. At first I saw [Webmachine](http://wiki.basho.com/Webmachine.html) as a silly framework for declarative RESTful programming. But as the talked got into more complex issues a light bulb lit in my head and I think I totally got it. It’s unlikely that I’ll ever get to use this framework, but I went from being a skeptic to actually learning something.

[@daniel_jacobson](http://twitter.com/daniel_jacobson) from Netflix described the [recent evolution of the Netflix API](http://qconsf.com/sf2011/presentation/Techniques+for+Scaling+the+Netflix+API+in+the+Cloud). This was mostly about the internal API that thousands of devices use. They chose to create an API variation for every device a longtime ago and are now bringing scripting-like functionality to a middle-tier, server-side. Think of it as a server-side proxy for your API where you execute sequences of operations that are device-specific. Instead of performing chatty operations between a client and a server, you compile and execute them on the proxy.

There was a [keynote on Dart](http://qconsf.com/sf2011/presentation/Dart%2C+a+new+programming+language+for+structured+web+programming) on Friday. Why you would want to have type-checking during development and turn it off at runtime is beyond me. Does a thousand smart developers make an awesome language? Does a tree fall in the woods?

Fortunately [@rauchg](http://twitter.com/rauchg) killed it in a [live coding session for Socket.IO w/ node.js](http://qconsf.com/sf2011/presentation/Realtime+Web+Apps+with+HTML5+WebSocket+and+Beyond). He built a chatty client-server and OMG, he types way faster than me.

There was a nice NoSQL applications panel where each vendor tried to sell each-other’s products. It was so polite!

Last, but not the least, I met with a bunch of old friends that live in SF and even got to touch a Kindle Fire warm out of Amazon!
