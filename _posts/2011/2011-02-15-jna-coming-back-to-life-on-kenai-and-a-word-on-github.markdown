---
layout: post
title: "JNA: Coming back to Life on Kenai (and a word on Github)"
redirect_from: "/jna-coming-back-to-life-on-kenai-and-a-word-on-github"
date: 2011-02-15 18:50:19
tags: [open source, jna, java]
comments: true
---
You might have heard about the massive controversy about [Hudson’s move to Github](http://www.infoq.com/news/2011/02/sonatype-hudson). I could have stirred a big storm in a cup for the [Java Native Access (JNA)](https://github.com/twall/jna/) project, but instead of I spent a few hours this morning resurrecting it back to some life form on [Kenai](http://kenai.com/) [[JNA-172](http://java.net/jira/browse/JNA-172)]. It was about time, even [people on Habrahabr noticed](http://habrahabr.ru/blogs/java/113436/). I heard from [@toddfast](http://java.net/people/85599-toddfast)  who is working on a 3.2.8 release too, so all will be good soon.

#### Website

The new live JNA url is [https://github.com/twall/jna/](https://github.com/twall/jna/).

#### Logo

To celebrate the new old JNA, I added a logo. I found this one on the internet, so this is the biggest change. I hope you like it.

![jnalogo]({{ site.url }}/images/posts/2011/2011-02-15-jna-coming-back-to-life-on-kenai-and-a-word-on-github/jnalogo%5b4%5d.jpg)

#### Migration

I tried the Kenai Wiki and it worked quite well. But we have tons of existing content in SVN, so I created a website in the features section of the JNA project. This enabled Webdav on [https://jna.java.net/](https://jna.java.net/) and a /website/jna/ path into which I can upload files. This is [documented here](http://kenai.com/projects/help/pages/UploadWebsiteFiles). Uploading files basically brings the old content into the Kenai infrastructure. I used [BitKinex](http://www.bitkinex.com/) to upload, obviously we need to enable an SCM hook [[JNA-177](http://java.net/jira/browse/JNA-177)]. This is the same as it worked on the old java.net.

#### Issues?

If you find issues with the JNA site, please [create them in JIRA](http://java.net/jira/browse/JNA).

#### Source Control

Check out JNA source code from [https://svn.java.net/svn/jna~svn/trunk](https://svn.java.net/svn/jna~svn/trunk "https://svn.java.net/svn/jna~svn/trunk").

#### Famous Last Thoughts

I would pick [Github](https://github.com/) over Kenai for any new project ten times out of ten. Kenai is fairly ugly and feels a bit clunky. It’s a collection of somewhat aggregated services, including decent wiki markup and JIRA. Where Kenai fails miserably is at creating a true collaborative environment around the open-source code, something that Github is awesome at (think pull requests and markdown rendering tightly integrated around code). IMHO those collaboration tools is what makes Github so wonderful! (Note that I still do like CodePlex, so I would pick Github over CodePlex maybe 3 times out of 5 :))

#### Update (2015)

JNA can now be found [on Github](https://github.com/twall/jna).

