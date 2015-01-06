---
layout: post
title: "Unable to Obtain Stable Firefox Connection in 60 seconds: Downgrading Firefox on Ubuntu"
redirect_from: "/unable-to-obtain-stable-firefox-connection-in-60-seconds-downgrading-firefox-on-ubuntu"
date: 2011-08-17 16:43:33
tags: [testing]
comments: true
---
![image]({{ site.url }}/images/posts/2011/2011-08-17-unable-to-obtain-stable-firefox-connection-in-60-seconds-downgrading-firefox-on-ubuntu/image%5b5%5d.jpg)

Firefox 6 just made its way on my Ubuntu installation. That broke Capybara tests that use selenium-webdriver with the annoying _unable to obtain stable firefox connection in 60 seconds _error_. _Looks like support for Firefox 6 has just been committed and there’s nothing released._ _So hold your upgrades!

If you’re like me and just hit update, downgrading to an older version of Firefox is going to be non-trivial. The Firefox people make it super hard by hiding older versions and not versioning packages. They also make it particularly hard to run multiple versions, at least in my experience. I finally managed to go back to 3.6 with [these instructions](http://blog.troyastle.com/2011/06/downgrade-to-firefox-36-on-ubuntu-natty.html) and in the process learned something about  _apt-cache policy _that can be tweaked to prefer distribution sources. Now, where can I find a distribution of Firefox 4 or 5 and how do I install it?
