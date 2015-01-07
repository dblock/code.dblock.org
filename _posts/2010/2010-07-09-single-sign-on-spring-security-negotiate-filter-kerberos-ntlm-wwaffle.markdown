---
layout: post
title: "Single Sign-On: Spring-Security Negotiate Filter (Kerberos + NTLM) w/Waffle"
redirect_from: "/single-sign-on-spring-security-negotiate-filter-kerberos-ntlm-wwaffle/"
date: 2010-07-09 15:10:36
tags: [spring, waffle, security]
comments: true
dblog_post_id: 114
---

![springwaffle]({{ site.url }}/images/posts/2010/2010-07-09-single-sign-on-spring-security-negotiate-filter-kerberos-ntlm-wwaffle/springwaffle_3.jpg)

In this post I’ll explain how to configure the Waffle Spring-Security Negotiate filter to do single-sign-on on Windows and touch on how much more elegant the spring-based filter configuration is versus, for example, a generic servlet filter.

#### Download

Download [Waffle](https://github.com/dblock/waffle). The zip contains _Waffle.chm_ with the latest version of this tutorial.

#### Configure Your Application

_Configure Spring-Security_

We'll assume that [Spring-Security](http://static.springsource.org/spring-security/site/) is configured via web.xml with a filter chain and a Spring _ContextLoaderListener_. The Waffle beans configuration will be added to _waffle-filter.xml_.

{% highlight xml %}
<filter>
    <filter-name>springSecurityFilterChain</filter-name>
    <filter-class>org.springframework.web.filter.DelegatingFilterProxy</filter-class>
</filter>
<filter-mapping>
    <filter-name>springSecurityFilterChain</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>
<context-param>
    <param-name>contextConfigLocation</param-name>
    <param-value>/WEB-INF/waffle-filter.xml</param-value>
</context-param>
<listener>
    <listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
</listener>
{% endhighlight %}

_Package Files_

You need waffle-jna.jar, jna.jar, platform.jar and commons-logging-1.1.1.jar from the Waffle distribution as well as Spring and Spring-security JARs. Those should be placed in your application’s classpath (eg. packaged in WAR). If you’re using Tomcat, for demo purposes you can put these files in Tomcat’s _lib_.

_Windows Authentication Provider_

Declare a Windows Authentication provider. This is the link between Waffle and the operating system.

{% highlight xml %}
<bean id="waffleWindowsAuthProvider" class="waffle.windows.auth.impl.WindowsAuthProviderImpl" />
{% endhighlight %}

_Waffle Security Filter Providers_

Declare a collection of Waffle security filter providers that implement various authentication protocols.

{% highlight xml %}
<bean id="negotiateSecurityFilterProvider" class="waffle.servlet.spi.NegotiateSecurityFilterProvider">
  <constructor-arg ref="waffleWindowsAuthProvider" />
</bean>

<bean id="basicSecurityFilterProvider" class="waffle.servlet.spi.BasicSecurityFilterProvider">
  <constructor-arg ref="waffleWindowsAuthProvider" />
</bean>

<bean id="waffleSecurityFilterProviderCollection" class="waffle.servlet.spi.SecurityFilterProviderCollection">
  <constructor-arg>
    <list>
      <ref bean="negotiateSecurityFilterProvider" />
      <ref bean="basicSecurityFilterProvider" />
    </list>
  </constructor-arg>
</bean>
{% endhighlight %}

If you’re not very familiar with Spring, you will start loving it right here. We’re adding two providers to a collection in a configuration file. This means that we don’t need to have another configuration mechanism than this one to add or remove one. We don’t need to do this in code either. Each class instance (bean) is also configurable individually – we can, for example, configure the name of the realm for Basic authentication.

{% highlight xml %}
<bean id="basicSecurityFilterProvider" class="waffle.servlet.spi.BasicSecurityFilterProvider">
  <constructor-arg ref="waffleWindowsAuthProvider" />
  <property name="Realm" value="DemoRealm" />
</bean>
{% endhighlight %}

It’s more verbose, but it’s much more flexible.

_Add a Waffle Security Filter_

Add the Waffle security filter and entry point to the _sec:http_ configuration section. The filter will be placed before the Basic authentication filter that ships with Spring-Security. The filter uses the collection of authentication filter providers defined above to perform authentication.

{% highlight xml %}
<sec:http entry-point-ref="negotiateSecurityFilterEntryPoint">
  <sec:intercept-url pattern="/**" access="IS_AUTHENTICATED_FULLY" />
  <sec:custom-filter ref="waffleNegotiateSecurityFilter" position="BASIC_AUTH_FILTER" />
</sec:http>

<bean id="negotiateSecurityFilterEntryPoint" class="waffle.spring.NegotiateSecurityFilterEntryPoint">
  <property name="Provider" ref="waffleSecurityFilterProviderCollection" />
</bean>
{% endhighlight %}

_Spring-Security Authentication Manager_

Define a required default Spring-Security authentication manager. We’re not going to use it in this setup because the filter takes care of authentication and the user doesn’t have a way to supply, for example, a username and password.

{% highlight xml %}
<sec:authentication-manager alias="authenticationProvider" />
{% endhighlight %}

Note that Waffle does include a Spring-based authentication manager for form-based authentication or non-web-based scenarios.

_The Filter Itself_

Finally, define the Spring-Security Waffle filter that uses the collection of security filter providers to perform authentication.

{% highlight xml %}
<bean id="waffleNegotiateSecurityFilter" class="waffle.spring.NegotiateSecurityFilter">
  <property name="Provider" ref="waffleSecurityFilterProviderCollection" />
</bean>
{% endhighlight %}

#### Demo Application

A demo application with the complete configuration file can be found in the Waffle distribution in the _Samples\waffle-spring-filter_ directory. Copy the entire directory into Tomcat's webapps directory and navigate to http://localhost:8080/waffle-spring-filter. You should be automatically logged-in under your current Windows account.

#### Links

- [Spring-Security](http://static.springsource.org/spring-security/site/)
- [Waffle](https://github.com/dblock/waffle)
