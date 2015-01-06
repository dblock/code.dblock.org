---
layout: post
title: "Waffle: Single Sign-On User Impersonation in Tomcat"
redirect_from: "/waffle-single-sign-on-user-impersonation-in-tomcat"
date: 2011-01-18 14:21:02
tags: [tomcat, waffle, jna, security, java, active directory, win32]
comments: true
---
![]({{ site.url }}/images/posts/2011/2011-01-18-waffle-single-sign-on-user-impersonation-in-tomcat/image%5b3%5d.jpg)

A generous contributor (Nicolas Guillaumin, [@nguillaumin](http://www.codeplex.com/site/users/view/nguillaumin) who works for a company called [Funnelback](http://www.funnelback.com/)), has committed the much requested impersonation support to Waffle. This is pretty exciting, since it fills in a bunch of squares in the puzzle that we’re trying to assemble with the [Waffle project](https://github.com/dblock/waffle).

I tried it out with build 1.4.1744.0.

First, there’s a line of code in the _index.jsp_ that displays the current Windows thread identity by calling a Win32 API via JNA.

```jsp
You are logged in as remote user <b><%= request.getRemoteUser() %></b> in session <b><%= session.getId() %></b>.<br>
You are impersonating user <b><%= Secur32Util.getUserNameEx(Secur32.EXTENDED_NAME_FORMAT.NameSamCompatible) %></b>.
```

I have two users, _dblock-gray\dblock_ and _dblock-gray\test_. I am running the Tomcat server as _dblock-gray\dblock _and am browsing to it logged in as _dblock-gray\test_. Without impersonation I see the following.

![dblock-user]({{ site.url }}/images/posts/2011/2011-01-18-waffle-single-sign-on-user-impersonation-in-tomcat/dblock-user%5b5%5d.jpg)

This means that while I am logged in as the test user (`request.getRemoteUser()` returns _dblock-gray\test_), the Windows thread identity is the same one as of the Tomcat server (_dblock-gray\dblock_).

Let’s add _impersonate_ into  web.xml.

```xml
<filter>
  <filter-name>SecurityFilter</filter-name>
  <filter-class>waffle.servlet.NegotiateSecurityFilter</filter-class>
  <init-param>
    <param-name>impersonate</param-name>
    <param-value>true</param-value>
  </init-param>
</filter>
```

Tomcat now impersonates _dblock-gray\test_.

![test-user]({{ site.url }}/images/posts/2011/2011-01-18-waffle-single-sign-on-user-impersonation-in-tomcat/test-user%5b4%5d.jpg)

This is great news: I can now operate on behalf of _dblock-gray\test_ to, for example, access files that test owns on the server. Also note that this is the default behavior of IIS when you enable Windows Authentication and we’re now accomplishing the same with Tomcat or any other servlet-compliant server.
