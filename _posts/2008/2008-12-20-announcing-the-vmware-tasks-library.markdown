---
layout: post
title: "Announcing the VMWare Tasks Library"
redirect_from: "/announcing-the-vmware-tasks-library/"
date: 2008-12-20 05:30:00
tags: [vmware, dotnet, testing]
dblog_post_id: 25
---
![VMWare](https://web.archive.org/web/20160118032012im_/http://www.codeproject.com/KB/library/VMWareTasks/VMWareLogo.jpg)

Now that I wrote various tools that interop with VMWare, I started working on a VMWare Tasks Library, a managed C# wrapper on top of VMWare COM ViX API that makes it really easy to use.

- [CodeProject Article](https://web.archive.org/web/20081225090238/http://www.codeproject.com:80/KB/library/VMWareTasks.aspx)

I checked in basic functionality of connecting to a virtual machine host, restoring snapshots, powering them up, executing commands, getting lists of files in a directory and subdirectories, etc.

At my day job we developed a tool that uses VMWare to test installers (executes a cross-product of virtual machine snapshots and installers). I plan to take an alternate approach here and write an MSBuild Task to control VMWare, which could enable more flexible automation scenarios.

## Update (2015)

Check out [VMWareTasks on Github](https://github.com/dblock/vmwaretasks).
