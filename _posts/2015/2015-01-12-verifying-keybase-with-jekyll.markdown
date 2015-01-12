---
layout: post
title: "Verifying a Jekyll Site With Keybase.io"
date: 2015-01-12
tags: [jekyll, keybase.io]
comments: true
---
The future of communication is signed and sources are trusted. You can find me at [keybase.io/dblock](https://keybase.io/dblock).

Keybase wants you to host a .txt file on your website to prove your identity. With Jekyll, create a _keybase.txt_ file in any folder that isn't prefixed with an underscore (mine is in [_pages/keybase.txt_](https://github.com/dblock/www.dblock.org/blob/gh-pages/pages/keybase.txt)) and use the _permalink_ keyword to place it on the website.

```
---
permalink: /.well-known/keybase.txt
---
==================================================================
https://keybase.io/dblock
--------------------------------------------------------------------

(the rest of your claim ...)
```

Everything is open-source, check out [www.dblock.org#2ed83ee3](https://github.com/dblock/www.dblock.org/commit/2ed83ee3c2916e20f773a02721e8377df7cbfbcb).
