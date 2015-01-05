---
layout: post
title: "JNDI: Naming and Directory Services with OpenDS"
redirect_from: "/jndi-naming-and-directory-services-with-opends"
date: 2010-04-13 15:07:34
tags: [soa, jndi, java, active directory]
comments: true
---
I often hear from .NET programmers "I’d like to get into Java, not the language, but all that J2EE stuff ...". I am one of those people so I try to use any opportunity to try something I’ve never touched before.

We’re moving to a SOA model with the product at my [day job](http://www.appsecinc.com). One of the fundamental questions is: _"How does a service find another service?"._ The standard answer is to use a naming and directory service and in Java you talk to one of these things with [JNDI](http://java.sun.com/products/jndi/).

First, a few basics.

- **Naming service** is a fundamental facility in any computing system. It’s the means by which names are associated with objects and objects are found based on their names. For example, to access a file on the computer you must provide its name.
- **Directory Service** is an extension of the naming services. A directory service associates names with objects and also allows such objects to have _attributes_. Thus, you not only can look up an object by its name but also get the object's attributes or search for the object based on its attributes.

By using a directory service, you can simplify applications and their administration by centralizing the storage of shared information. For our purposes such information includes SOAP service URIs. For example, you can find demoService (a previously agreed-upon name of the demo service) at *http://localhost:20080/demo*.

#### Client & Server

I picked up [OpenDS](http://www.opends.org/), on open-source server from Sun. After a straightforward installation (set _OPENDS_JAVA_HOME_ to a JRE location and run _setup.bat_) I had an LDAP server running as a Windows Service (OpenDS) on port 389. There’s a handy _bat\control-panel.bat_ that launches a schema and object browser.

We can now access this server with JNDI, which comes standard with Java Platform 1.1.2 or later.

```cs
Hashtable<String, String> env = new Hashtable<String, String>();
env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
env.put(Context.PROVIDER_URL, "ldap://localhost:389/dc=example,dc=com");
env.put(Context.SECURITY_AUTHENTICATION, "simple");
env.put(Context.SECURITY_PRINCIPAL, "cn=Directory Manager");
env.put(Context.SECURITY_CREDENTIALS, "password");
DirContext ctx = new InitialDirContext(env);
Attributes attrs = ctx.getAttributes("");
NamingEnumeration<? extends Attribute> e = attrs.getAll();
while(e.hasMore()) {
    System.out.println(e.next());
}
ctx.close();
```

This outputs the attributes of my initial domain context that was created at setup time.

```
dc: appsecinc
objectClass: domain, top
```

#### The Goal

Let’s create a directory for our SOAP services. The goal is to be able to store a collection of service objects, each containing a well-defined URL and retrieve service URLs using the service names.

#### Extending the Schema

The OpenDS schema is stored in .ldif files in the config\schema directory. The directory schema can be extended by importing LDIF files, modifying those in the schema directory or programmatically with JNDI. I’ll write an import an .ldif file.

There’re several RFCs with various well-known attribute types, such as _name_ or _uid_. We’re only missing _serviceUri_, which we can define as a custom attribute.

```opends
attributeTypes: ( 1.2.840.113556.1.8000.2554.999999.1 NAME 'serviceUri'
    DESC 'service URI' EQUALITY caseIgnoreMatch ORDERING caseIgnoreOrderingMatch
    SUBSTR caseIgnoreSubstringsMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 )
```

Our _Service_ type is defined as follows: an object with a common name (cn), a humanly readable name (name), an object class (Service), a unique identifier (uid) and an url to the service (serviceUri).


```opends
objectClasses: ( 1.2.840.113556.1.8000.2554.999999.2 NAME 'Service'
    DESC 'a SOAP Service' SUP top
    STRUCTURAL MUST ( cn $ name $ objectClass $ uid $ serviceUri ) )
```

#### OIDs

You can generate a root OID using [this script](http://msdn.microsoft.com/en-us/library/ms677620.aspx) (save the script to disk and run `cscript script.vbs`) and keep adding numbers to it. It’s just a globally unique number that identifies an attribute or a class. I generated OID 1.2.840.113556.1.8000.2554.999999.

#### Service in Java

Let's define a Service Java class that can be used to read and write objects to the directory.

```java
package com.example.jndi;

import javax.naming.NameNotFoundException;
import javax.naming.NamingException;
import javax.naming.directory.Attribute;
import javax.naming.directory.Attributes;
import javax.naming.directory.BasicAttribute;
import javax.naming.directory.BasicAttributes;

public class Service extends UnimplementedDirContext {
    String _name;
    String _serviceUri;
    String _uid;

    public Service(String uid, String name, String uri) {
        _uid = uid;
        _name = name;
        _serviceUri = uri;
    }

    public Service(Attributes inAttrs) {
        _name = inAttrs.get("name").toString();
        _serviceUri = inAttrs.get("serviceUri").toString();
        _uid = inAttrs.get("uid").toString();
    }

    @Override
    public Attributes getAttributes(String name) throws NamingException {
        if (! name.equals("")) {
            throw new NameNotFoundException();
        }

        Attributes attrs = new BasicAttributes(true);  // Case ignore
        Attribute oc = new BasicAttribute("objectclass");
        oc.add("extensibleObject");
        oc.add("top");
        attrs.put(oc);
        attrs.put("objectclass", "Service");
        attrs.put("name", _name);
        attrs.put("uid", _uid);
        attrs.put("serviceUri", _serviceUri);
        return attrs;
    }

    public String toString() {
        return _name + " @ " + _serviceUri;
    }
}
```

This is a simple container for attributes. The `UnimplementedDirContext` is an empty class that throws NotImplementedException on two dozen methods that are required by a full `DirContext`.

#### A Services Organization

We’d like to organize services under a Services organization. I’ve created that manually in the directory. The full directory path to the OU is `o=Services,dc=example,dc=com`.

#### Writing to the Directory

A write is a call to `bind`. Binding means connecting a _name_ to an _object_. You can `rebind`, ie. either create or update an existing object.

```java
Service demoService = new Service(
        "{F6E978E7-A0BC-47ae-95A9-219CD40C5993}",
        "demoService",
        "http://localhost:20080/demo/");
ctx.rebind("cn=demoService,o=Services", demoService);
```

Here’s what we have in the directory now (this is the _Manage Entries_ UI from the control panel tool that comes with OpenDS).

![image]({{ site.url }}/images/posts/2010/2010-04-13-jndi-naming-and-directory-services-with-opends/image%5b14%5d.jpg)

#### Retrieving from the Directory

In order to retrieve a strongly typed object from the directory we must supply an object factory. When the factory encounters an object with an `objectClass=Service`, it will create an instance of such.


```java
package com.example.jndi;

import javax.naming.*;
import javax.naming.directory.*;
import javax.naming.spi.DirObjectFactory;
import java.util.Hashtable;

public class ServiceFactory implements DirObjectFactory {

    public ServiceFactory() {

    }

    public Object getObjectInstance(Object obj, Name name, Context ctx,
            Hashtable<?, ?> env, Attributes inAttrs) throws Exception {

        if (obj instanceof DirContext) {
            Attribute objectClass = inAttrs.get("objectClass");
            NamingEnumeration<?> ne = objectClass.getAll();
            while(ne.hasMore()) {
                if (ne.next().equals("Service")) {
                    return new Service(inAttrs);
                }
            }
        }

        return null;
    }

    public Object getObjectInstance(Object obj, Name name, Context ctx, Hashtable<?, ?> env) throws Exception {
        return getObjectInstance(obj, name, ctx, env, null);
    }
}
```

The initial directory context must be told to use this factory.

```java
env.put(Context.OBJECT_FACTORIES, "com.example.jndi.ServiceFactory");
```

Finally, the retrieval becomes a simple lookup.

```java
Service demoService = (Service) ctx.lookup("cn=demoService,o=Services");
```

#### Deleting Directory Objects

To complete the picture, let's delete a directory object. This is the opposite of `bind`, `unbind`.

```java
ctx.unbind("cn=demoService,o=Services");
```

#### A Word on XML

All this requires server-side Java code and keeping the LDAP port 389 open.

Alternatively, OpenDS provides an implementation of Directory Services Markup Language (DSML), an XML API to directory services. It’s then possible to switch JNDI client code from LDAP to DSML using [a Sun early access JNDI client for DSML](http://java.sun.com/developer/earlyAccess/jndi/).

#### Links

- [Naming and Directory Services Tutorial](http://java.sun.com/products/jndi/tutorial/TOC.html)
- [OpenDS Directory Server](http://www.opends.org/)
- [Source Code for this Article](https://github.com/dblock/codeproject/tree/master/JndiDemo)
  - [Service.java](https://github.com/dblock/codeproject/blob/master/JndiDemo/src/com/example/jndi/Service.java)
  - [UnimplementedDirContext.java](https://github.com/dblock/codeproject/blob/master/JndiDemo/src/com/example/jndi/UnimplementedDirContext.java)
  - [ServiceFactory.java](https://github.com/dblock/codeproject/blob/master/JndiDemo/src/com/example/jndi/ServiceFactory.java)

