---
layout: post
title: "NTLM: Please show ID with every POST"
redirect_from: "/ntlm-please-show-id-with-every-post/"
date: 2010-05-20 22:16:08
tags: [gwt, waffle, security, java]
comments: true
dblog_post_id: 104
---

#### Prologue

I was debugging a GWT application that worked well with FORM authentication and refused to work with integrated Windows auth (NTLM/Kerberos) on some machines. It all started with a benign error message.

![]({{ site.url }}/images/posts/2010/2010-05-20-ntlm-please-show-id-with-every-post/image_2.jpg)

The log reveals an interesting stack.

```
Exception while dispatching incoming RPC call
java.lang.IllegalArgumentException: encodedRequest cannot be empty
at com.google.gwt.user.server.rpc.RPC.decodeRequest(RPC.java:226)
at com.google.gwt.user.server.rpc.RemoteServiceServlet.processCall(RemoteServiceServlet.java:163)
at com.google.gwt.user.server.rpc.RemoteServiceServlet.doPost(RemoteServiceServlet.java:86)
at javax.servlet.http.HttpServlet.service(HttpServlet.java:709)
at javax.servlet.http.HttpServlet.service(HttpServlet.java:802)
```

We’re in the middle of an Ajax POST. Examining the HTTP request we find that it doesn’t have a body. This explains why GWT is throwing this exception, but doesn’t explain why this happens. I asked for help on both the [GWT group](http://groups.google.com/group/google-web-toolkit/browse_thread/thread/6039401ab4221f7c) and on [EXTJs premium forum](http://www.extjs.com/forum/showthread.php?99321-Exception-while-dispatching-incoming-RPC-call), but didn’t get anything useful.

```
POST /dbprotect/com.example.gwt.main/service/ServiceRPC HTTP/1.1
Accept: */*
Accept-Language: en-us
Content-Type: text/x-gwt-rpc; charset=utf-8
Accept-Encoding: gzip, deflate
User-Agent: Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.2; Trident/4.0; …)
Host: localhost:20080
Content-Length: 0
Connection: Keep-Alive
Cache-Control: no-cache
Authorization: Negotiate TlRMTVNTUAABAAAAB7IIogkACQAxAAAACQAJACgAAAAFAs4OAAAAD0RET1VCLVJFRFdPUktHUk9VUA==
```

#### The Issue

I mentioned that I had two environments: one that worked and one that didn’t. The defining moment came when [John](http://blog.johnhite.com/) pointed out that the working environment was choosing _Kerberos_, while the non-working environment was choosing _NTLM_ when performing _Negotiate_ authentication. It was clear that after a Kerberos auth the POST no longer carried an Authorization header and had a body.

I (mistakenly) concluded that this was a GWT bug with Internet Explorer. It failed the same way in Chrome though, so this wasn’t some kind of conspiracy.

#### The Explanation

I started reading GWT code. I also read the [NTLM RFC](http://davenport.sourceforge.net/ntlm.html). The latter was helpful.

> _This scheme differs from most "normal" HTTP authentication mechanisms, in that subsequent requests over the authenticated connection are not themselves authenticated; NTLM is connection-oriented, rather than request-oriented. So a second request for "/index.html" would not carry any authentication information, and the server would request none. If the server detects that the connection to the client has been dropped, a request for "/index.html" would result in the server reinitiating the NTLM handshake._

> _A notable exception to the above is the client's behavior when submitting a POST request (typically employed when the client is sending form data to the server). If the client determines that the server is not the local host, the client will initiate reauthentication for POST requests over the active connection. The client will first submit an empty POST request with a Type 1 message in the "Authorization" header; the server responds with the Type 2 message (in the "WWW-Authenticate" header as shown above). The client then resubmits the POST with the Type 3 message, sending the form data with the request._

#### The Fix

This fix was easy. When an empty POST is sent, we must follow the protocol and perform authentication instead of assuming that the client is already authenticated (we did do that in a previous GET). This is now properly implemented in the [Waffle Tomcat Authenticator](https://github.com/dblock/waffle).

#### Suboptimal Performance

There’s a big side effect to this NTLM negotiation – degraded performance. You’re getting a POST request that requires authentication every time you have a new connection. This happens a lot with AJAX sites, such as GWT-based ones. A workaround is described in [KB251404](http://support.microsoft.com/kb/251404), setting _HKEY_CURRENT_USER/Software/Microsoft/Windows/CurrentVersion/Internet Settings/DisableNTLMPreAuth_ to 1.

In a properly configured Active Directory you’re most likely to be using Kerberos anyway. This requires a valid SPN. Read [this article](http://blogs.msdn.com/sql_protocols/archive/2006/12/02/understanding-kerberos-and-ntlm-authentication-in-sql-server-connections.aspx) to start – it’s about SQL server, but applies to all services. Adding a _HTTP/server.com:port_ SPN was sufficient in some of my test environments to avoid NTLM altogether.
