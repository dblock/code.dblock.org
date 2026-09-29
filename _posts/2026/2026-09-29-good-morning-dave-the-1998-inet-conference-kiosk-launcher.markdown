---
layout: post
title: "Good Morning, Dave: the 1998 INET Conference Kiosk Launcher"
date: 2026-09-29
tags: [ai, open-source]
---

In July 1998, the Internet Society held INET '98, "The Internet Summit", at Palexpo in Geneva. The University of Geneva provided about 250 computers for the conference, and I was a student there. I wrote much of the conference network's website, [www.inet98.ch](https://dblock.github.io/inet98/), and the [launcher](https://github.com/dblock/inet98/tree/master/app) that ran on the public Windows 95 PCs instead of Explorer.

![The Inet 98 Launcher running under Wine on macOS](/images/posts/2026/2026-09-29-good-morning-dave-the-1998-inet-conference-kiosk-launcher/inet98-launcher.gif)

The Inet 98 Launcher was a full-height bar on the left of the screen with a button for each installed application: Internet Explorer, Netscape, PC Pine, Telnet, WS-FTP and Office 95 and 97. I wrote it in Delphi 3. It showed a screen saver when a machine sat idle, reset itself, and could reboot the PC to return it to a clean state.

It also had a remote-control server on TCP port 895. Staff could connect from anywhere on the network, type a password and send a message to a user, hide the bar, start the screen saver, or reboot the machine. A wrong password got "alarm has been activated, you are logged!". The right one got "Good morning dave!".

This is the launcher running again today, under Wine on macOS. The buttons change icon on hover. The hidden `-stats` command asks for a password and shows the activity counters. A remote session then logs in. It gets the alarm on a wrong password and the greeting on the right one. Then it sends a message, hides and shows the bar, reads machine stats and starts the screen saver.

The conference was also the first time I had access to a T1 line to the US. Once the machines were up and running, there wasn't much left for me to do, so I spent hours on IRC.

I found the source of both recently. They're now at [dblock/inet98](https://github.com/dblock/inet98).

[![The INET '98 network website](/images/posts/2026/2026-09-29-good-morning-dave-the-1998-inet-conference-kiosk-launcher/inet98-website.png)](https://dblock.github.io/inet98/)

### Building It Again

I don't have Delphi 3, so with Copilot I ported the launcher to Free Pascal and Lazarus. It builds with the Windows version of the compiler and runs under Wine on macOS.

Most of the work was in the details. The binary Delphi forms had to be converted to text. Several embedded bitmaps had headers that Delphi tolerated and Lazarus didn't. My button component drew into its own device context and came out blank. A background thread started before the main form existed. The Delphi socket components are gone, so a small replacement is built on Free Pascal's sockets. macOS doesn't let a normal user listen on port 895, so it listens on 10895. The password dialog's OK button did nothing, because Lazarus doesn't apply a button's default result when it loads a form.

The [full list](https://github.com/dblock/inet98/blob/master/app/README.md#what-it-took-to-port), the original source, the port, the build scripts and a prebuilt `inet98.exe` are all [on GitHub](https://github.com/dblock/inet98).
