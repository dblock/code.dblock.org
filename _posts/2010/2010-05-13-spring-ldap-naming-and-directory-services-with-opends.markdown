---
layout: post
title: "Spring-LDAP: Naming and Directory Services with OpenDS"
redirect_from: "/spring-ldap-naming-and-directory-services-with-opends/"
date: 2010-05-13 09:45:02
tags: [opends, spring, jndi, java]
comments: true
dblog_post_id: 102
---
![]({{ site.url }}/images/posts/2010/2010-05-13-spring-ldap-naming-and-directory-services-with-opends/image_4.jpg)

In a [previous post](/jndi-naming-and-directory-services-with-opends) I’ve described an initial implementation of OpenDS as a naming and directory service, including extending the directory schema and reading and writing directory objects with JNDI. As actual (read: competent) Java developers took over my prototype, they switched from JNDI to [spring-ldap](http://www.springsource.org/ldap). The resulting code is much more pleasant, and I got to learn a bit more about Spring.

#### Service Object

Let's get something useful in and out of the directory: a _Service_ object. Naturally it doesn’t matter where it came from, so the Service class is a simple container.

{% highlight java %}
public class Service {
    String _name;
    String _serviceUri;

    public Service(String name, String uri) {
        _name = name;
        _serviceUri = uri;
    }

    public String toString() {
        return _name + " @ " + _serviceUri;
    }

    public String getName() {
        return _name;
    }

    public void setName(String name) {
        _name = name;
    }

    public String getServiceUri() {
        return _serviceUri;
    }

    public void setServiceUri(String uri) {
        _serviceUri = uri;
    }
}
{% endhighlight %}

You’ll immediately notice that in contrast with the previous implementation, this object knows nothing about being stored in a directory. I was lazy then, but this time Spring helps (forces) me to write better code.

#### Service DAO

At the core of spring-ldap lies _LdapTemplate_ that executes core LDAP functionality and encapsulates all the plumbing. We’re going to implement a simple DAO for our Service objects that can, for example, retrieve all services.

{% highlight java %}
public class ServiceDAO {
    private LdapTemplate _ldapTemplate;

    public void setLdapTemplate(LdapTemplate ldapTemplate) {
        _ldapTemplate = ldapTemplate;
    }

    public List<Service> getAllServices() {
        return (List<Service>) _ldapTemplate.search("", "(objectclass=Service)",
                new ServiceAttributesMapper());
    }
}
{% endhighlight %}

Notice a few important things here. First, we have not specified how to connect to the LDAP server - that will appear in the runtime configuration. Secondly, we use _ServiceAttributesMapper_, a class that knows how to map LDAP attributes into a Service object, achieving a very nice separation of concerns.

{% highlight java %}
public class ServiceAttributesMapper implements AttributesMapper {
    public Object mapFromAttributes(Attributes attrs) throws NamingException {
        return new Service(
                attrs.get("name").get().toString(),
                attrs.get("serviceUri").get().toString()
                );
    }
}
{% endhighlight %}

#### Spring Configuration

To make it all work we need some configuration. We can define a _springldap.xml_ configuration file for our tests, another one for production, etc.

{% highlight xml %}
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-2.0.xsd">
    <bean id="contextSource"
        class="org.springframework.ldap.core.support.LdapContextSource">
        <property name="url" value="ldap://localhost:389" />
        <property name="base" value="dc=example,dc=com" />
        <property name="userDn" value="cn=Directory Manager" />
        <property name="password" value="password" />
    </bean>
    <bean id="ldapTemplate" class="org.springframework.ldap.core.LdapTemplate">
        <constructor-arg ref="contextSource" />
    </bean>
    <bean id="ldapService" class="com.example.springldap.ServiceDAO">
        <property name="ldapTemplate" ref="ldapTemplate" />
    </bean>
</beans>
{% endhighlight %}

What does this do?

1. Defines the values for the _LdapContextSource_. In our case, a url to our OpenDS installation, a base path to the objects, a user and password to access the directory.
2. Defines how to construct an _LdapTemplate_ that encapsulates LDAP core functionality. It takes the context source defined above.
3. Tells Spring to set the _LdapTemplate_ property of the _ServiceDAO_ with the value above.

We could have done this all in code, but Spring helps us create another level of abstraction and enables a complete configuration-based runtime experience.

#### Getting Services

We still need to tell Spring to use this configuration at runtime before we can call DAO methods such as _getAllServices_.

{% highlight java %}
Resource resource = new ClassPathResource("/springldap.xml");
BeanFactory factory = new XmlBeanFactory(resource);
ServiceDAO ldapService = (ServiceDAO) factory.getBean("ldapService");
List<Service> serviceList = ldapService.getAllServices();
{% endhighlight %}

This is nice! With Spring, we have achieved complete separation of responsibilities and pluggable configuration and, all things considered, wrote a lot less code.

#### More DAO

_Create or Update a Service_

{% highlight java %}
public void createOrUpdateService(Service s) {
    Attributes attrs = new BasicAttributes(true);  // Case ignore
    Attribute oc = new BasicAttribute("objectclass");
    oc.add("extensibleObject");
    oc.add("top");
    attrs.put(oc);
    attrs.put("objectclass", "Service");
    attrs.put("name", s.getName());
    attrs.put("serviceUri", s.getServiceUri());
    DistinguishedName newServiceDN = new DistinguishedName();
    newServiceDN.add("cn", s.getName());
    _ldapTemplate.rebind(newServiceDN, null, attrs);
}
{% endhighlight %}

_Delete a Service_

{% highlight java %}
public void deleteService(Service s) {
    DistinguishedName serviceDN = new DistinguishedName();
    serviceDN.add("cn", s.getName());
    _ldapTemplate.unbind(serviceDN);
}
{% endhighlight %}

_Get a Service by Name_

{% highlight java %}
public Service getServiceByName(String name) throws NameNotFoundException {
    return (Service) _ldapTemplate.lookup("cn=" + name,
            new ServiceAttributesMapper());
}
{% endhighlight %}

#### Running the Code

You can run the source code from this article with OpenDS and Eclipse.

1. Check out the source code from [here](https://github.com/dblock/codeproject/tree/master/JndiDemo).
2. Install OpenDS from [https://web.archive.org/web/20111001105032/http://www.opends.org](https://web.archive.org/web/20111001105032/http://www.opends.org).
3. Copy _schema\Services.ldif_ into _OpenDS\config\schema\100-Services.ldif_ and restart OpenDS.
4. Import the _JndiDemo_ project into Eclipse and run JUnit tests in the _src-test_ package.

#### Links

- [Source Code for this Article](https://github.com/dblock/codeproject/tree/master/JndiDemo)
- [OpenDS Directory Server](https://web.archive.org/web/20111001105032/http://www.opends.org/)
- [Getting Started with JNDI and OpenDS](/jndi-naming-and-directory-services-with-opends)
- [Spring-LDAP](http://www.springsource.org/ldap)
