---
layout: post
title: "HowTo: remote control, copy and run programs on a VMware Workstation or VI server using VIX APIs"
redirect_from: "/howto-remote-control-copy-and-run-programs-on-a-vmware-workstation-or-vi-server-using-vix-apis"
date: 2008-12-10 20:15:00
tags: [vmware]
comments: true
---
I've been playing with [VMware](http://www.vmware.com/) lately, both Workstation and VMware Infrastructure (VI). The company has really stepped up with the new SDKs and the level of programmable interfaces, making some excellent implementation decisions that enable us to drive virtual machines for primarily unit-testing purposes. The doc is a little light today, so this should help.

#### What do we use this for?

We (at my [day job](http://www.appsecinc.com/aboutus/index.shtml)) developed a tool (in C#) that runs MSI installers to make sure the product installs on various knownly good or bad environments, sort of unit testing installers. We also have an ESX environment that we share.

#### VMWare Programming APIs

There're two types of APIs.

- **VMWare Virtual Infrastructure SDK** : a set of tools and APIs to manage a VMWare Infrastructure environment. A toolkit has also been released that contains managed wrappers on top of the SOAP interface provided by a VMWare deployment. It's focused on VMWare ESX or VirtualCenter management and is beyond the scope of this post.

- **VMWare VIX API**. The VIX API allows you to write programs and scripts that automate virtual machine operations, as well as the guests within virtual machines. It runs on both Windows and Linux and supports management of VMware Server, Workstation, and Virtual Infrastructure (both ESX and vCenter). Bindings are provided for C, Perl, and COM (Visual Basic, VBscript, C#). In this post I'll focus on the C# implementation.

#### What do you need?

- Either VMWare [Workstation 6.5](http://www.vmware.com/download/ws/), a VI environment (I use ESX), or both.
- VMWare ViX. This is the SDK, obtained from  [<u>http://www.vmware.com/download/sdk/vmauto.html</u>](http://www.vmware.com/download/sdk/vmauto.html). The new 1.6.2 version is required for VI support.

#### Connecting to a VMWare Workstation or ESX Server

Connecting to a local VMWare Workstation or an ESX server is virtually identical. The ESX server requires an URL to the SOAP SDK (eg. [https://esxserver/sdk](https://esxserver/sdk)) and a username and password.

```charp
private void ConnectToVMWareWorkstation()
{
  Connect(Constants.VIX_SERVICEPROVIDER_VMWARE_WORKSTATION, string.Empty, 0, string.Empty, string.Empty);
}

private void ConnectToVMWareVIServer(string hostName, int hostPort, string username, string password)
{
  Connect(Constants.VIX_SERVICEPROVIDER_VMWARE_VI_SERVER,  hostName, hostPort, username, password);
}

private void Connect(int hostType, string hostName, int hostPort, string username, string password)
{
  // Connect to a VMware Workstation
  IJob vmJob = VmwareVixInterop.vixLib.Connect(
  Constants.VIX_API_VERSION, hostType, hostName, hostPort, username, password, 0, null, null);
  // You need to get the IHost object that represents the host where your VM is located.
  // Since COM allocates the pointer you need to use this funky mechanism to extract the IHosts array.
  object[] VIX_PROPERTY_JOB_RESULT_HANDLE =  new object[1];
  VIX_PROPERTY_JOB_RESULT_HANDLE[0] = Constants.VIX_PROPERTY_JOB_RESULT_HANDLE;
  // Wait for the operation to complete
  object hosts = VmwareVixInterop.Wait(vmJob, VIX_PROPERTY_JOB_RESULT_HANDLE);
  // Cast and retrieve the IHost object.
  object[] hostArray = hosts as object[];
  _host = (IHost) hostArray[0];
}
```

#### Locating a Virtual Machine

A virtual machine on a VMWare Workstation is a file with a standard path (eg. _C:\Virtual Machines\myvirtualmachine.vmx_). Unsurprisingly it is the same thing on an ESX server, but with a relative storage path. The latter can be found in the VMWare Infrastructure Client: right click on a virtual machine, choose _Edit Settings_, click the _Options_ tab and note the _Virtual Machine Configuration File_ (eg. _[storage] virtualmachine/virtualmachine.vmx_).

```cs
public void OpenFile(string fileName)
{
  // Open the VM from the path specified
  IJob vmJob = _host.OpenVM(fileName, null);
  object[] resultHandles = new object[1];
  resultHandles[0] = Constants.VIX_PROPERTY_JOB_RESULT_HANDLE;
  // Wait for the operation to complete
  object vms = VmwareVixInterop.Wait(vmJob, resultHandles);
  // Get the VM object returned
  Object[] vmArray = vms as Object[];
  _vm = (IVM) vmArray[0];
}
```

#### Power-on, power-off, copy and execute

These are straightforward operations supported by the SDK via the IVM interface returned set by the above-mentioned OpenFile method. Here're some examples.

```cs
IJob PowerOn(int powerOnOptions, IVixHandle propertyList, ICallback jobDoneCallback);

IJob RevertToSnapshot(ISnapshot snapshot, int options, IVixHandle propertyList, ICallback jobDoneCallback);

IJob CopyFileFromHostToGuest(string hostPathName, string guestPathName, int options, IVixHandle propertyList, ICallback jobDoneCallback);
```

It is now possible to execute commands synchronously and asynchronously, without having to involve WMI or another similar method.

```cs
public int Execute(string path, string parameters)
{
  IJob vmJob = _vm.RunProgramInGuest(path, parameters, VixCOM.Constants.VIX_RUNPROGRAM_ACTIVATE_WINDOW, null, null);
  object[] propertyIDs = new Object[] { Constants.VIX_PROPERTY_JOB_RESULT_GUEST_PROGRAM_EXIT_CODE };
  object results = VmwareVixInterop.Wait(vmJob, propertyIDs);
  return Convert.ToInt32(((object[])results)[0]);
}
```

I think the whole job-based API could use a nice .NET wrapper :)

#### Update (2015)

Check out [VMWareTasks](https://github.com/dblock/vmwaretasks).



