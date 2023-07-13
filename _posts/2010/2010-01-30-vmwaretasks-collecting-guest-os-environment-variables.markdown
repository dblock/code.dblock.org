---
layout: post
title: "VMWareTasks: collecting Guest OS environment variables"
redirect_from: "/vmwaretasks-collecting-guest-os-environment-variables/"
date: 2010-01-30 16:34:27
tags: [vmware]
comments: true
dblog_post_id: 79
---
All VMWare VixCOM users eventually go through a moment of being puzzled with the behavior of VixCOM ReadVariable function used with `VIX_GUEST_ENVIRONMENT_VARIABLE` ([read this thread](https://communities.vmware.com/message/1166742)). This is supposed to return values for the guest OS environment variables. You can get the value for `%TMP%`, but not for `%ProgramFiles%`. It’s probably due to the fact that VMWareTools aren’t really creating a user environment after login, but who cares, that renders the function virtually useless.

Can we work around it?

We know how to pipe output, so we can just run `set`, collect and parse the results.

{% highlight c# %}
/// <summary>
/// Returns environment variables parsed from the output of a set command.
/// </summary>
/// <returns>Environment variables.</returns>
public Dictionary<string, string> GetEnvironmentVariables()
{
    Dictionary<string, string> environmentVariables = new Dictionary<string, string>();
    StringReader sr = new StringReader(RunCommandInGuest("set").StdOut);
    string line = null;
    while (! string.IsNullOrEmpty(line = sr.ReadLine()))
    {
        string[] nameValuePair = line.Split("=".ToCharArray(), 2);
        if (nameValuePair.Length != 2)
        {
            throw new Exception(string.Format("Invalid environment string: \"{0}\"", line));
        }

        environmentVariables[nameValuePair[0]] = nameValuePair[1];
    }
    return environmentVariables;
}
{% endhighlight %}

Implemented as `Vestris.VMWareLib.Tools.Windows.Shell.GetEnvironmentVariables()` in [VMWareTasks](https://github.com/dblock/vmwaretasks). It’s a method rather than a property because it actually executes remote commands and environment variables change over time.

{% highlight c# %}
Dictionary<string, string> env = guestShell.GetEnvironmentVariables();
Console.WriteLine(env["ProgramFiles"]);
{% endhighlight %}

Problem solved.

