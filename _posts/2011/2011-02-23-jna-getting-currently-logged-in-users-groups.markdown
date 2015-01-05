---
layout: post
title: "JNA: Getting currently logged-in user’s groups"
redirect_from: "/jna-getting-currently-logged-in-users-groups"
date: 2011-02-23 15:57:47
tags: [waffle, jna, security, win32]
comments: true
---
A Waffle user is asking how to get the groups for a currently logged-in user. You don’t need Waffle to do this, just JNA. The 3.2.7 release has an Advapi32Util class that implements retrieving users from the current thread or process token.

```java
for(Account a : Advapi32Util.getCurrentUserGroups()) {
  System.out.println(a.fqn);
}
```
