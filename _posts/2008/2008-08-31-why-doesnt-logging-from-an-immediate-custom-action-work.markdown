---
layout: post
title: "Why doesn't logging from an immediate custom action work?"
redirect_from: "/why-doesnt-logging-from-an-immediate-custom-action-work/"
date: 2008-08-31 23:30:00
tags: [msi]
comments: true
dblog_post_id: 10
---
Something that has always frustrated me: _Why doesn't logging from an immediate custom action work?_. Christopher Painter pointed out a documented (!) answer.

[https://learn.microsoft.com/en-us/windows/win32/msi/doaction-controlevent](https://learn.microsoft.com/en-us/windows/win32/msi/doaction-controlevent)

_"Note that custom actions launched by a **DoAction** ControlEvent can send a message with the [Message](https://learn.microsoft.com/en-us/windows/win32/msi/session-message) method, but cannot send a message with [MsiProcessMessage](https://learn.microsoft.com/en-us/windows/win32/api/msiquery/nf-msiquery-msiprocessmessage). On systems prior to Windows Server 2003, custom actions launched by a DoAction ControlEvent cannot send messages with **MsiProcessMessage** or **Message**. For more information, see [Sending Messages to Windows Installer Using MsiProcessMessage](https://learn.microsoft.com/en-us/windows/win32/msi/sending-messages-to-windows-installer-using-msiprocessmessage)."_

