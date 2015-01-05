---
layout: post
title: "JNA: accessing Windows registry from Java"
redirect_from: "/jna-accessing-windows-registry-from-java"
date: 2010-03-23 18:29:30
tags: [jna, java, win32]
comments: true
---
Some things should just be easy. I’ve committed a bunch of registry utility functions into JNA’s platform.jar, all with unit tests. You don’t have to break your head with Win32 API, just use `com.sun.jna.platform.win32.Advapi32Util` and the following functions.

- `registryCreateKey`
- `registryGetIntValue`
- `registryGetStringValue`
- `registryValueExists`
- `registryKeyExists`
- `registrySetIntValue`
- `registrySetStringValue`
- `registryDeleteValue`
- `registryDeleteKey`

Try these:

```java
Advapi32Util.registryCreateKey(WinReg.HKEY_CURRENT_USER, "Software", "JNA");
Advapi32Util.registrySetIntValue(WinReg.HKEY_CURRENT_USER, "Software\\JNA", "IntValue", 42);
System.out.println(Advapi32Util.registryGetIntValue(WinReg.HKEY_CURRENT_USER, "Software\\JNA", "IntValue"));
Advapi32Util.registryDeleteKey(WinReg.HKEY_CURRENT_USER, "Software", "JNA");
```

I’ll add `REG_MULTI_SZ` support and registry key and value enumerators next.

If you were using JnaContrib Registry classes for these purposes before, you should switch. The code in the latter doesn’t do a very good job at consistently throwing exceptions when a key cannot be read or found.
