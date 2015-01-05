---
layout: post
title: "JNA: AcquireCredentialsHandle, InitializeSecurityContext and AcceptSecurityContext - Establishing an Authenticated Connection"
redirect_from: "/jna-acquirecredentialshandle-initializesecuritycontext-and-acceptsecuritycontext-establishing-an-authenticated-connection"
date: 2010-03-26 15:05:31
tags: [waffle, jna, security, win32]
comments: true
---
I’ve been working on porting [WAFFLE](https://github.com/dblock/waffle) to Java/ [JNA](https://github.com/twall/jna/). As usual I have modest and practical goals with that project: to provide a working example for everything InitializeSecurityContext and AcceptSecurityContext and to replace the .NET -> COM -> Java bridge for [our application](http://www.appsecinc.com/products/dbprotect/). So lets get started.

#### The Problem

You’ve got a client and a server. For example, a browser and a web server. Both are joined to the same Active Directory domain. When you navigate to the website on your web server you don’t get prompted for credentials. How can this happen?

#### SSPI

On Windows, this works because of the [Security Support Provider Interface, aka SSPI](http://technet.microsoft.com/en-us/library/bb742535.aspx). SSPI is a well-defined API for obtaining integrated security services for, among other things, authentication for any distributed application protocol. A client-server conversation is an example of such an application. SSPI is a Microsoft proprietary implementation of [GSSAPI](http://en.wikipedia.org/wiki/Generic_Security_Services_Application_Program_Interface), an IETF standard. Who cares about standards, we just want it to work, right?

When a client wants to authenticate to a server, it needs to supply credentials and send them to the server. The server needs to validate this, reply that the credentials were kosher and possibly continue executing code on behalf of the client.

Credentials can come in a variety of forms, such as a username and password or a notarized birth certificate from City Hall. Sending those to the server needs to be secure: you don’t want to send credentials to the wrong server, the server wants to make sure you’re really who you claim to be and nobody should be able to intercept this data on the wire and reuse it. The how part of this is the job of the authentication protocol, such as, for example, NTLM or Kerberos.

Because there’re many protocols, SSPI exchanges so called _tokens_, opaque blobs of data. the protocol can put anything in the blobs.

Protocols often require several exchanges. For example, I may need to obtain the server’s public key, encrypt credentials, send them with my public key and receive an encrypted confirmation of success. Therefore both client and server maintain a so called _security context_ during this conversation.

SSPI allows you to do all this with any protocol or SSPI provider. There’s an NTLM SSPI provider, Kerberos SSPI provider, etc. SSPI describes three important calls that doo all of the above.

- [AcquireCredentialsHandle](http://msdn.microsoft.com/en-us/library/aa374712(VS.85).aspx): gets a HANDLE for outbound (client) or inbound (server) credentials
- [InitializeSecurityContext](http://msdn.microsoft.com/en-us/library/aa375506(VS.85).aspx): creates (or continues) a client-side security context
- [AcceptSecurityContext](http://msdn.microsoft.com/en-us/library/aa374703(VS.85).aspx): creates (or continues) a server-side security context

#### Implementation

You can now guess how this works.

![image]({{ site.url }}/images/posts/2010/2010-03-26-jna-acquirecredentialshandle-initializesecuritycontext-and-acceptsecuritycontext-establishing-an-authenticated-connection/image%5b4%5d.jpg)

#### Structures

We’re going to do this in JNA. First, some structure definitions.

A security handle is a pointer that holds credentials, context, etc. The `SecHandle`, `CtxtHandle` and `CredHandle` are all the same thing.

```java
public static class SecHandle extends Structure {
    public Pointer dwLower;
    public Pointer dwUpper;

    public SecHandle() {
        dwLower = null;
        dwUpper = null;
    }

    public boolean isNull() {
        return dwLower == null && dwUpper == null;
    }
}
```

A security buffer holds a single token. It has a size and a type. For example, a security token will be of `MAX_TOKEN_SIZE` size and `SECBUFFER_TOKEN` type.

```java
public static class SecBuffer extends Structure {

    public static class ByReference extends SecBuffer implements Structure.ByReference {
        public ByReference() {

        }

        public ByReference(int type, int size) {
            super(type, size);
        }
    }

    public NativeLong cbBuffer;
    public NativeLong BufferType;
    public Pointer pvBuffer;

    public SecBuffer() {
        cbBuffer = new NativeLong(0);
        pvBuffer = null;
        BufferType = new NativeLong(SECBUFFER_EMPTY);
    }

    public SecBuffer(int type, int size) {
        cbBuffer = new NativeLong(size);
        pvBuffer = new Memory(size);
        BufferType = new NativeLong(type);
        allocateMemory();
    }
}
```

Notice the infamous `ByReference` inner class, a handy way in JNA to have a `ByReference` and a non-By-Reference class that do the same thing.

An array of buffers is called a `SecBufferDesc`.

```java
public static class SecBufferDesc extends Structure {
    public NativeLong ulVersion;
    public NativeLong cBuffers;
    public SecBuffer.ByReference[] pBuffers;

    public SecBufferDesc() {
        ulVersion = new NativeLong(SECBUFFER_VERSION);
        cBuffers = new NativeLong(1);
        SecBuffer.ByReference secBuffer = new SecBuffer.ByReference();
        pBuffers = (SecBuffer.ByReference[]) secBuffer.toArray(1);
        allocateMemory();
    }

    public SecBufferDesc(int type, int tokenSize) {
        ulVersion = new NativeLong(SECBUFFER_VERSION);
        cBuffers = new NativeLong(1);
        SecBuffer.ByReference secBuffer = new SecBuffer.ByReference(type, tokenSize);
        pBuffers = (SecBuffer.ByReference[]) secBuffer.toArray(1);
        allocateMemory();
    }
}
```

Notice the way an array of inner buffers is declared `ByReference` and created with a `toArray` call. This tells JNA about a nested structure over a contiguous block of memory. It will be read and written automagically in and out of function calls.

The API also needs a timestamp.

```java
public static class SECURITY_INTEGER extends Structure {
    public NativeLong dwLower;
    public NativeLong dwUpper;

    public SECURITY_INTEGER() {
        dwLower = new NativeLong(0);
        dwUpper = new NativeLong(0);
    }
}

public static class TimeStamp extends SECURITY_INTEGER {

}
```

#### Secur32.dll

The above-mentioned functions are implemented in Secur32.dll.

```java
public interface Secur32 extends W32API {
    Secur32 INSTANCE = (Secur32) Native.loadLibrary(
            "Secur32", Secur32.class, W32APIOptions.UNICODE_OPTIONS);

    public int AcquireCredentialsHandle(String pszPrincipal, String pszPackage,
            NativeLong fCredentialUse, LUID pvLogonID,
            Pointer pAuthData, Pointer pGetKeyFn,
            Pointer pvGetKeyArgument, CredHandle phCredential,
            TimeStamp ptsExpiry);

    public int InitializeSecurityContext(CredHandle phCredential, CtxtHandle phContext,
            String pszTargetName, NativeLong fContextReq, NativeLong Reserved1,
            NativeLong TargetDataRep, SecBufferDesc pInput, NativeLong Reserved2,
            CtxtHandle phNewContext, SecBufferDesc pOutput, NativeLongByReference pfContextAttr,
            TimeStamp ptsExpiry);

    public int AcceptSecurityContext(CredHandle phCredential, CtxtHandle phContext,
            SecBufferDesc pInput, NativeLong fContextReq, NativeLong TargetDataRep,
            CtxtHandle phNewContext, SecBufferDesc pOutput, NativeLongByReference pfContextAttr,
            TimeStamp ptsTimeStamp);

    public int DeleteSecurityContext(CtxtHandle phContext);

    public int FreeCredentialsHandle(CredHandle phCredential);
}
```

#### Client-Server

We can do both client and server in the same code for the currently logged on user. In the real world you would only need the client or the server part and you would have to translate the pbClientToken and pbServerToken objects into bytes and send/receive them.

```java
try {
    // client ----------- acquire outbound credential handle
    CredHandle phClientCredential = new CredHandle();
    TimeStamp ptsClientExpiry = new TimeStamp();
    assertEquals(W32Errors.SEC_E_OK, Secur32.INSTANCE.AcquireCredentialsHandle(
     null, "Negotiate", new NativeLong(Sspi.SECPKG_CRED_OUTBOUND), null, null,
     null, null, phClientCredential, ptsClientExpiry));
    // client ----------- security context
    CtxtHandle phClientContext = new CtxtHandle();
    NativeLongByReference pfClientContextAttr = new NativeLongByReference();
    // server ----------- acquire inbound credential handle
    CredHandle phServerCredential = new CredHandle();
    TimeStamp ptsServerExpiry = new TimeStamp();
    if (W32Errors.SEC_E_OK != Secur32.INSTANCE.AcquireCredentialsHandle(
     null, "Negotiate", new NativeLong(Sspi.SECPKG_CRED_INBOUND), null, null,
     null, null, phServerCredential, ptsServerExpiry))) {
         throw RuntimeException("AcquireCredentialsHandle");
    }
    // server ----------- security context
    CtxtHandle phServerContext = new CtxtHandle();
    SecBufferDesc pbServerToken = new SecBufferDesc(Sspi.SECBUFFER_TOKEN, Sspi.MAX_TOKEN_SIZE);
    NativeLongByReference pfServerContextAttr = new NativeLongByReference();
    while(true) {
        // client ----------- initialize security context, produce a client token
        // client token returned is always new
        SecBufferDesc pbClientToken = new SecBufferDesc(Sspi.SECBUFFER_TOKEN, Sspi.MAX_TOKEN_SIZE);
        // server token is empty the first time
        int clientRc = Secur32.INSTANCE.InitializeSecurityContext(
                phClientCredential,
                phClientContext.isNull() ? null : phClientContext,
                Advapi32Util.getUserName(),
                new NativeLong(Sspi.ISC_REQ_CONNECTION),
                new NativeLong(0),
                new NativeLong(Sspi.SECURITY_NATIVE_DREP),
                pbServerToken,
                new NativeLong(0),
                phClientContext,
                pbClientToken,
                pfClientContextAttr,
                null);
        if (clientRc == W32Errors.SEC_E_OK)
            break;
        if(clientRc != W32Errors.SEC_I_CONTINUE_NEEDED) {
            throw RuntimeException("InitializeSecurityContext");
        }
        // server ----------- accept security context, produce a server token
        int serverRc = Secur32.INSTANCE.AcceptSecurityContext(phServerCredential,
                phServerContext.isNull() ? null : phServerContext,
                pbClientToken,
                new NativeLong(Sspi.ISC_REQ_CONNECTION),
                new NativeLong(Sspi.SECURITY_NATIVE_DREP),
                phServerContext,
                pbServerToken,
                pfServerContextAttr,
                ptsServerExpiry);
        if(serverRc != W32Errors.SEC_I_CONTINUE_NEEDED && serverRc != W32Errors.SEC_E_OK) {
            throw RuntimeException("AcceptSecurityContext");
        }
    }
} finally {
    // release server context
    Secur32.INSTANCE.DeleteSecurityContext(phServerContext);
    Secur32.INSTANCE.FreeCredentialsHandle(phServerCredential);
    // release client context
    Secur32.INSTANCE.DeleteSecurityContext(phClientContext);
    Secur32.INSTANCE.FreeCredentialsHandle(phClientCredential);
}
```

#### Source Code

`com.sun.jna.platform.win32.Secur32` and `com.sun.jna.platform.win32.Sspi` were committed to JNA. The example code is similar to `com.sun.jna.platform.win32.Secur32Test.testAcceptSecurityContext`.
