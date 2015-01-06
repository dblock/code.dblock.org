---
layout: post
title: "CryptProtectData and FIPS 140"
redirect_from: "/cryptprotectdata-and-fips-140"
date: 2009-11-18 12:45:00
tags: [security]
comments: true
---
In the past years at [Application Security Inc.](http://www.appsecinc.com) I've learned a lot about selling software to the US governement, including very secretive organizations such as the CIA, DOJ, IRS, branches of the miltary, etc. (I am just providing this list as an example - I am not saying we actually sell anything to these specific organizations - that information is classified). Selling to the governement is a whole different beast and requires significant attention from engineering towards certifications like [EAL](http://en.wikipedia.org/wiki/Evaluation_Assurance_Level) or [FIPS](http://www.itl.nist.gov/fipspubs/).

FIPS is an interesting one. Microsoft did a good job at figuring out its FIPS story, but there remains one cloud that is strangely unclear: is [CryptProtectData](http://msdn.microsoft.com/en-us/library/aa380261(VS.85).aspx) and [CryptUnprotectData](http://msdn.microsoft.com/en-us/library/aa380882(VS.85).aspx) FIPS-140? It's just not documented anywhere and nobody would really say.

When I worked at Microsoft I spent quite a bit of time in building 41 (if I remember correctly) at Windows NT Securty. I was working on Passport authentication for Netdocs and then Microsoft Billing. It was easy to get an answer to questions that involved SSPI or Kerberos from people who knew what they were talking about. Hence I was pretty excited to see a beginning of an [answer to this question from John Banes on microsoft.public.platformsdk.security](http://groups.google.com/group/microsoft.public.platformsdk.security/browse_thread/thread/9be4bf54574d5ad9?hl=en). Then he said: "Well, I cannot make any official statements any more." Conspiracy theories start here!

Anyway, Microsoft support was very helpful. So while they update the documentation here's the gist of it.

> DPAPI uses a FIPS-validated cryptographic implementation for encrypting data in Windows XP and later OS versions.  DPAPI’s encryption functionality in Windows 2000 used DES, which is no longer an Approved algorithm under FIPS 140.

You don't have to turn any registry switches or do anything magical to get FIPS-140. Good reason to stick to this simple API to get your crypto on Windows.

