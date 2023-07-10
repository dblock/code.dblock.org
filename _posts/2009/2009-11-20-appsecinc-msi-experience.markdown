---
layout: post
title: "AppSecInc. MSI Experience"
redirect_from: "/appsecinc-msi-experience/"
date: 2009-11-20 18:15:00
tags: [msi]
comments: true
dblog_post_id: 64
---
A couple of years ago [we](https://web.archive.org/web/20131111165225/https://www.appsecinc.com/) used to have a really big problem with Windows installers. We had one guy writing InstallShield installers and a bunch of components thrown at him with the usual "just install these, please". As a result, almost every single deployment ran into some kind of hard-to-diagnose failure, force the entire thing to rollback and require creative solutions to get the customer running. More InstallScript was written at best.

> "What's up with those customers?", - we would say, "Why do they want to install our software?!".

Then the customer would try to upgrade ...

I saw large teams deal with these problems before at Microsoft, quite successfully, so I had my team turn around 180 degrees and set course on changing deployment technology to something enterprise-ready and robust.

- We made every single developer care about installation and everyone learned through brown bags how to write an installer or what Windows installer is about and why it's harder than it seems.
- We changed technology to [Wix](http://wixtoolset.org/) so that we can share the work load across the organization and so that every developer adding a file makes sure to take care of the installer at the same time. We made installer code just like C++, C# or Java code.
- We re-thought individual installable components from scratch and how they assemble into a working product. We wrote brand new merge modules and MSI installers.
- We developed C++ custom actions (DTF didn't exist in the public then to write managed ones) and Wix extensions that not available in wix and that are now open-sourced as [AppSecInc. MSI Extensions](https://github.com/dblock/msiext). We evolved a unit-test system from an MSI shim to using the MSI engine for every single CA to make sure they are robust.
- We re-thought suite deployment and settled on [dotNetInstaller](https://github.com/dblock/dotnetinstaller) bootstrapper to chain the whole thing together, contributing some features as well.
- We invested into test automation with the [RemoteInstall Test Framework](https://github.com/dblock/remoteinstall) to cover the hundreds of install and upgrade scenarios.

Today the problem is gone - we have virtually zero deployment failure - and we're open-sourcing the two key elements above since they are not in the line of our primary business (yes, we're your database security risk and compliance company): [RemoteInstall Test Framework](https://github.com/dblock/remoteinstall) and [AppSecInc. MSI Extensions](https://github.com/dblock/msiext). If you have similar problems with your installers, do what I say. With today's tools open-source it will take you half the time and you'll wonder why you haven't done it earlier.

