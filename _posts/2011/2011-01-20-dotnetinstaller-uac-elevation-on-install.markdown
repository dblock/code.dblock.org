---
layout: post
title: "dotNetInstaller: UAC Elevation on Install"
redirect_from: "/dotnetinstaller-uac-elevation-on-install/"
date: 2011-01-20 15:36:42
tags: [open source, security, ui, dotnetinstaller, win32]
comments: true
dblog_post_id: 158
---
Following a much pleasing trend of developers contributing major functionality to my open-source projects, [@nsleightholm](http://www.codeplex.com/site/users/view/nsleightholm) (Neil Sleightholm who works for a company called [X2Systems Ltd](http://www.x2systems.com).) has contributed support for UAC elevation on install to [dotNetInstaller 2.0](https://github.com/dblock/dotnetinstaller).

Until now you had to mark your Setup.exe to elevate in the manifest and the user was prompted to elevate upfront. This is not the default behavior of MSI installers and is not an ideal user experience. It also creates a major problem for installers that need to reboot in the middle, as Windows Defender will block any process that tries to elevate while auto-starting. Both of these issues are resolved.

#### How does it look?

Check out the GUI from the sample packaged setup.

![]({{ site.url }}/images/posts/2011/2011-01-20-dotnetinstaller-uac-elevation-on-install/image_11.jpg)

Note the elevation icon next to the install button!

#### How does it work?

dotNetInstaller will check whether you’re running a compatible operating system. If you’re on Windows XP, it will require the user to have administrative rights and fail with a message if those aren’t present. On Vista and Windows 7, it will re-launch an elevated version of itself. Although many samples are available on the internet, the code was quite involved – thanks Neil!

#### How do I enable UAC elevation?

Set _administrator_required_ to _true _in your installer configuration (note that this is now the default). You should also specify a proper _administrator_required_message_.

#### Do I need to change the embedded manifest?

We’ve changed the default manifest to include all of the following, but if you’re embedding your own manifest, you must declare these.

- The executable must not elevate by default, hence it should be marked to execute _asInvoker_.
- It must be declared compatible with Windows Vista and Windows 7 to prevent the Windows compatibility assistant from complaining.
- The UAC icon comes from Windows visual styles, hence it must have a dependency on Windows common-controls.

Here’s the complete manifest from the packaged setup sample.

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
  <assemblyIdentity version="1.0.0.0" processorArchitecture="X86" name="Setup.exe" type="win32" />
  <description>Sample Packaged Setup</description>
  <trustInfo xmlns="urn:schemas-microsoft-com:asm.v3">
    <security>
      <requestedPrivileges>
        <requestedExecutionLevel level="asInvoker" uiAccess="false"/>
      </requestedPrivileges>
    </security>
  </trustInfo>
  <compatibility xmlns="urn:schemas-microsoft-com:compatibility.v1">
    <application>
      <!-- Windows Vista -->
      <supportedOS Id="{e2011457-1546-43c5-a5fe-008deee3d3f0}"/>
      <!-- Windows 7 -->
      <supportedOS Id="{35138b9a-5d96-4fbd-8e2d-a2440225f93a}"/>
    </application>
  </compatibility>
  <dependency>
    <dependentAssembly>
      <assemblyIdentity type="win32" name="Microsoft.Windows.Common-Controls" version="6.0.0.0"
       processorArchitecture="\*" publicKeyToken="6595b64144ccf1df" language="\*" />
    </dependentAssembly>
  </dependency>
</assembly>
```

#### Which build?

This feature is available since this week’s build 2.0.386.0. There’re still some rough edges being polished.

#### What about htmlInstaller?

The parity feature request for htmlInstaller is still open. Please contribute.
