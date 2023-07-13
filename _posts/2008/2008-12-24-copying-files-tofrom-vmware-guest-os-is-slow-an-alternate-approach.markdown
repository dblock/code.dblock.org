---
layout: post
title: "Copying files to/from VMWare guest OS is slow: an alternate approach"
redirect_from: "/copying-files-tofrom-vmware-guest-os-is-slow-an-alternate-approach/"
date: 2008-12-24 05:45:00
tags: [vmware]
comments: true
dblog_post_id: 26
---
I really like VMWare VIX API's _CopyFileFromGuestToHost_ and _CopyFileFromHostToGuest_. These automatically copy a single file or an entire directory tree. Easy. Unfortunately I am copying large (150-300 Mb) files to/from a VMWare guest OS and it's taking an hour to copy a hundred megs. I bet VMWare API was developed by Russian developers, so it's probably sending UTF-8 encoded bytes in Russian via SOAP. You might remember that I am writing a tool that lets one test a cross-product of installers and virtual machine snapshots: three MSIs multipled by twenty snapshots equals days of file copying! It's not going to work.

I posted a [question about this in VMWare Communities](https://communities.vmware.com/thread/184489?tstart=0) and got a satisfactory response: _I don't think there is a workaround. We are aware of the issue (we run in to it internally) and hope to fix it in a future release._

In the meantime, I need a short term solution.

I decided to try and map the remote drive and use a simple _File.Copy_. The first challenge is to find out the remote server's IP address. VMWare exposes guest OS variables, including the ip, so I've extended VMWareTasks to support those.

{% highlight c# %}
/// <summary>
/// Environment, guest and runtime variables
/// </summary>
/// <param name="name">name of the variable</param>
[IndexerName("Variables")]
public string this[string name]
{
  get
  {
    VMWareJob job = new VMWareJob(_vm.ReadVariable(_variableType, name, 0, null));
    object[] properties = { Constants.VIX_PROPERTY_JOB_RESULT_VM_VARIABLE_STRING };
    return job.Wait<string>(properties, 0, VMWareInterop.Timeouts.ReadVariableTimeout);
  }

  set
  {
    VMWareJob job = new VMWareJob(_vm.WriteVariable(_variableType, name, value, 0, null));
    job.Wait(VMWareInterop.Timeouts.WriteVariableTimeout);
  }
}
{% endhighlight %}

Here's the IP address of a powered-on VM.

{% highlight c# %}
virtualMachine.GuestVariables["ip"];
{% endhighlight %}

We can make up a network path out of a local one.

{% highlight c# %}
public string PathToNetworkPath(string ip, string value)
{
  return string.Format(@"\\{0}\{1}", ip, value.Replace(":", "$"));
}
{% endhighlight %}

Mapping a network drive is implemented in mpr.dll with [WNetAddConnection2](https://learn.microsoft.com/en-us/windows/win32/api/winnetwk/nf-winnetwk-wnetaddconnection2a). A wrapper class will do the job.

{% highlight c# %}
public class NetworkDrive
{
  [DllImport("mpr.dll")]
  public static extern int WNetAddConnection2(ref NETRESOURCE lpNetResource, string lpPassword, string UserName, int dwFlags);

  [StructLayout(LayoutKind.Sequential)]
  public struct NETRESOURCE
  {
    public int dwScope;
    public int dwType;
    public int dwDisplayType;
    public int dwUsage;
    public string lpLocalName;
    public string lpRemoteName;
    public string lpComment;
    public string lpProvider;
  }

  private const int RESOURCETYPE_DISK = 0x1;

  private string _localName;
  private string _remoteName;

  public NetworkDrive(string remoteName)
  {
    _remoteName = remoteName;
  }

  public NetworkDrive(string remoteName, string localName)
  {
    _remoteName = remoteName;
    _localName = localName;
  }

  public string LocalName
  {
    get { return _localName; }
    set { _localName = value; }
  }

  public string RemoteName
  {
    get { return _remoteName; }
    set { _remoteName = value; }
  }

  public void MapNetworkDrive(string username, string password)
  {
    NETRESOURCE netResource = new NETRESOURCE();
    netResource.dwScope = 2;
    netResource.dwType = RESOURCETYPE_DISK;
    netResource.dwDisplayType = 3;
    netResource.dwUsage = 1;
    netResource.lpRemoteName = _remoteName;
    netResource.lpLocalName = _localName;
    int rc = WNetAddConnection2(ref netResource, password, username, 0);
    if (rc != 0)
    {
      throw new Win32Exception(rc);
    }
  }
}
{% endhighlight %}

Let's put it all together.

{% highlight c# %}
public void CopyFileFromGuestToHost(string guestPath, string hostPath)
{
  string guestNetworkPath = PathToNetworkPath(_ip, guestPath);
  NetworkDrive guestNetworkDrive = new NetworkDrive(Path.GetPathRoot(guestNetworkPath));
  guestNetworkDrive.MapNetworkDrive(_username, _password);
  File.Copy(guestNetworkPath, hostPath, true);
}
{% endhighlight %}

The last thing that remains to be done to make the new copy compatible is to also copy directories and subdirectories. That's left as an exercise to the reader.

