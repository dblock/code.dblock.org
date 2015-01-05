---
layout: post
title: "VMWareTasks 1.3 for VixCOM 1.7.0 (let's reinvent less wheels)"
redirect_from: "/vmwaretasks-13-for-vixcom-170-lets-reinvent-less-wheels"
date: 2009-09-10 13:15:50
tags: [vmware]
comments: true
---
[![VMWareTasks Library](http://i3.codeplex.com/Project/Download/FileDownload.aspx?ProjectName=vmwaretasks&DownloadId=65246 "VMWareTasks Library")](http://vmwaretasks.codeplex.com)

I've released **VMWareTasks 1.3** for VixCOM 1.6.3 and 1.7.0.

[http://vmwaretasks.codeplex.com](http://vmwaretasks.codeplex.com) |

#### Release Notes

Build 1.3.27534.0.

#### Features

- Added a VMWareComLib and VMWareComTools that expose a full scriptable COM interface.
- Added a vestris-vmwarecomlib.jar and vestris-vmwarecomtools.jar that exposes a Com4J JNI wrapper for VMWareComLib and VMWareComTools to Java clients.
- Added support for VixCOM 1.7.0. VMWareTasks works against both 1.6.2 and 1.7.0.

#### Misc Improvements

- All VMWareLib.Tools objects are now IDisposable and explicitly release reference to the virtual machine.
- All assemblies are strongly named and signed.
- The source in the release package can now be built without any changes.

#### Bugs

- VMWareRootSnapshotCollection.CreateSnapshot doesn't pass flags to the COM API.

#### Backwards incompatible interface changes

- VMWareVirtualHost.ConnectToVMWareServer takes an additional username and password. Pass blank values to connect to a local VMWare Server 1.x.

#### Update (2015)

VMWareTasks now lives [on Github](https://github.com/dblock/vmwaretasks).

