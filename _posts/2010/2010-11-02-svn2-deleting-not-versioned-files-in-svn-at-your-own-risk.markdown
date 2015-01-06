---
layout: post
title: "Svn2: deleting not-versioned files in SVN (at your own risk)"
redirect_from: "/svn2-deleting-not-versioned-files-in-svn-at-your-own-risk/"
date: 2010-11-02 15:26:34
tags: [subversion]
comments: true
---

I often need to delete not-versioned files in SVN. Although I am supposed to create projects that place all output outside of the SVN client structure, it’s not always practical. So all those pesky generated files are hard to get rid of and pollute my _svn status_. I frequently dump the output of `svn status | findstr "^?_"` into a .cmd file and edit it replacing all ? with `del /Q`.

We can do better. I added a new tool, _svn2_ to the [Svn2Svn project](https://github.com/dblock/svn2svn/). Svn2 has a _sync_ command that sends all non-versioned files to the recycle bin. Use at your own risk – this _will_ delete files that haven’t been svn-added.

#### Implementation

Svn2 uses [SharpSVN](http://sharpsvn.open.collab.net/) which can run a _status_ command. For each file that is not-versioned, we call a _Microsoft.VisualBasic.FileIO_ function to recycle it.

```cs
SvnStatusArgs statusArgs = new SvnStatusArgs();
statusArgs.Depth = SvnDepth.Infinity;
statusArgs.ThrowOnError = true;
client.Status(path, statusArgs, new EventHandler<SvnStatusEventArgs>(
    delegate(object sender, SvnStatusEventArgs e)
{
    switch (e.LocalContentStatus)
    {
        case SvnStatus.NotVersioned:
            Console.WriteLine(" {0} {1}", StatusToChar(e.LocalContentStatus), e.FullPath);
            if (File.Exists(e.FullPath))
            {
                FileSystem.DeleteFile(e.FullPath, UIOption.OnlyErrorDialogs,
                    RecycleOption.SendToRecycleBin);
            }
            else if (Directory.Exists(e.FullPath))
            {
                FileSystem.DeleteDirectory(e.FullPath, UIOption.OnlyErrorDialogs,
                    RecycleOption.SendToRecycleBin);
            }
            break;
    }
}));
```
