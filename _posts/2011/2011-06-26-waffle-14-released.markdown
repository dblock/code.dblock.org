---
layout: post
title: "Waffle 1.4 Released"
redirect_from: "/waffle-14-released"
date: 2011-06-26 22:39:58
tags: [open source, waffle, jna, active directory, win32]
comments: true
---
![waffle]({{ site.url }}/images/posts/2011/2011-06-26-waffle-14-released/waffle_4.jpg)

WAFFLE exposes native Windows authentication facilities to C# and Java clients using [JNA](http://github.com/twall/jna). Version 1.4 has shipped Tuesday, June 21, 2010, exactly 11 months after the very popular 1.3 release. WAFFLE has seen massive production adoption over the past year. This version notably introduces support for impersonation, bringing Waffle almost at par with IIS native Windows authentication.

Build is 1.4.8182.0.

#### Features

- #8559: Added impersonation support on the Servlet security filter.
- #9353: Allow customization of GrantedAuthority string in Spring Security filter and authentication manager.
- #8493: Intermediate security contexts of unfinished Negotiate protocol instances expire after ten seconds.
- #9854: Added support for query strings with multiple parameters to MixedAuthenticator.
- #243081: Filter providers and protocols specified in configuration can be separated by any type of space.

There’re Waffle forks for Tomcat 5, 7 and Spring-Security 2.

#### Update (2015)

Please find Waffle [on Github](https://github.com/dblock/waffle).
