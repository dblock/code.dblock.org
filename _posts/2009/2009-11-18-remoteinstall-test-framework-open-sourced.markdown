---
layout: post
title: "RemoteInstall Test Framework Open-Sourced"
redirect_from: "/remoteinstall-test-framework-open-sourced/"
date: 2009-11-18 00:30:00
tags: [codeproject, testing, dotnetinstaller, vmware, msi]
comments: true
dblog_post_id: 62
---

I am pleased to announce the open sourcing of the [RemoteInstall Test Framework](https://github.com/dblock/remoteinstall).

RemoteInstall is a pragmatic approach to testing and has been extremely successful at my [day job](http://www.appsecinc.com/). We went through several test framework iterations and just couldn't get any automation going. We tried expensive systems and open-source stuff. We spent cash. We made automation a priority. It continued being a dead end.

In the meantime we were authoring MSI installers like crazy. We had to deal with a large distributed system that was having a high deployment failure rate, a system made of many components. We had hundreds of upgrade paths and it was clear that we needed to automate it. Seeing company automation efforts deadlocked, I decided that instead of trying yet another expensive test system I'll have an intern write a simple tool that can leverage VMWare Infrastructure. I wanted it to do this:

```
for each virtual machine {
  for each snapshot {
    restore the snapshot
    install the software
    report success or failure
  }
}
```

Simple enough? That's all RemoteInstall was at its inception. You can get this behavior out of the box with a simple config file. Here's what the output looks like in CruiseControl. This tests an application for clean install and upgrade from various known snapshots.

![CruiseControl.jpg](https://raw.githubusercontent.com/dblock/remoteinstall/master/Screenshots/CruiseControl.jpg)

The results were superb. We have virtually zero deployment failure in production for thousands of custommers. Then, eventually we got pretty good at this adding lots of useful features. If you have more than one VM you can do this in parallel. RI integrates with build automation. It can pickup your latest installers from network shares. Etc. Next, we thought: why not run some tests after each successful installation? So we added tasks and some simple integration. So you can execute JUnit or NUnit tests on the remote machine post-installation.

![NUnit.jpg](https://raw.githubusercontent.com/dblock/remoteinstall/master/Screenshots/NUnit.jpg)

This made it into a full blown test framework. We now author tests in C# and Java and remote them via RI to run against multiple configurations.

[Download RI Here](https://github.com/dblock/remoteinstall)

I want to thank [Application Security Inc.](http://www.appsecinc.com) for helping me in making this happen and all the anonymous developers who have contributed code to RI here on Madison Ave.

