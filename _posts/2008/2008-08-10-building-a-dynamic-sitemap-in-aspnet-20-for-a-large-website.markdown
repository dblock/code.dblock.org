---
layout: post
title: "Building a dynamic SiteMap in ASP.NET 2.0 for a large website"
redirect_from: "/building-a-dynamic-sitemap-in-aspnet-20-for-a-large-website/"
date: 2008-08-10 18:10:23
tags: [asp.net]
comments: true
---
![dynamic sitemap rendered](http://www.codeproject.com/KB/aspnet/dynamicsitemap/dynamicsitemap.jpg)

Sitemaps and breadcrumbs (SiteMapPath) are useful and easy to implement for a static site with a sitemap file. For dynamic sites, something as simple seems to get much more complicated.

When I started reading about sitemaps for dynamic sites, I found a common approach: generate a static site map for the whole website from, for example, a data source. Re-generate periodically. Use the [XmlSiteMapProvider](http://msdn2.microsoft.com/en-us/library/system.web.xmlsitemapprovider.aspx). Cache. The technique is described in [this CodeProject article](http://www.codeproject.com/useritems/DynamicSitemapASPNET2.asp).

This doesn't work for my site at all. I need to provide a site map for a large number of pages, potentially hundreds of thousands. The site is deep and dynamic, and only a small unpredictable set of pages is accessed frequently. There're also two hundred different object types in the back-end database which is not coupled with the user-interface at all. Querying everything once is not trivial. Generating an accurate site map for the whole site would take too long, would be a lot of code, and would definitely take too much memory to cache.

[My CodeProject Article](http://www.codeproject.com/KB/aspnet/dynamicsitemap.aspx) demonstrates a simpler and practical solution chosen.

