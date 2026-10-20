---
layout: post
title: "Waffle: Single Sign-On User Impersonation in Tomcat"
redirect_from: "/waffle-single-sign-on-user-impersonation-in-tomcat/"
date: 2011-01-18 14:21:02
tags: [tomcat, waffle, jna, security, java, active directory, win32, open-source]
dblog_post_id: 157
---
![]({{ site.url }}/images/posts/2011/2011-01-18-waffle-single-sign-on-user-impersonation-in-tomcat/image_3.jpg)

A generous contributor (Nicolas Guillaumin, @nguillaumin) who works for a company called Funnelback, has committed the much requested impersonation support to Waffle. This is pretty exciting, since it fills in a bunch of squares in the puzzle that we're trying to assemble with the [Waffle project](https://github.com/dblock/waffle).

I tried it out with build 1.4.1744.0.

First, there's a line of code in the _index.jsp_ that displays the current Windows thread identity by calling a Win32 API via JNA.

```jsp
You are logged in as remote user <b><%= request.getRemoteUser() %></b> in session <b><%= session.getId() %></b>.<br>
You are impersonating user <b><%= Secur32Util.getUserNameEx(Secur32.EXTENDED_NAME_FORMAT.NameSamCompatible) %></b>.
```

I have two users, `dblock-gray\dblock` and `dblock-gray\test`. I am running the Tomcat server as `dblock-gray\dblock` and am browsing to it logged in as `dblock-gray\test`. Without impersonation I see the following.

![dblock-user]({{ site.url }}/images/posts/2011/2011-01-18-waffle-single-sign-on-user-impersonation-in-tomcat/dblock-user_5.jpg)

This means that while I am logged in as the test user (`request.getRemoteUser()` returns `dblock-gray\test`), the Windows thread identity is the same one as of the Tomcat server (`dblock-gray\dblock`).

Let's add _impersonate_ into  web.xml.

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

Tomcat now impersonates `dblock-gray\test`.

![test-user]({{ site.url }}/images/posts/2011/2011-01-18-waffle-single-sign-on-user-impersonation-in-tomcat/test-user_4.jpg)

This is great news: I can now operate on behalf of `dblock-gray\test` to, for example, access files that test owns on the server. Also note that this is the default behavior of IIS when you enable Windows Authentication and we're now accomplishing the same with Tomcat or any other servlet-compliant server.
