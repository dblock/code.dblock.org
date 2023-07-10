---
layout: post
title: "Cabinet.dll: what's a proper way to handle fdintCABINET_INFO in a split cab"
redirect_from: "/cabinetdll-whats-a-proper-way-to-handle-fdintcabinetinfo-in-a-split-cab/"
date: 2010-02-11 14:57:00
tags: [win32]
comments: true
dblog_post_id: 82
---
I’ve been tracking a bug in [CabLib](http://www.codeproject.com/KB/files/CABCompressExtract.aspx), used in [dotNetInstaller](https://github.com/dblock/dotnetinstaller) recently. CabLib is a complete C# and C++ wrapper for Cabinet.dll and its goal is to make it easier to CAB files. Anyone who used Cabinet.dll’s interface directly will quickly discover that it follows the usual Microsoft Win32 mantra: if a developer can do something himself with the existing API, don’t include that functionality in the platform SDK. This produces a well thought-through Cabinet SDK, provided that your user has a major in computer science and a PhD in cognitive psychology.

One of the more interesting aspects of CABs is so-called split CABs. This is just a chain of CAB files, useful if you need to put CABs on a set of floppy drives or embed as a Win32 resource, as dotNetInstaller does (resource size is limited). The Cabinet.dll interface is based on callbacks: you call [FDICopy](https://learn.microsoft.com/en-us/windows/win32/api/fdi/nf-fdi-fdicopy) and it calls you back (`fdintCABINET_INFO`) whenever it encounters a file that is split over several CABs, telling you which next CAB to process. Logically, you would want to process that next CAB, except that here you need to wait for FDICopy to return to do it. This means you need to remember what the next CAB name is, so that you can call FDICopy on it. The algorithm around FDICopy looks like this.

{% highlight cpp %}
while (TRUE)
{
    if (! FdiCopy(context, cabFile, cabFolder, 0, FDICallback, 0, pParam))
        break;

    if (! nextCab.Len())
        break;

    cabFile = nextCab;
}
{% endhighlight %}

... and the callback ...

{% highlight cpp %}
INT_PTR FdiCallback(FDINOTIFICATIONTYPE fdint, PFDINOTIFICATION pfdin)
{
    switch (fdint)
    {
        case fdintCABINET_INFO:
        {
            nextCab = pfdin->psz1;
{% endhighlight %}

There’s a bug here, one that was not obvious to track. The symptom is that you’re not getting all the files extracted, some CAB files are missed. The problem is that while you’re processing CAB1, for FILE1 you can get a callback that says to continue in CAB2. Then you can get a callback for FILE2 that says to continue in CAB3. You should be ignoring that second callback because you haven’t processed CAB2 yet.

I initially fixed it with a list, but CabLib author pointed out that this is an overkill. The final code looks like this.

{% highlight cpp %}
while (TRUE)
{
    nextCab.clear();

    if (! FdiCopy(context, cabFile, cabFolder, 0, FDICallback, 0, pParam))
        break;

    if (! nextCab.Len())
        break;

    cabFile = nextCab;
}
{% endhighlight %}

{% highlight cpp %}
INT_PTR FdiCallback(FDINOTIFICATIONTYPE fdint, PFDINOTIFICATION pfdin)
{
    switch (fdint)
    {
        case fdintCABINET_INFO:
        {
            if (nextCab.empty())
                nextCab = pfdin->psz1;
{% endhighlight %}

This was a huge time suck from my development time. If there’s one conclusion you want to take away from this, is that you should never design an interface like the one in Cabinet.dll.
