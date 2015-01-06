---
layout: post
title: "Guava: replacing a ConcurrentHashMap"
redirect_from: "/guava-replacing-a-concurrenthashmap"
date: 2010-10-04 18:18:52
tags: [java]
comments: true
---
I found half an hour this morning to look at [Waffle](https://github.com/dblock/waffle) issue #8493.

Negotiate is a multi-step protocol. After an initial request the Waffle authentication provider will add an entry to a hashtable mapping the new connection IDs to a newly obtained security context. At a subsequent step, the security context is retrieved from the hastable and used to continue the authentication protocol. If the connection is abandoned half way through this process, a handle will remain in the hashtable forever.

One of the solutions is to swap the hash structure for a cache that expires entries. I found [Guava (aka Google-collections)](http://code.google.com/p/guava-libraries/). Here’s my new concurrent hashmap with expiration.

```java
ConcurrentMap<String, CtxtHandle> _continueContexts = new MapMaker()
  .expiration(10, TimeUnit.SECONDS)
  .makeMap();
```

It couldn’t have been easier.

