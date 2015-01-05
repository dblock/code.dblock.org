---
layout: post
title: "Single Sign-On: Servlet Negotiate Security Filter (Kerberos + NTLM) w/ Waffle"
redirect_from: "/single-sign-on-servlet-negotiate-security-filter-kerberos-ntlm-w-waffle"
date: 2010-05-25 18:03:19
tags: [tomcat, waffle, security, java, active directory]
comments: true
---

_Jamais deux sans trois._

![waffle]({{ site.url }}/images/posts/2010/2010-05-25-single-sign-on-servlet-negotiate-security-filter-kerberos-ntlm-w-waffle/waffle%5b3%5d.jpg)

#### Download

Download [Waffle 1.3](https://github.com/dblock/waffle).

#### Configure Tomcat

_Copy Files_

Copy _waffle-jna.jar_, _jna.jar_ and _platform.jar_ to Tomcat's _lib_ directory. You can package these files with your application, but this is easier for the demonstration.

_Security Filter_

Add the security filter to _WEB-INF\web.xml_.

```xml
<filter>
  <filter-name>SecurityFilter</filter-name>
  <filter-class>waffle.servlet.NegotiateSecurityFilter</filter-class>
</filter>
<filter-mapping>
  <filter-name>SecurityFilter</filter-name>
  <url-pattern>/*</url-pattern>
</filter-mapping>
```

That’s it.

#### Demo Application

A demo application can be found in the Waffle distribution in the _Samples\Tomcat\waffle-filter_ directory. Copy the entire directory into Tomcat's webapps directory and navigate to http://localhost:8080/waffle-filter.

#### Retrieving User Principal

If you’re familiar with Tomcat you’ll be surprised that `<%= request.getUserPrincipal().getName() %>` works in a JSP page with this filter in place and no realm configuration. Theoretically Tomcat says you cannot assign a Principal to the request in a filter. The guys at the [Tomcat Security Filter Project](http://securityfilter.sourceforge.net/) found a very simple solution – wrap the request up and pass the wrapper into the next filter in the chain.

```java
WindowsPrincipal windowsPrincipal = new WindowsPrincipal(windowsIdentity, null, _principalFormat, _roleFormat);
subject.getPrincipals().add(windowsPrincipal);
session.setAttribute("javax.security.auth.subject", subject);
NegotiateRequestWrapper requestWrapper = new NegotiateRequestWrapper(request, windowsPrincipal);
chain.doFilter(requestWrapper, response);
```
