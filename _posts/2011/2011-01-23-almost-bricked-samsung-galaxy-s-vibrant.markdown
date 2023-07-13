---
layout: post
title: "Almost Bricked Samsung Galaxy S Vibrant"
redirect_from: "/almost-bricked-samsung-galaxy-s-vibrant/"
date: 2011-01-23 06:57:54
tags: [android, google]
comments: true
dblog_post_id: 159
---
Today I almost bricked my Android. Rest assured, it all ends well.

It all started with my phone hanging. I use a relatively old version of [Wireless Tether](https://code.google.com/p/android-wifi-tether), which always hangs if I turn it on in this one place in New York City (it never hung anywhere else, ... ever!). I happen to visit this place very often and use wireless tether there all the time. Usually, I can reboot the phone an turn tether back on. Annoying, but not a big deal. But this afternoon the phone failed to reboot and got stuck at the Samsung S logo. I quickly speculated that it coincided with the Android 2.2 (Froyo) release for the Galaxy and that TMobile sent some secret message to my phone to die.

I was facing the beautiful Samsung logo in frustration. I had a problem. Thank G. for XDA-developers and, in my case, [https://forum.xda-developers.com/showthread.php?t=734475](https://forum.xda-developers.com/showthread.php?t=734475).

Two hours into reading confusing instructions on the internet, I got really good at getting the system update mode (power off, hold up and down key, press power, release power) an the download mode (power off, hold up and down key, then plug a USB cable). I downloaded the TMobile ROM for my phone and Odin. The first time I ran Odin it hung in trying to update cache.frs.

After I rebooted my phone again, I got the screen of death. Since many posts talk about people throwing their phones out of the window after seeing this, I really thought I just bricked mine. I was already thinking of hitting my phone with a hammer or sinking it in a bucket of acid (I do have a bucket of acid and the "I am stupid" phone insurance that covers everything, provided you don’t root your phone or the repair people can’t figure out what happened).

![]({{ site.url }}/images/posts/2011/2011-01-23-almost-bricked-samsung-galaxy-s-vibrant/image_12.jpg)

I then read [an article](https://web.archive.org/web/20160227185208/https://www.jamie.co.za/2010/11/19/bricked-samsung-galaxy-s) about how to hack a USB cable to force the phone back in download mode and started googling for parts. Thankfully, the simpler solution (hold the up and down key, plug the USB cable instead of pressing power) worked instantly.

![]({{ site.url }}/images/posts/2011/2011-01-23-almost-bricked-samsung-galaxy-s-vibrant/image_16.jpg)

To fix the cache.frs hang, I had to disable driver signature verification on my Windows 7 (didn’t need to reboot).

![bricked2]({{ site.url }}/images/posts/2011/2011-01-23-almost-bricked-samsung-galaxy-s-vibrant/bricked2_3.jpg)

Odin then worked like a charm.

![bricked1]({{ site.url }}/images/posts/2011/2011-01-23-almost-bricked-samsung-galaxy-s-vibrant/bricked3_2.jpg)

The phone rebooted with Android 2.1. Success!

#### Upgrading to Froyo

I have my phone back. So what can I do to make things worse? Android 2.2 is really here for the Galaxy! T-Mobile told me the update would be available "shortly" in September, but I am familiar with software schedules slipping. I knew they meant January. Did I really care? I was perfectly happy with 2.1. But 2.2 > 2.1, so I had to try it. I followed the instructions [here](https://web.archive.org/web/20110207230012/https://forums.t-mobile.com/t5/Samsung-Vibrant/Samsung-Vibrant-software-upgrade-to-Android-2-2-Froyo-now/td-p/678871). It didn’t quite work and produced download errors at first. Then, after restarting Kies as Administrator (I am on Windows 7) it decided to update itself.

![]({{ site.url }}/images/posts/2011/2011-01-23-almost-bricked-samsung-galaxy-s-vibrant/image_5.jpg)

Phone updated an running. I can go sleep now. Lots of rooting and apps to install tomorrow.
