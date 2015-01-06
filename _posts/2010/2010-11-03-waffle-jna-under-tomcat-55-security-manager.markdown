---
layout: post
title: "Waffle + JNA under Tomcat 5.5 Security Manager"
redirect_from: "/waffle-jna-under-tomcat-55-security-manager/"
date: 2010-11-03 14:50:39
tags: [tomcat, waffle, jna, security, java]
comments: true
---

I struggled with this one. Here’s how to get [JNA](https://github.com/twall/jna) and [Waffle](https://github.com/dblock/waffle/) to work under a Java security manager. In my case I have a Tomcat 5.5 which is launched with _-security_. Here’s the complete command-line.

```bat
@echo off
setlocal
set JAVA_OPTS=-Djava.security.auth.login.config="webapps/waffle-jaas/login.conf" -Djava.security.auth.policy="webapps/waffle-jaas/jaas.policy"
call bin/catalina.bat run -security
endlocal
```

Place all the JARs in _waffle/lib_ and added the folder to the common class loader in _conf/catalina.properties_. You can just put the files in common/lib of course.

```config
common.loader=...,${catalina.base}/waffle/lib/*.jar
```

Grant JNA permissions for your web applications in _conf/catalina.policy _and allow it to load a native library from a temporary location. JNA also tries to unpack _jnidispatch.dll_ for the proper platform into a temporary location from its own JAR, and then load it.  If the load fails you typically get a _"java.lang.UnsatisfiedLinkError: jnidispatch (/com/sun/jna/win32-x86/jnidispatch.dll) not found in resource path"_ exception.

The grants in my _conf/catalina.policy_ look like this.

```config
grant {
    ...

    // JNA
    permission java.util.PropertyPermission "jna.boot.library.path", "read";
    permission java.lang.RuntimePermission "loadLibrary.jnidispatch";
};

grant codeBase "file:${catalina.home}/waffle/lib/-" {
        permission java.security.AllPermission;
};
```

Because we’re dealing with authenticators in Waffle, grant catalina authenticator and realm classes runtime permissions.

```config
permission java.lang.RuntimePermission "accessClassInPackage.org.apache.catalina.*";
```

With this I was able to run all Waffle demos.
