---
layout: post
title: "Waffle 1.3 Released"
redirect_from: "/waffle-13-released/"
date: 2010-07-25 19:19:51
tags: [tomcat, spring, waffle, jna, active directory, win32]
comments: true
---

![waffle]({{ site.url }}/images/posts/2010/2010-07-25-waffle-13-released/waffle_4.jpg)

If you’re writing PInvoke in C# or Java code for Windows authentication, save yourself some time, WAFFLE has these features for you.

- Account lookup locally and in Active Directory via Win32 API with zero configuration.
- Enumerating Active Directory domains and domain information.
- Returns computer domain / workgroup join information.
- Supports logon for local and domain users returning consistent fully qualified names, identity (SIDs), local and domain groups, including nested.
- Supports all functions required for implementing server-side single-signon with Negotiate and NTLM.
- Supports Windows Identity impersonation.
- Includes a Windows Installer Merge Module for distribution of C# binaries.

If you're using Tomcat or Jetty with an IIS front-end to do authentication only, Waffle has the following features and will allow you to get rid of IIS.

- A Tomcat Negotiate (NTLM and Kerberos) Authenticator Valve.
- A generic Servlet Negotiate (NTLM and Kerberos) Security Filter.
- A Tomcat Single Sign-On + Form Authentication Mixed Valve.
- A Spring-Security Negotiate (NTLM and Kerberos) Filter.
- A Spring-Security Windows Authentication Manager.
- A JAAS Login Module.

WAFFLE has originated at [AppSecInc.](http://www.appsecinc.com) and the team deserves the credit. John has [a blog](http://blog.johnhite.com/) too, check it out.
