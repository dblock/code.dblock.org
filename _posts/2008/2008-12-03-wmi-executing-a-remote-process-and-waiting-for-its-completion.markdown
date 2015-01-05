---
layout: post
title: "WMI: Executing a remote process and waiting for its completion"
redirect_from: "/wmi-executing-a-remote-process-and-waiting-for-its-completion"
date: 2008-12-03 21:45:00
tags: [wmi]
comments: true
---
This drove me crazy for an hour. I needed to execute a remote process via WMI and wait for it to finish. Lots of online resources are suggesting to use `__InstanceCreationEvent`, but that always threw access denied errors back at me. This is a workable straightforward solution, waiting for process to finish by quering the running processes.

```cs
ConnectionOptions connOptions = new ConnectionOptions();
connOptions.Impersonation = ImpersonationLevel.Impersonate;
connOptions.Authentication = AuthenticationLevel.Default;
connOptions.Username = ...;
connOptions.Password = ...;
connOptions.EnablePrivileges = true;
ManagementScope scope = new ManagementScope(@"\\" + machinename + @"\root\cimv2", connOptions);
scope.Connect();

ManagementPath mgmtPath = new ManagementPath("Win32_Process");
ManagementClass mgmtClass = new ManagementClass(_scope, mgmtPath, null);
ManagementBaseObject mgmtBaseObject = mgmtClass.GetMethodParameters("Create");
mgmtBaseObject["CommandLine"] = commandLine;
ManagementBaseObject outputParams = mgmtClass.InvokeMethod("Create", mgmtBaseObject, null);
uint pid = (uint) outputParams["processId"];
Console.Write("Pid: {0} ", pid);
while (Select("Win32_Process", string.Format("processId = {0}", pid)).Count > 0)
{
  Console.Write(".");
  Thread.Sleep(1000);
}
Console.WriteLine(" done.");
```
