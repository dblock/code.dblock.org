---
layout: post
title: "ACL-based authorization model with NHibernate"
redirect_from: "/acl-based-authorization-model-with-nhibernate/"
date: 2009-02-26 01:45:00
tags: [hibernate]
comments: true
dblog_post_id: 39
---
I've posted a long overdue article describing an ACL-based authorization model with NHibernate 2.0. This is the next level of evolution from ACL-based implementations that I've used on FoodCandy or in the software that runs this blog.

> _This article introduces a practical and secure model for data access with NHibernate. Specifically, we will produce a discretionary access model intercepted by an NHibernate 2.0 event system. We will examine both usage of interceptors and events. While rather straightforward, this is a very powerful model that provides a robust and secure Data Access Layer (DAL) and a per-class/instance approach with a minimal amount of code._

[**https://www.codeproject.com/KB/web-security/objectlevelsecurity.aspx**](https://www.codeproject.com/KB/web-security/objectlevelsecurity.aspx)

![](https://www.codeproject.com/KB/web-security/objectlevelsecurity/domainmodel.jpg)

