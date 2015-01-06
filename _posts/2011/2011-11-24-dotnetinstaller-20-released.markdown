---
layout: post
title: "dotNetInstaller 2.0 Released"
redirect_from: "/dotnetinstaller-20-released/"
date: 2011-11-24 17:57:16
tags: [dotnetinstaller, msi]
comments: true
---
I’ve released DNI 2.0 today. It’s a major release with a new HTML bootstrapper, better elevation support, Windows 8, etc. It has been stable for quite a while now and a few people are using this build in production.

Build 2.0.81.0

#7968: Support elevation as a subsequent command within the bootstrapper. First UI shows un-elevated, but clicking install elevates. (dotNetInstaller only)
#8005: Added a new os_filter type 'greater than' (+) and 'less than' (-).
#6289: Added a new setup bootstrapper, htmlInstaller, driven by an HTML-based UI engine.
#6618: Added #STARTPATH, #STARTEXE and #STARTFILENAME substitution variables.
#6955: Added #OSLANGID substitution variable, operating system language ID.
#6620: Added #OSLOCALE substitution variable, operating system ISO language and region (eg. en-US).
#6956: #LANGID and #LANGUAGE are always set to the value in the currently executing configuration. #LANGUAGE may be empty, while #LANGID will default to the operating system value.
#6604: InstallerEditor no longer needs a configuration file to link a bootstrapper and the configuration does not need to be saved before creating an exe.
#6798: InstallerEditor will display file names when embed files are missing during linking.
#4884: InstallerEditor will notice that a configuration file has changed on disk and offer to reload it.
#6786: Bootstrapper will return a 3010 exit code when a reboot was required.
#6786: Added /noreboot to the bootstrapper to suppress actual reboot when required. Bootstrapper will simply return a 3010 exit code in this case.
#7004: The user-defined browse control will always return paths without the trailing backslash except for drive paths (eg. C:\).
#6730: InstallerEditor displays a * next to field names that are required and displays an error if the user tries to delete the value.
#7148: Added support for Windows 2008 SP2 and Windows 7 SP1.
#7252: Enabled Visual Styles: modified default manifests with a dependency on Microsoft.Windows.Common-Controls 6.0.
#7382: Added disable_wow64_fs_redirection at setup configuration and component level to run native x64 Windows applications (cmd, regedit, etc) from dotNetInstaller.
#7916: Added MUI support with MuiUser (preferred language set for the user) and MuiSystem (preferred language set for the system) options in configuration lcidtype.
#8277: Language selector dialog in dotNetInstaller will automatically select the operating system language if available.
#8256: Added /noRunOnReboot to the bootstrapper to suppress actually writing the RunOnReboot registry key.
#272583: Added support for Windows 8.

#### Update (2015)

Find dotNetInstaller [on Github](https://github.com/dblock/dotnetinstaller).
