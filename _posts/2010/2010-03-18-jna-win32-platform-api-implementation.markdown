---
layout: post
title: "JNA: Win32 platform API implementation"
redirect_from: "/jna-win32-platform-api-implementation/"
date: 2010-03-18 14:08:51
tags: [jna, java, win32]
comments: true
---
Lately I’ve been working on a native Java implementation of [Waffle](https://github.com/dblock/waffle) and contributing an increasing amount of code to the java.net [JNA](http://jna.java.net) project. Waffle has several goals that provide support for Windows authentication in Java. In this post I’ll describe the JNA implementation that allows us to retrieve user group memberships for the currently logged on user or a user logged on with a username and password. Both of these were made really simple by JNA.

A user’s security context is represented by a token and includes local and domain groups flattened out. That is, it contains all groups, including nested ones. If this construct didn’t exist, Windows would have to call Active Directory every time it wants to, for example, verify whether a logged on user has access to a certain file. Having the group memberships in the security context allows the operating system to compare the group SIDs with the values in the file’s ACL.

Incidentally, this concept has additional magical powers that we developed in one of my Microsoft patents, that allows you to inject a random group SID at logon by writing some SSPI code (a real brain teaser) for a group that doesn’t exist. You get a special SID for Passport accounts and hence can grant access to Passport users that have never logged on a server by looking up a user by e-mail and deriving a Passport SID. When the user actually logs on the server, he inherits a Passport SID in the list of group SIDs, and voila. This is how Password authentication works in Windows Longhorn. But I digress...

Asking the security context about group memberships is hence is the "correct" way of retrieving this information. I’ve seen many painfully complicated code that attempt to lookup user group memberships by enumerating groups, first local, then domain and even tries to get nested ones. This is a difficult process that almost never leads to correct results, especially in scenarios with Active Directory trusts.

#### Currently Logged-On User: security token

What we want is a security token for the current thread or, if that doesn’t exist, of the current process. This is the token that gives you access to the information such as which user created the thread or process (self) and hence which security groups are attached to it.

```java
HANDLEByReference phToken = new HANDLEByReference();
HANDLE threadHandle = Kernel32.INSTANCE.GetCurrentThread();
if (! Advapi32.INSTANCE.OpenThreadToken(threadHandle,
        WinNT.TOKEN_DUPLICATE | WinNT.TOKEN_QUERY, true, phToken)) {
    HANDLE processHandle = Kernel32.INSTANCE.GetCurrentProcess();
    if (! Advapi32.INSTANCE.OpenProcessToken(processHandle,
        WinNT.TOKEN_DUPLICATE | WinNT.TOKEN_QUERY, phToken)) {
            throw new LastErrorException(Kernel32.INSTANCE.GetLastError());
    }
}
Kernel32.INSTANCE.CloseHandle(phToken.getValue());
```

Notice that this kind of code is almost identical to .NET PInvoke. JNA makes it completely trivial to wrap a DLL function.

```java
public interface Advapi32 extends W32API {
    Advapi32 INSTANCE = (Advapi32) Native.loadLibrary("Advapi32",
            Advapi32.class, W32APIOptions.UNICODE_OPTIONS);

    public boolean OpenProcessToken(
            HANDLE ProcessHandle,
            int DesiredAccess,
            HANDLEByReference TokenHandle);
}
```

#### Currently Logged-On User: security groups

Now that we’re holding a security token, we can get the security groups. This is done with Advapi32.dll’s GetTokenInformation. The latter is a little tricky because the Win32 API is capable of retrieving all kinds of token information and takes a pointer to a buffer in memory. But in Java we want to get strongly typed Structure objects back. JNA simplifies this and makes pointer and structure virtually interchangeable by doing all the marshalling logic under the hood.

```java
public boolean GetTokenInformation(
        HANDLE tokenHandle,
        int tokenInformationClass,
        Structure tokenInformation,
        int tokenInformationLength,
        IntByReference returnLength);
```

We can derive `TOKEN_GROUPS` from `Structure` and pass it as `tokenInformation`.

```java
public static class TOKEN_GROUPS extends Structure {
    public TOKEN_GROUPS() {
        super();
    }

    public TOKEN_GROUPS(Pointer memory) {
        super(memory);
        read();
    }

    public int GroupCount;
    public SID_AND_ATTRIBUTES Group0;

    public SID_AND_ATTRIBUTES[] getGroups() {
        return (SID_AND_ATTRIBUTES[]) Group0.toArray(GroupCount);
    }
}
```

Notice that the number of `SID_AND_ATTRIBUTES` is unknown. When `GetTokenInformation` returns it puts the number of these items into `GroupCount`. JNA supports `Structure.toArray` that just says "this is not a structure, it’s an array of structures". This is similar to .NET’s `PInvoke Marshal.PtrToStructure`, albeit slightly more hacky because what we get back from Win32 is a pointer to an array, not a structure.

Finally, we can call `GetTokenInformation`, the first time to obtain the size of the memory required and the second time to get the actual data.

```java
// get token group information size
IntByReference tokenInformationLength = new IntByReference();
if (Advapi32.INSTANCE.GetTokenInformation(hToken,
        WinNT.TOKEN_INFORMATION_CLASS.TokenGroups, null, 0, tokenInformationLength)
        || Kernel32.INSTANCE.GetLastError() != W32Errors.ERROR_INSUFFICIENT_BUFFER) {
    throw new RuntimeException("Expected GetTokenInformation to fail with ERROR_INSUFFICIENT_BUFFER");
}
// get token group information
Memory tokenInformationBuffer = new Memory(tokenInformationLength.getValue());
WinNT.TOKEN_GROUPS groups = new WinNT.TOKEN_GROUPS(tokenInformationBuffer);
if (! Advapi32.INSTANCE.GetTokenInformation(hToken,
        WinNT.TOKEN_INFORMATION_CLASS.TokenGroups, groups,
        tokenInformationLength.getValue(), tokenInformationLength)) {
    throw new LastErrorException(Kernel32.INSTANCE.GetLastError());
}
// display groups
for (SID_AND_ATTRIBUTES sidAndAttribute : groups.getGroups()) {
    System.out.println("Group sid: " + Advapi32Util.convertSidToStringSid(sidAndAttribute.Sid));
    try {
        System.out.println("Group name: " + Advapi32Util.getAccountBySid(sidAndAttribute.Sid).name);
    } catch(Exception e) {
        System.out.println("Group name: <unknown>");
    }
}
```

#### Logon a User: security groups

The only difference of obtaining the security groups of a user that we logon with a username and password is that the user’s token is returned by `LogonUser`.

```java
HANDLEByReference phUser = new HANDLEByReference();
if(! Advapi32.INSTANCE.LogonUser(username, domain, password, WinBase.LOGON32_LOGON_NETWORK,
   WinBase.LOGON32_PROVIDER_DEFAULT, phUser)) {
       throw new LastErrorException(Kernel32.INSTANCE.GetLastError());
}

//
// ... proceed with GetTokenInformation using phUser.getValue()
//

Kernel32.INSTANCE.CloseHandle(phUser.getValue());
```

#### JNA Platform Library: making it easy, just for you

In the current JNA source you’ll find a few changes in the distribution structure: examples.jar is gone and a new platform.jar was added. Demos are built separately into a contrib folder. Platform-specific APIs, such as the ones described above, go into platform.jar. Win32 APIs are in `com.sun.jna.platform.win32`. There’re several classes that support the goals described above.

- `com.sun.jna.platform.win32.Advapi32`: pure Advapi32.dll interfaces
- `com.sun.jna.platform.win32.Advapi32Util`: a utility library that makes Advapi32.dll interfaces usable without too much hassle

I’ve added some useful functions to Advapi32Util:

- `convertSidToStringSid`: convert from a SID to a string
- `convertSidStringToSid`: convert from a string to a SID
- `getAccountByName`: retrieving account information by account name, using `LookupAccountName`
- `getAccountBySid`: retrieve account information by SID, using `LookupAccountSid`
- `getCurrentUserGroups`: get groups for the currently logged on user
- `getTokenAccount`: get information about the user who owns a token
- `getTokenGroups`: get groups for a give token (a user logged on with `LogonUser`)
