---
layout: post
title: "Waffle / Сейчас всё станет намного сложнее: troubleshooting Kerberos and NTLM"
redirect_from: "/waffle-troubleshooting-kerberos-and-ntlm/"
date: 2011-02-03 13:31:23
tags: [open source, waffle, security, active directory]
comments: true
dblog_post_id: 166
---
![usb-toaster]({{ site.url }}/images/posts/2011/2011-02-03-waffle-troubleshooting-kerberos-and-ntlm/usb-toaster_3.jpg)

I’ve often faced puzzling integrated authentication failures on Windows with [WAFFLE](https://github.com/dblock/waffle/). The usual suspects are _the logon attempt failed_ errors. Most of the time I’d try to run the server as a different user (localsystem, a domain user, etc.) and hope for the best. Things get quickly complicated with domain trusts, user accounts enabled for delegation, machine accounts enabled for delegation, plus the fact that the Negotiate protocol selects Kerberos vs. NTLM based on a clever client-server exchange amongst the three inseparable friends – the client, the server and one of the domain controllers distributed across five continents. The amount of possible combinations usually makes me sleepy and I realize that I easily give up.

Fortunately this is open-source software and where I fail others can pickup the ball. A thread had a Negotiate problem that smelled pretty bad, so I basically told @dorlov that he’s on his own and "good luck with that". Russians don’t seem to give up, so he solved his problem and assembled a few nice links that will help you troubleshoot issues with Kerberos and NTLM.

#### Troubleshooting Kerberos

- [Enabling Kerberos Logging](http://support.microsoft.com/?id=262177)
- [Troubleshooting Kerberos Delegation](https://support.microsoft.com/en-us/help/907272/kerberos-authentication-and-troubleshooting-delegation-issues)

#### Troubleshooting NTLM

- [Enabling NTLM Logging](http://blogs.technet.com/b/askds/archive/2009/10/08/ntlm-blocking-and-you-application-analysis-and-auditing-methodologies-in-windows-7.aspx)

#### Useful KBs

- [https://mskb.pkisolutions.com/kb/896861](https://mskb.pkisolutions.com/kb/896861)
- [http://technet.microsoft.com/en-us/library/dd566199(v=WS.10).aspx](http://technet.microsoft.com/en-us/library/dd566199(v=WS.10).aspx)
- [http://support.microsoft.com/kb/326040](http://support.microsoft.com/kb/326040)

