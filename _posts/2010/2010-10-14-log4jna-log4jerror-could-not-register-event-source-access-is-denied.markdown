---
layout: post
title: "log4jna: log4j:ERROR Could not register event source (Access is denied.)"
redirect_from: "/log4jna-log4jerror-could-not-register-event-source-access-is-denied/"
date: 2010-10-14 12:06:29
tags: [log4j, jna, security, win32]
comments: true
---
This is a pretty common problem with NTEventLogAppender (both log4j and [log4jna](https://github.com/dblock/log4jna/) versions) on Windows Vista, 7 or 2008.

#### Repro

I’ll use the demo project in log4jna to demonstrate what’s going on.

First, configure log4j.properties with an NTEventLogAppender and a new event source name ("demo" in the example below).

```config
log4j.rootCategory=INFO, E

org.apache.log4jna.nt.demo=DEBUG

log4j.appender.E = org.apache.log4jna.nt.Win32EventLogAppender
log4j.appender.E.layout = org.apache.log4j.PatternLayout
log4j.appender.E.source = demo
log4j.appender.E.layout.ConversionPattern = %d{yyyy-MM-dd HH:mm:ss} %c{1} [%p] %m%n
```

Run the demo as a non-admin user (if you have log4jna source you can do _ant run_). It fails with the following error.

```log
[java] log4j:ERROR Could not register event source.
[java] com.sun.jna.platform.win32.Win32Exception: Access is denied.
[java]     at com.sun.jna.platform.win32.Advapi32Util.registryCreateKey(Advapi32Util.java:712)
[java]     at org.apache.log4jna.nt.Win32EventLogAppender.registerEventSource(Unknown Source)
[java]     at org.apache.log4jna.nt.Win32EventLogAppender.activateOptions(Unknown Source)
[java]     at org.apache.log4j.config.PropertySetter.activate(PropertySetter.java:307)
[java]     at org.apache.log4j.config.PropertySetter.setProperties(PropertySetter.java:172)
[java]     at org.apache.log4j.config.PropertySetter.setProperties(PropertySetter.java:104)
[java]     at org.apache.log4j.PropertyConfigurator.parseAppender(PropertyConfigurator.java:809)
[java]     at org.apache.log4j.PropertyConfigurator.parseCategory(PropertyConfigurator.java:735)
[java]     at org.apache.log4j.PropertyConfigurator.configureRootCategory(PropertyConfigurator.java:615)
[java]     at org.apache.log4j.PropertyConfigurator.doConfigure(PropertyConfigurator.java:502)
[java]     at org.apache.log4j.PropertyConfigurator.doConfigure(PropertyConfigurator.java:547)
[java]     at org.apache.log4j.helpers.OptionConverter.selectAndConfigure(OptionConverter.java:483)
[java]     at org.apache.log4j.LogManager.<clinit>(LogManager.java:127)
[java]     at org.apache.log4jna.nt.demo.Demo.main(Unknown Source)
```

#### Fix

Windows Event Log requires a registered event source to fire events to. The NTEventLogAppender attempts to create one automatically, but doesn’t have enough registry permissions to do so. In order to run software as a non-admin, we must create the registry key at software installation time when we do have those registry permissions. In our case, we need to create a _demo_ key under _HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Application_.

![]({{ site.url }}/images/posts/2010/2010-10-14-log4jna-log4jerror-could-not-register-event-source-access-is-denied/image_4.jpg)

This is sufficient for the application to run and to fire an event without errors. I’ll explain what’s going with the event text in my next post.

![]({{ site.url }}/images/posts/2010/2010-10-14-log4jna-log4jerror-could-not-register-event-source-access-is-denied/image_17.jpg)
