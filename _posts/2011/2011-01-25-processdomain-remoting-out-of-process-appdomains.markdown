---
layout: post
title: "ProcessDomain: remoting & out-of-process AppDomains"
redirect_from: "/processdomain-remoting-out-of-process-appdomains/"
date: 2011-01-25 19:28:17
tags: [processdomain, appsecinc, open source, win32]
comments: true
dblog_post_id: 161
---
![gear]({{ site.url }}/images/posts/2011/2011-01-25-processdomain-remoting-out-of-process-appdomains/gear_5.jpg)

Some more open-source free goodness from AppSecInc today with eternal0’s release of .NET [ProcessDomain](https://web.archive.org/web/20120401193717/http://processdomain.codeplex.com/). This is AppSecInc’s fifth open-source project released under the Eclipse Public License.

> [processdomain.codeplex.com](https://web.archive.org/web/20120401193717/http://processdomain.codeplex.com/)

It’s basically what browsers do these days for isolating tasks in separate processes with AppDomain semantics. Our problem was running multiple jobs that have some native code that uses incompatible DLLs. You can’t load DLL1 and then DLL2, the process would crash or the job would fail. We were already doing this in AppDomains, so ProcessDomain was a virtually zero-line replacement that solved that problem.
