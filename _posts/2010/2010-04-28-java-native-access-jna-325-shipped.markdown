---
layout: post
title: "Java Native Access (JNA) 3.2.5 Shipped"
redirect_from: "/java-native-access-jna-325-shipped"
date: 2010-04-28 12:16:40
tags: [jna, java, win32]
comments: true
---
![java-logo_svg-a]({{ site.url }}/images/posts/2010/2010-04-28-java-native-access-jna-325-shipped/java-logo_svg-a%5b6%5d.jpg) 3.2.5 shipped quietly last week.

JNA now includes _platform.jar_ that has cross-platform mappings and mappings for a number of commonly used platform functions, including a large number of Win32 mappings as well as a set of utility classes that simplify native access. The code is tested and the utility interfaces ensure that native memory management is taken care of correctly. I’ve contributed a boatload of code in this area, so when something doesn’t work you can blame me.

Before you map your own functions, check the JavaDoc for an already mapped one.

Platform-specific structures are mapped by header. For example, *ShlObj.h* structures can be found in `com.sun.jna.platform.win32.ShlObj`. Platform functions are mapped by library. For example, *Advapi32.dll* functions can be found in `com.sun.jna.platform.win32.Advapi32`. Simplified interfaces (wrappers) for *Advapi32.dll* functions can be found in `com.sun.jna.platform.win32.Advapi32Util`.

The following large areas have been covered to some extent in native interfaces and utility libraries: Registry, SSPI, Active Directory, DPAPI, Users and Groups and Shell.

There will be more refactoring and coverage in the next release. It also seems to have picked up a little traction on the mailing list as people have been sending patches with more Win32 code. I’ll do my best at committing that, so send more. The goal is to eventually cover all of win32 SDK and put the Java to Win32 interoperability problem to rest.


