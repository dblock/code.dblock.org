---
layout: post
title: "Getting the display name of a VMWare snapshot"
redirect_from: "/getting-the-display-name-of-a-vmware-snapshot/"
date: 2008-12-26 14:00:00
tags: [vmware]
comments: true
---
Looking at the source code of [another VMWare C# wrapper on CodePlex](http://www.codeplex.com/VixCOMWrapper), turns out that most VMWare interfaces represent VMWare handles. This is a good decision from the design point of view, but the implementation in VMWare VIX API is wrong: it should be returning objects that implement multiple interfaces, instead it returns one of the interfaces that you can happily cast to another.

This does answer the question of how to get the display name of a VMWare snapshot.

Let's add a wrapper for a VIX handle.

```cs
/// <summary>
/// A wrapper for a VIX handle. Most VIX objects returned also implement IVixHandle.
/// </summary>
public class VMWareVixHandle
{
  IVixHandle _handle = null;

  public VMWareVixHandle(IVixHandle handle)
  {
    _handle = handle;
  }

  /// <summary>
  /// Get an array of properties.
  /// </summary>
  /// <param name="properties">properties to fetch</param>
  /// <returns>an array of property values</returns>
  public object[] GetProperties(object[] properties)
  {
    object result = null;
    VMWareInterop.Check(_handle.GetProperties(properties, ref result));
    return (object[]) result;
  }
}
```

Then the snapshot's name is a cast to a IVixHandle which implements GetProperties.

```cs
public string DisplayName
{
  get
  {
    object[] properties = { Constants.VIX_PROPERTY_SNAPSHOT_DISPLAYNAME };
    return (string)new VMWareVixHandle((IVixHandle) _snapshot).GetProperties(properties)[0];
  }
}
```

