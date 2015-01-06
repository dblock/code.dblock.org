---
layout: post
title: "Windows/Active Directory Authentication: Tomcat + JAAS w/ Waffle"
redirect_from: "/windowsactive-directory-authentication-tomcat-jaas-w-waffle"
date: 2010-05-24 12:24:18
tags: [tomcat, waffle, jna, java, active directory]
comments: true
---

![waffle]({{ site.url }}/images/posts/2010/2010-05-24-windowsactive-directory-authentication-tomcat-jaas-w-waffle/waffle_6.jpg)

We used to have code that checked whether a username/password was valid, then tried to enumerate user groups in Active Directory. That didn’t work for nested groups, domains with trusts and many other scenarios in-between. Then we wrote what eventually became Waffle. This week-end I added a JAAS LoginModule to Waffle 1.3. You can use this with anything that supports JAAS, such as Tomcat for BASIC, DIGEST or FORMS authentication. This is actually a simple demonstration (as opposed to the Single Sign-On Negotiate/NTLM/Kerberos valve) of Waffle and is how we originally used it. Here’s how.

#### Download

Download [Waffle 1.3](https://github.com/dblock/waffle). The zip contains _Waffle.chm_ that has the latest version of this tutorial.

#### Configure Tomcat

_Copy Files_

Copy _waffle-jna.jar_, _jna.jar_ and _platform.jar_ to Tomcat's _lib_ directory.

_JAAS Realm_

Add a JAAS realm to the application context. Modify _META-INF\context.xml _of your application.

```xml
<Context>
  <Realm className="org.apache.catalina.realm.JAASRealm"
         appName="Jaas"
         userClassNames="waffle.jaas.UserPrincipal"
         roleClassNames="waffle.jaas.RolePrincipal"
         useContextClassLoader="false"
         debug="true" />
</Context>
```

_Authentication_

Modify _WEB-INF\web.xml_ of your application.

Enable BASIC, DIGEST or FORMS authentication for this realm.

```xml
<login-config>
  <auth-method>BASIC</auth-method>
  <realm-name>Jaas</realm-name>
</login-config>
```

Configure security roles. The Waffle login module adds all user's security groups (including nested and domain groups) as roles during authentication.

```xml
<security-role>
  <role-name>Everyone</role-name>
</security-role>
```

Restrict access to website resources. For example, to restrict the entire website to locally authenticated users add the following.

```xml
<security-constraint>
  <display-name>Waffle Security Constraint</display-name>
  <web-resource-collection>
    <web-resource-name>Protected Area</web-resource-name>
    <url-pattern>/*</url-pattern>
  </web-resource-collection>
  <auth-constraint>
    <role-name>Everyone</role-name>
  </auth-constraint>
</security-constraint>
```

_Login Configuration_

Create a login configuration file, _login.conf_. This configuration file specifies how to plug the Waffle Windows Login Module.

```config
Jaas {
    waffle.jaas.WindowsLoginModule sufficient;
};
```

The login.conf configuration file is passed to Java with `-Djava.security.auth.login.config=<path-to-file>/login.conf`.

_JAAS Security Policy_

Create JAAS policy configuration file, jaas.policy. This file specifies which identities are granted which permissions.

```config
grant Principal * * {
  permission java.security.AllPermission "/*";
};
```

The policy file is passed to Java with `-Djava.security.auth.policy=<path-to-file>/jaas.policy`.

#### Start Tomcat

You must start Tomcat with Security Manager enabled (`-security`) and configure it with a login configuration and policy. For example, the following will start Tomcat using the demo login.conf and jaas.policy from the Waffle samples.

```bat
@echo off
setlocal
set JAVA_OPTS=-Djava.security.auth.login.config="C:/Program Files/Tomcat/webapps/waffle-jaas/login.conf" -Djava.security.auth.policy="C:/Program Files/Tomcat/webapps/waffle-jaas/jaas.policy"
call bin/catalina.bat run -security
endlocal
```

#### Demo Application

A demo application can be found in the Waffle distribution in the _Samples\Tomcat\waffle-jaas_ directory. Copy the entire directory into Tomcat's webapps directory, start Tomcat as explained above, and navigate to http://localhost:8080/waffle-jaas. You will be prompted for your Windows login, enter your Windows credentials and log-in.

![]({{ site.url }}/images/posts/2010/2010-05-24-windowsactive-directory-authentication-tomcat-jaas-w-waffle/image_5.jpg)

