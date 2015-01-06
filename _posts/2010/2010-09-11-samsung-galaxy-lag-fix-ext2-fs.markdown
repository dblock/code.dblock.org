---
layout: post
title: "Samsung Galaxy Lag Fix: EXT2 FS"
redirect_from: "/samsung-galaxy-lag-fix-ext2-fs"
date: 2010-09-11 13:21:39
tags: [android]
comments: true
---

![Samsung-Vibrant-Galaxy-S-T959]({{ site.url }}/images/posts/2010/2010-09-11-samsung-galaxy-lag-fix-ext2-fs/samsung-vibrant-galaxy-s-t959_3.jpg)

I recently got rid of my Windows mobile phone and upgraded to an Android Samsung Galaxy S (I have T-Mobile). After a few days of installing all my new favorite apps, including _Daily Dilbert_, it was time to do pass onto more interesting things.

#### As usual, all these things will potentially brick your phone. Don’t do it.

Okay, now that decided to do it anyway ...

#### Rooting the Phone

I did this manually, but I realize now that there’re some nice utilities to help you. Notably see the one-click lag fix further. This gives you super-user access for those applications that require it. It also just feels plain good to play G.

#### Wireless Tethering

I stay in the City a couple days a week and used to steal internet access from a neighbor. Since then he revisited his router security and never bothered to give me his new password. It’s also a little awkward to share someone’s connection and it’s not worth it to buy permanent internet access to use it 5-6 times a month. There’s an additional problem of cellular reception in the place, you only get a decent connection (not even 3G) if you sit right by the window. So tethering with a USB cable is not an option – I needed to turn my phone into an actual wireless hotspot.

This can be done with [android-wifi-tether](http://code.google.com/p/android-wifi-tether). The app did hang on me a couple of times when turning tethering on, but I did stream a full Netflix movie with very good quality without interruption one late evening.

#### One Click Lag Fix

![snap20100809_151120]({{ site.url }}/images/posts/2010/2010-09-11-samsung-galaxy-lag-fix-ext2-fs/snap20100809_151120_4.jpg)

The software _"creates a VIRTUAL EXT2 filesystem inside the stock RFS filesystem on the internal SD card, with a 4KB block size. This means that this lag fix creates a buffer between the real filesystem and the android system. This buffer should reduce the amount of disk I/O required for all operations by utilizing EXT2 buffering, as well as not writing file access times to disk, etc."_

Okay, this makes total sense. Download _One Click Lag Fix_ from the Android Market, install and run. The tool will let you root the phone, install the lag fix, etc. Don’t worry about the scary minute or two when the phone goes blank on reboot (and you don’t see your T-Mobile logo after the music). Mine rebooted just fine eventually.

Is it faster? Hell yeah! Download _Quadrant Standard_, a benchmark tool and compare before and after.

#### Android 2.2 (Froyo)?

Android 2.2 (Froyo) should make some of this obsolete. Well, definitely Wireless Tethering. We’ll see when the update hits the Galaxy S this or next month.

