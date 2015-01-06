---
layout: post
title: "OCLF: One Click Lag Fix on Android 2.2 (Galaxy S)"
redirect_from: "/oclf-one-click-lag-fix-on-android-22-galaxy-s"
date: 2011-01-31 04:08:41
tags: [android]
comments: true
---
![]({{ site.url }}/images/posts/2011/2011-01-31-oclf-one-click-lag-fix-on-android-22-galaxy-s/image%5b2%5d.jpg)

Continuing to play with things I don’t need on my phone today. Applying the One Click Lag Fix (OCLF in the Market) was a bit harder. I got _OneClickLagFix V2.2+ failed with error: Could not mv playlogos1 to playlogosnow – mv: can’t rename ‘/system/bin/playlogos1’: Read-only file system_.

To fix this, I hat to download a Terminal Emulator and remount the system partition r/w manually.

```
su -
mount -o remount,rw /dev/block/stl9 /system
```

Run `mount` without any parameters first to check that `/system` is indeed `/dev/block/stl19`.

The lag fix hung the first time on dd (it should only take 30 seconds or so at the most), but worked the second time around after a reboot.

Does the lag fix help? No idea, we’ll see.
