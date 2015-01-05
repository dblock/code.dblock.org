---
layout: post
title: "Why doesn't logging from an immediate custom action work?"
redirect_from: "/why-doesnt-logging-from-an-immediate-custom-action-work"
date: 2008-08-31 23:30:00
tags: [msi]
comments: true
---
Something that has always frustrated me: _Why doesn't logging from an immediate custom action work?_. Christopher Painter pointed out a documented (!) answer.

[http://msdn2.microsoft.com/en-us/library/aa368322(VS.85).aspx](http://msdn2.microsoft.com/en-us/library/aa368322(VS.85).aspx)

_"Note that custom actions launched by a **DoAction** ControlEvent can send a message with the [Message](http://msdn2.microsoft.com/en-us/library/aa371672(VS.85).aspx) method, but cannot send a message with [MsiProcessMessage](http://msdn2.microsoft.com/en-us/library/aa370354(VS.85).aspx). On systems prior to Windows Server 2003, custom actions launched by a DoAction ControlEvent cannot send messages with **MsiProcessMessage** or **Message**. For more information, see [Sending Messages to Windows Installer Using MsiProcessMessage](http://msdn2.microsoft.com/en-us/library/aa371614(VS.85).aspx)."_


