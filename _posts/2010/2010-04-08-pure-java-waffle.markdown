---
layout: post
title: "Pure Java Waffle"
redirect_from: "/pure-java-waffle"
date: 2010-04-08 12:53:46
tags: [waffle, jna, security, java, active directory, win32]
comments: true
---

[![](https://github.com/dblock/waffle/raw/master/waffle.jpg)](https://github.com/dblock/waffle/)

I finally got to porting [Waffle](https://github.com/dblock/waffle/) to pure java with [JNA](https://github.com/twall/jna/). This means you don’t need .NET framework or COM to call Waffle from Java. It’s pure Java.

Waffle is a thin interface that simplifies Windows authentication and authorization, therefore providing a practical and workable back-end for NTLM, Negotiate, Kerberos and other [SPNEGOs](http://en.wikipedia.org/wiki/SPNEGO). Here’re some scenarios that you can now do without any headache directly in Java.

#### Logon a user: get his local and domain groups

This calls Win32 `LogonUser`, examines the user token and extracts all local and domain group memberships from it. This obviously includes nested groups.

```java
IWindowsAuthProvider prov = new WindowsAuthProviderImpl();
IWindowsIdentity identity = prov.logonUser("username", "password");
System.out.println("User identity: " + identity.getFqn());
for(IWindowsAccount group : identity.getGroups()) {
    System.out.println(" " + group.getFqn() + " (" + group.getSidString() + ")");
}
```

Here’re the first lines of output for my current user:

```
User identity: dblock-green\dblock
dblock-green\None (S-1-5-21-3442045183-1395134217-4167419351-513)
Everyone (S-1-1-0)
dblock-green\HomeUsers (S-1-5-21-3442045183-1395134217-4167419351-2418)
BUILTIN\Administrators (S-1-5-32-544)
BUILTIN\Users (S-1-5-32-545)
NT AUTHORITY\NETWORK (S-1-5-2)
```

#### Active directory: get the list of trusted domains

```java
IWindowsAuthProvider prov = new WindowsAuthProviderImpl();
IWindowsDomain[] domains = prov.getDomains();
for(IWindowsDomain domain : domains) {
    System.out.println(domain.getFqn() + ": " + domain.getTrustDirectionString());
}
```

The typical scenario is presenting a dropdown in front of the user to choose domains he can logon to. This list includes the current domain and all domain trusts.

#### Active directory: is this computer joined to a domain?

```java
IWindowsAuthProvider prov = new WindowsAuthProviderImpl();
IWindowsComputer computer = prov.getCurrentComputer();
System.out.println(computer.getComputerName());
System.out.println(computer.getJoinStatus());
System.out.println(computer.getMemberOf());
```

For systems that run both with and without active directory you need to programmatically figure out whether a computer is joined to a domain or a workgroup. If it’s joined to a domain or a workgroup you want to know what domain the computer is joined to.

#### Local machine: enumerate local groups

```java
IWindowsAuthProvider prov = new WindowsAuthProviderImpl();
IWindowsComputer computer = prov.getCurrentComputer();
String[] localGroups = computer.getGroups();
for(String localGroup : localGroups) {
    System.out.println(" " + localGroup);
}
```

#### Negotiate: single sign-on

This is the sweetest waffle, both the client and the server-side of the Negotiate protocol made super easy. You would typically split this code in two halves and do the work of transmitting the tokens between client and server. In the end, the user is logged on to the server side and you can examine his local and domain groups.


```java
String securityPackage = "Negotiate";
// client credentials handle
IWindowsCredentialsHandle clientCredentials = WindowsCredentialsHandleImpl.getCurrent(securityPackage);
clientCredentials.initialize();
// initial client security context
WindowsSecurityContextImpl clientContext = new WindowsSecurityContextImpl();
clientContext.setPrincipalName(Advapi32Util.getUserName());
clientContext.setCredentialsHandle(clientCredentials.getHandle());
clientContext.setSecurityPackage(securityPackage);
clientContext.initialize();
// accept on the server
WindowsAuthProviderImpl provider = new WindowsAuthProviderImpl();
IWindowsSecurityContext serverContext = null;
do
{
    if (serverContext != null) {
        // initialize on the client
        SecBufferDesc continueToken = new SecBufferDesc(Sspi.SECBUFFER_TOKEN, serverContext.getToken());
        clientContext.initialize(clientContext.getHandle(), continueToken);
    }
    // accept the token on the server
    serverContext = provider.acceptSecurityToken(clientContext.getToken(), securityPackage);
} while (clientContext.getContinue() || serverContext.getContinue());

System.out.println(serverContext.getIdentity().getFqn());
for (IWindowsAccount group : serverContext.getIdentity().getGroups()) {
    System.out.println(" " + group.getFqn());
}

serverContext.dispose();
clientContext.dispose();
clientCredentials.dispose();
```

#### Integration and Download

Waffle now has the same (or very similar) interface in C#, COM, Jacob and pure Java. So you can use it in a variety of applications. For COM we supply a merge module for your installer. For C#, reference **Waffle.Windows.AuthProvider.dll**. For Java, reference **waffle-jna-auth.jar** and include jna.jar and platform.jar in your distribution.
