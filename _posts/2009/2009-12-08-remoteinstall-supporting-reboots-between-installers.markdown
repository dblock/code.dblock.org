---
layout: post
title: "RemoteInstall: supporting reboots between installers"
redirect_from: "/remoteinstall-supporting-reboots-between-installers/"
date: 2009-12-08 16:23:18
tags: [remoteinstall, testing, dotnetinstaller, vmware, msi]
comments: true
dblog_post_id: 71
---
We’ve recently upgraded the Visual Studio 2005 SP1 C++ Redistributable to a [newer version with the ATL security update](http://www.microsoft.com/downloads/details.aspx?familyid=766A6AF7-EC73-40FF-B072-9112BAB119C2&displaylang=en). We quickly found that the installer requires a reboot in about half of our upgrade scenarios. This is understandable because our own application is running and using the CRT and while the ATL security update looks like a new side-by-side installation magic happens that involves the previous version.

Interestingly in a few spot tests the installers finished successfully without the reboot, even after prompting for one. Since a CRT is available already, almost all DLLs can load and run just fine with the current version – some SxS manifest points the CRT to the latest version installed. We decided to be clever and suppressed the reboot by telling [dotNetInstaller](https://github.com/dblock/dotnetinstaller/) to ignore the 3010 return code and by installing the CRT redistributable with `/q:a /c:"vcredi~3.exe /q:a /c:"msiexec /i vcredist.msi /qb!"` (if you just run `vcredist_x86.exe /Q` you get a reboot prompt). Once checked into source control, built and in automation, 4 out of 27 daily install/upgrade scenarios failed. The culprit was some C++ DLL that failed to register.

This was all a bad idea: we’re constantly making extra effort to avoid reboots for our customers, but we forget that reboots exist for a reason and that people upgrade a production system every six months with careful planning for downtime and even rollback. A reboot is not that bad. Everyone should stop suppressing reboots, an obscure DLL registration failure for 4 out of 27 customers is much worse than a required reboot for half of them.

Once reboot was back in-place, our [RemoteInstall](https://github.com/dblock/remoteinstall) automation broke. We run the entire bootstrapper with /q, which forces a silent install that reboots in the middle. RemoteInstall doesn’t know how to handle this and thinks that the server vanished in the middle of installation. It fails the test.

Nothing that 10 minutes of coding can’t solve.

Rather than trying to make RemoteInstall understand that the installer forced a server reboot, we want it to take control of the reboot process. The first step is to split the bootstrapper installation into the Visual Studio CRT installation and our application, "pre-install" the CRT. If the CRT requires a reboot (return code 3010), RemoteInstall will shutdown the guest operating system and power it back up (reboot is not directly supported in VMWare VIX). It can then continue with the next installer. I implemented this behavior in [RemoteInstall 1.2 Beta](https://github.com/dblock/remoteinstall), including an additional _rebootIfRequired_ option for those picky developers that don’t believe me when I say you should stop suppressing reboots.

```cs
else if (remoteInstallResult.RebootRequired)
{
    if (installerConfig.RebootIfRequired)
    {
        ConsoleOutput.WriteLine("Shutting down '{0}:{1}'", _vmPowerDriver.VmConfig.Name,
            _vmPowerDriver.SnapshotConfig.Name);
        _vmPowerDriver.ShutdownGuest();
        ConsoleOutput.WriteLine("Powering on '{0}:{1}'", _vmPowerDriver.VmConfig.Name,
            _vmPowerDriver.SnapshotConfig.Name);
        _vmPowerDriver.PowerOn();
    }
    else
    {
        ConsoleOutput.WriteLine("Skipping reboot of '{0}:{1}'", _vmPowerDriver.VmConfig.Name,
            _vmPowerDriver.SnapshotConfig.Name);
    }
}
```

This is what the new configuration looks like for executable setups. The list of exit codes says to reboot on 3010, succeed on 0 and fail otherwise. MSI setups do this automatically since 3010 is a documented MSI return code that signals reboot.

```xml
<installers destpath="C:" sequence="lifo">
  <installer file="vcredist_x86.exe" name="Visual Studio CRT" type="exe" uninstall="false" installArgs="/q:a /c:"vcredi~3.exe /q:a /c:""msiexec /i vcredist.msi /qb!"""">
    <exitcodes>
      <exitcode value="3010" result="reboot" />
      <exitcode value="0" result="success" />
      <exitcode result="failure" />
    </exitcodes>
  </installer>
  <installer file="Setup.exe" name="Application Installer" type="exe" uninstall="false" installArgs="/q" />
</installers>
```

This is what the output from a run in CruiseControl looks like. You can see the messages about a required reboot.

![]({{ site.url }}/images/posts/2009/2009-12-08-remoteinstall-supporting-reboots-between-installers/image_12.jpg)

