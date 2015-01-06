---
layout: post
title: "VMWare ESXi 4.1.0 Automation: Insufficient permissions in host operating system"
redirect_from: "/vmware-esxi-410-automation-insufficient-permissions-in-host-operating-system"
date: 2010-09-24 21:40:19
tags: [remoteinstall, testing, vmware]
comments: true
---
One of our servers was upgraded to VMWare ESXi 4.1.0 and automation that uses [RemoteInstall](https://github.com/dblock/remoteinstall/) (and [VMWareTasks](https://github.com/dblock/vmwaretasks/)) broke. The first part was easy, we needed to download and install the [latest version of VixCOM (1.10)](http://www.vmware.com/support/developer/vix-api/). Then commands would fail with the _"Insufficient permissions in host operating system"_.

The work-around is to grant the VMUser role the "_Acquire guest control ticket"_ permission under _Virtual Machine/Interaction_.

![SnipImage]({{ site.url }}/images/posts/2010/2010-09-24-vmware-esxi-410-automation-insufficient-permissions-in-host-operating-system/snipimage_9.jpg)

