---
layout: post
title: "Introducing Oshi: Operating System and Hardware Information (Java)"
redirect_from: "/introducing-oshi-operating-system-and-hardware-information-java"
date: 2010-06-23 01:10:34
tags: [oshi, jna, java, hardware, win32]
comments: true
---

![oshi]({{ site.url }}/images/posts/2010/2010-06-23-introducing-oshi-operating-system-and-hardware-information-java/oshi%5b8%5d.jpg)

Take Hyperic SIGAR, a very popular Java API that lets you collect system information. It has two major drawbacks.

1. It uses a native library (eg. _hyperic-sigar-x86.dll)_, which you have to install separately from your application’s jar/war.
2. It’s GPL v2. My legal department immediate flagged that as a no-go since we’re a commercial product.

Sounds like we could live with the first problem, but we can’t live with the second. Licensing is a pest.

While we’re at it, we should be able to leverage [JNA](https://github.com/twall/jna/) and fix the first problem too. In the end we could end up with a very nice library that lots of people use.

#### The Oshi Project

Introducing the [Oshi Project](https://github.com/dblock/oshi). I’ve put a day of work into it and a bit of design thought in terms of operating system and hardware interfaces. I’ve implemented those for Windows, so it can generate this kind of output.

```
Microsoft Windows 7
2 CPU(s):
Intel(R) Core(TM)2 Duo CPU T7300  @ 2.00GHz
Intel(R) Core(TM)2 Duo CPU T7300  @ 2.00GHz
Memory: 532.1 MB/2.0 GB
```

Here’s the code for the above.

```java
SystemInfo si = new SystemInfo();
OperatingSystem os = si.getOperatingSystem();
System.out.println(os);
HardwareAbstractionLayer hal = si.getHardware();
System.out.println(hal.getProcessors().length + " CPU(s):");
for(Processor cpu : hal.getProcessors()) {
    System.out.println(" " + cpu);
}
System.out.println("Memory: " +
        FormatUtil.formatBytes(hal.getMemory().getAvailable()) + "/" +
        FormatUtil.formatBytes(hal.getMemory().getTotal()));
```

#### What’s Next?

[Oshi](https://github.com/dblock/oshi) needs your help to implement \*nix ports and create interfaces for other types of software and hardware information, such as disks, processes, printers, etc. Some of the functionality may be generic and should be pushed into JNA.
