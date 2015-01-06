---
layout: post
title: "Single Sign-On: Servlet Negotiate Security Filter (Kerberos + NTLM) w/ Waffle and Jetty"
redirect_from: "/single-sign-on-servlet-negotiate-security-filter-kerberos-ntlm-w-waffle-and-jetty/"
date: 2012-10-02 20:55:56
tags: [waffle, security, active directory, win32]
comments: true
dblog_post_id: 349
---
![]({{ site.url }}/images/posts/2012/2012-10-02-single-sign-on-servlet-negotiate-security-filter-kerberos-ntlm-w-waffle-and-jetty/image_3.jpg)

Jetty is just another servlet container, so the setup is very similar to [Tomcat’s](http://code.dblock.org/single-sign-on-servlet-negotiate-security-filter-kerberos-ntlm-w-waffle).

1. Download an extract Jetty. I used [Jetty 6.1.26](http://dist.codehaus.org/jetty/jetty-6.1.26/jetty-6.1.26.zip).
2. Download the latest Waffle, I used a 1.5 beta from [https://github.com/dblock/waffle/downloads](https://github.com/dblock/waffle/downloads).
3. Place the **waffle-filter** demo app contents into **webapps\waffle-filter**.
4. Place all Waffle JARs into Jetty’s **lib** directory.
5. Start Jetty with **java -jar start.jar**.
6. In Internet Explorer, choose **Tools** , **Internet Options** and add [http://localhost](http://localhost) to **Local Intranet** in the **Security** tab.
7. Navigate to http://localhost:8080/waffle-filter, you should see the logged in page with all kinds of logged in info.
