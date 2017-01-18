---
layout: post
title: "Visual Studio 2008 Crashes: doesn’t always mean Microsoft sucks"
redirect_from: "/visual-studio-2008-crashes-doesnt-always-mean-microsoft-sucks/"
date: 2010-06-08 13:09:25
tags: [microsoft]
comments: true
dblog_post_id: 109
---

![]({{ site.url }}/images/posts/2010/2010-06-08-visual-studio-2008-crashes-doesnt-always-mean-microsoft-sucks/image_4.jpg)

I often hear from people that Microsoft sucks. When I worked there I found it funny.

I recently had a recurrent crash in Visual Studio 2008. I would switch to the HTML design view (ASP.NET application or simple HTLM page) et voila, crash. Annoying, to say the least. The call stack ended up somewhere in MFC and didn’t look promising. I spent a lot of time being frustrated until this morning, when I decided to actually do something about it.

Microsoft has (had) active forums for all its software. Visual Studio 2008 forum is here: [http://forums.asp.net/1112.aspx](https://web.archive.org/web/20100417224307/http://forums.asp.net/1112.aspx). Turns out that one of the [existing hotfixes](https://web.archive.org/web/20151022210245/http://forums.asp.net/t/1393894.aspx) seemed related to the area where I was seeing the crash. I downloaded and installed it, the problem went away. It also looks like if it didn’t, I could get a very reasonable turn-around on the forum after reporting a crash as someone is being paid to work the forum and collect issues, publish announcements and patches. No annoying forms and no calling on the phone some entry-level support person on the other side of the planet. It’s a developer-to-developer relationship and this is exactly how I like it.
