---
layout: post
title: "JNA is now a Githubber"
redirect_from: "/jna-is-now-a-githubber"
date: 2011-06-20 13:32:09
tags: [github, git, open source, jna, java]
comments: true
---
![]({{ site.url }}/images/posts/2011/2011-06-20-jna-is-now-a-githubber/image%5b10%5d.jpg)

JNA is one of the most popular Java Libraries that doesn’t belong to a large community, such as Apache. It’s mostly maintained by Timothy Wall. There’re hundreds of people on the mailing list and many contributors. Every time I see a Java project that runs on various platforms, especially on Windows, I see JNA. We all need to call native functions, and JNA makes it super easy.

Here’s our new home. And, naturally, it’s on Github. Scroll down on that page a bit and you’ll see updated docs, download links, etc.

[https://github.com/twall/jna](https://github.com/twall/jna)

#### The long story ...

We were not unhappy with the old Java.net site, it worked fine and while it didn’t offer amazing collaboration features, it looked pretty good and lots of problems were ironed out over the hundreds of years of development on the site. People submitted patches and all went well. Then someone decided that it wasn’t good enough and created project Kenai. But it seems that the Kenai people worked in some kind of bubble and produced what Java.net is today, a crappy CMS. We [really tried to make it work for us](/jna-coming-back-to-life-on-kenai-and-a-word-on-github), but it’s just not worth our time.

Java.net has been and continues to be about content management, but developers want collaboration. The fundamental goals don’t align with what we need.

Oracle has outsourced Java.net in March to a company called Cognisync. The first thing Cognisync did was a [press release](http://www.cognisync.com/news/company/03_01_11_javanet).

You can imagine a few sales execs in a room making a deal and celebrating with a nice bottle of expensive French champagne, before instructing the marketing team to make a press release and throwing the thing over the cubicle walls to an understaffed team of developers. How do you feel about improving this giant mess? It’s so crappy, it’s a challenge, you’re going to love it! I’ve lived through some of similar scenarios in various big and small companies, my opinion is that it’s highly unlikely that Cognisync or anybody else is capable of transforming Java.net from a dying weed into a thriving flower.

![]({{ site.url }}/images/posts/2011/2011-06-20-jna-is-now-a-githubber/image%5b18%5d.jpg)

The user experience of Java.net sends you back by a decade. It seems that the team never had a designer. There’re big navigation problems and some small ones. For example, you cannot get rid of the links about Java.net under the "Get Involved" section. If I am looking at JNA and I see "Get Involved", I want to get involved in JNA, duh. The same goes for "Get Informed". It leads to all kinds of places. Generally 80% of the layout has nothing to do with your project and replacing the whole thing with your own site (seems possible, Glassfish has [done it](http://glassfish.java.net/)) is a total overkill for smaller teams like JNA. I’d rather write some more code for the project itself than have to struggle with building a website on top of Kenai.

![]({{ site.url }}/images/posts/2011/2011-06-20-jna-is-now-a-githubber/image%5b14%5d.jpg)

Writing on forums is like talking to a wall. I wrote a post asking how to change something in the layout and it vanished in the last migration from forum system X to system Y. I can’t find it anymore. It was up for a while and nobody answered.

When the site undergoes maintenance it can be down or in read-only mode over an entire week-end. It’s just poor planning, trying to push too large of a change online. For an open-source collaboration platform or any serious service a downtime of more than a few minutes is just not OK. Here’s the note after which my post was nowhere to be found.

![]({{ site.url }}/images/posts/2011/2011-06-20-jna-is-now-a-githubber/image5%5b1%5d.jpg)

Seriously? You _may_ be able to access the site in read-only mode over the week-end? Otherwise you get this experience.  It should just say "Not Working".

![]({{ site.url }}/images/posts/2011/2011-06-20-jna-is-now-a-githubber/image%5b19%5d.jpg)

But I am venting, for which I apologize. I think that it’s a shame that Java.net is not becoming a true platform for Java collaboration. I see projects abandoning that ship as fast as they can and never look back. And if they aren’t, it’s because their coordinators have never used Github or are still weighing pros and cons of the cost of moving. Talking about pros, today we had our [second pull request](https://github.com/twall/jna/pull/2) with a large chunk of code in the Win32 platform library, for which I could easily make a code review, add comments and hopefully merge soon. A successful platform for collaboration is ultimately about removing barriers and Github excels in that.

With this, I am much happier today. JNA became a Githubber.
