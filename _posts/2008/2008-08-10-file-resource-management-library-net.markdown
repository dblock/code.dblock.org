---
layout: post
title: "File Resource Management Library (.NET)"
redirect_from: "/file-resource-management-library-net"
date: 2008-08-10 18:00:00
tags: [win32]
comments: true
---
There are several good articles about reading and writing resources from/to a compiled binary. Most focus on retrieving module version information and modifying version information, mostly in C++. Some detail the same operations for cursor or dialog resources. There's, however, no single .NET library to retrieve and save any type of resources, or any library to edit version resources specifically.

This implementation is a framework that enumerates resources and implements both read and write of the file version (`VS_VERSIONINFO`) resources. It can be easily extended to other resource types.

<a href='http://www.codeproject.com/Articles/27373/File-Resource-Management-Library-NET' target='_blank'>CodeProject Article</a>

#### Update (2015)

ResourceLib which started as the above-mentioned article can be found on <a href='https://github.com/dblock/resourcelib' target='_blank'>Github</a>.


