---
layout: post
title: "Oracle 0-day: how complex systems allow simple attacks"
redirect_from: "/oracle-0-day-how-complex-systems-allow-simple-attacks"
date: 2010-02-10 14:00:00
tags: [security, databases]
comments: true
---
![]({{ site.url }}/images/posts/2010/2010-02-10-oracle-0-day-how-complex-systems-allow-simple-attacks/image_5.jpg)

Since I work in database security, I heard "Oracle 0-Day" about every 15 minutes in the past few days [read this for details](http://www.notsosecure.com/blog/2010/02/04/hacking-oracle-11g/). I watched the David Litchfield’s Blackhat presentation with the Oracle 11G 0-day exploit (the video was pulled down from Blackhat’s site and is now back [here](https://media.blackhat.com/bh-dc-10/video/Litchfield_David/BlackHat-DC-2010-Litchfield-Oracle11g-video.m4v)). The vulnerability is business as usual, while the fact that it’s a zero-day must really be upsetting for Oracle – if you have an Oracle 11G, it would seem that there’s nothing you can do. Well, it’s not entirely true – we already distributed to our customers a knowledgebase update with fix scripts that revoke those evil privileges that prevent the vulnerability from being exploited. Applying it is another story because you might have applications that need those, but this is not the subject of my post.

When I was at Microsoft I worked on Microsoft Billing amongst other things. I heard "Secure Code Initiative" just about as many times as ["Oracle 0-Day" in those years](http://www.dshield.org/diary.html?storyid=1877). We focused on making systems simpler and more secure by design. Once the usual suspects of buffer overrun types were removed by not using `strcpy` and friends, it’s simple software design that eventually would yield secure software. SQL server is a great example, there hasn’t been a single severe vulnerability since SQL 2005. Oracle should go through a serious transformation of its programming and architecture practices, and simplify the system by core design. I mean, seriously, `DBMS_JVM_EXP_PERMS` mixed with a whole stack of Java APIs? Removing this kind of crap might be painful, but will go a long way to help sell more Oracle databases – otherwise, mark my words, it’s only a matter of time till a new generation of software and programmers makes Oracle databases obsolete and replace those monsters by cheaper, leaner alternatives.

Now let me see what other 0-day vulnerabilities for Oracle I have written on this napkin laying on my desk ...
