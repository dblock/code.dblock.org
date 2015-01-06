---
layout: post
title: "VMWareTasks: reading RunProgramInGuest command output"
redirect_from: "/vmwaretasks-reading-runprograminguest-command-output/"
date: 2010-01-30 16:24:10
tags: [vmware]
comments: true
---
This is a pretty common question on the VixCOM forum: _How do I run a command in the virtual machine and collect its output?_

VixCOM doesn’t have any support for this, so is there something we can do about it? I want to have a RunCommandInGuest to execute shell and other commands that returns StdOut and StdErr. So this is what I want to write:

```cs
Shell.ShellOutput output = guestShell.RunCommandInGuest("dir");
```

I figured that the easiest way would be to pipe output to a file and collect that file. Because the commands can also contain piping, we have to create a temporary .bat that contains the command. I did it for Windows, so you get `Vestris.VMWareLib.Tools.Windows.Shell.RunCommandInGuest` in [VMWareTasks](https://github.com/dblock/vmwaretasks).

```cs
/// <summary>
/// Use RunProgramInGuest to execute cmd.exe /C "guestCommandLine" > file and parse the result.
/// </summary>
/// <param name="guestCommandLine">Guest command line, argument passed to cmd.exe.</param>
/// <returns>Standard output.</returns>
public ShellOutput RunCommandInGuest(string guestCommandLine)
{
    string guestStdOutFilename = _vm.CreateTempFileInGuest();
    string guestStdErrFilename = _vm.CreateTempFileInGuest();
    string guestCommandBatch = _vm.CreateTempFileInGuest() + ".bat";
    string hostCommandBatch = Path.GetTempFileName();
    StringBuilder hostCommand = new StringBuilder();
    hostCommand.AppendLine("@echo off");
    hostCommand.AppendLine(guestCommandLine);
    File.WriteAllText(hostCommandBatch, hostCommand.ToString());
    try
    {
        _vm.CopyFileFromHostToGuest(hostCommandBatch, guestCommandBatch);
        string cmdArgs = string.Format("> \"{0}\" 2>\"{1}\"", guestStdOutFilename, guestStdErrFilename);
        _vm.RunProgramInGuest(guestCommandBatch, cmdArgs);
        ShellOutput output = new ShellOutput();
        output.StdOut = ReadFile(guestStdOutFilename);
        output.StdErr = ReadFile(guestStdErrFilename);
        return output;
    }
    finally
    {
        File.Delete(hostCommandBatch);
        _vm.DeleteFileFromGuest(guestCommandBatch);
        _vm.DeleteFileFromGuest(guestStdOutFilename);
        _vm.DeleteFileFromGuest(guestStdErrFilename);
    }
}
```

Problem solved.

