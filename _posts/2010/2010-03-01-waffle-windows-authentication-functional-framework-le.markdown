---
layout: post
title: "WAFFLE: Windows Authentication Functional Framework (LE)"
redirect_from: "/waffle-windows-authentication-functional-framework-le/"
date: 2010-03-01 18:28:04
tags: [waffle, java, dotnet, active directory, win32]
comments: true
dblog_post_id: 85
---
[![](https://github.com/dblock/waffle/raw/master/waffle.jpg)](https://github.com/dblock/waffle/)

I am pleased to announce the open-sourcing of WAFFLE.

> [https://github.com/dblock/waffle](https://github.com/dblock/waffle)

#### WAFFLE** stands for **W** indows **A** uthentication **F** unctional **F** ramework ( **L** ight **E** dition). WAFFLE is a .NET library with a COM interface and a Java bridge that provides a working implementation of server-side Windows authentication, including Forms, Negotiate, NTLM and other SPNEGOs.

_The long story:_

[We](https://web.archive.org/web/20131111165225/https://www.appsecinc.com) had a pickle. Our enterprise application, written in Java, needed Windows Forms authentication. We had no idea how to do this. After logon we wanted to get the logged on user's SID, a fully qualified name and domain groups, including nested ones to match an account in our database. Then we wanted to allow users to switch the application from Forms authentication to Windows authentication with single sign-on. Hard to believe, but we couldn't find anything that did what we wanted! So we wrote WAFFLE. Today we use JAAS and Tomcat and WAFFLE as a back-end, allowing our users to do all of forms logon, Windows NTLM, Negotiate and Kerberos (SPNEGO) authentication. WAFFLE is written in .NET and we use a Jacob Java bridge for interop. In some near future we’ll add the Java code that does Negotiate and NTLM in a Tomcat valve, it’s pretty straightforward.

If nothing else, this code serves as a clean and working example for everything related to [LogonUser](https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-logonusera), [InitializeSecurityContext](https://learn.microsoft.com/en-us/windows/win32/api/sspi/nf-sspi-initializesecuritycontexta) and [AcceptSecurityContext](https://learn.microsoft.com/en-us/windows/win32/api/sspi/nf-sspi-acceptsecuritycontext) APIs.

