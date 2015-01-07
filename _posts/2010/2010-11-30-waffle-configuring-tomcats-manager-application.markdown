---
layout: post
title: "Waffle: configuring Tomcat’s manager application"
redirect_from: "/waffle-configuring-tomcats-manager-application/"
date: 2010-11-30 16:27:45
tags: [tomcat, waffle, security, active directory]
comments: true
dblog_post_id: 147
---
A user has recently tried to integrate Tomcat’s manager application with [Waffle](https://github.com/dblock/waffle/) and got puzzling results. It took me a while to figure it out, revealing some creative thinking in Tomcat’s demo apps.

#### Configure Tomcat SSO

Let's configure Tomcat to use waffle for SSO. First, copy _waffle-jna.jar_, _jna.jar_, _platform.jar_, _commons-logging-1.1.1.jar_ and _guava-r07.jar_ (we’re using Waffle 1.4 beta) to tomcat’s lib folder.

_conf/context.xml_

Add the Waffle valve.

{% highlight xml %}
<Valve className="waffle.apache.NegotiateAuthenticator" />
{% endhighlight %}

_conf/server.xml_

Replace UserDatabaseRealm with the Waffle dummy realm.

{% highlight xml %}
<Realm className="waffle.apache.WindowsRealm" />
{% endhighlight %}

_conf/web.xml_

Protect all pages from unauthenticated users.

{% highlight xml %}
<security-constraint>
  <web-resource-collection>
    <web-resource-name>
      Tomcat Server
    </web-resource-name>
    <url-pattern>/*</url-pattern>
    <http-method>GET</http-method>
    <http-method>POST</http-method>
  </web-resource-collection>
  <auth-constraint>
    <role-name>BUILTIN\Users</role-name>
  </auth-constraint>
</security-constraint>
{% endhighlight %}

You may declare the group as a role.

{% highlight xml %}
<security-role>
  <description>
    The role that is required to log in.
  </description>
  <role-name>BUILTIN\Users</role-name>
</security-role>
{% endhighlight %}

You can now navigate to http://localhost:8080/ and perform single sign-on. In the logs you’ll see something like this.

```
Nov 30, 2010 10:17:02 AM waffle.apache.NegotiateAuthenticator authenticate
INFO: successfully logged in user: server\username
```

#### Configure Tomcat Manager

_webapps/manager/WEB-INF/web.xml_

Replace the authentication constraint to the users that should be able to access the manager application. For my example I’ll allow all authenticated users. You may also declare the group as a role (see above).

{% highlight xml %}
<auth-constraint>
  <role-name>BUILTIN\Users</role-name>
</auth-constraint>
{% endhighlight %}

Remove the entire _login-config_ block.

_webapps/manager/401.jsp_

Remove the following line of code.

{% highlight jsp %}
<%
    response.setHeader("WWW-Authenticate", "Basic realm=\"Tomcat Manager Application\"");
%>
{% endhighlight %}

It’s an interesting way to force a basic authentication popup. If you fail authentication, you get this popup every time, even if you changed BASIC authentication for something else. I believe it’s part of some clever evil plot to cause users many hours of frustration.
