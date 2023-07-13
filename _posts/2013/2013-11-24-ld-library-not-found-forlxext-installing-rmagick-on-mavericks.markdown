---
layout: post
title: "ld: library not found for–lXext installing RMagick on Mavericks"
redirect_from: "/ld-library-not-found-forlxext-installing-rmagick-on-mavericks/"
date: 2013-11-24 19:00:20
tags: [ruby]
comments: true
dblog_post_id: 400
---
As always, ImageMagick is super fun after an OS upgrade. Mavericks + Ruby 2.x + RMagick failed with something very confusing today. It couldn’t find the Xext library, which is part of X11. Turns out, that was removed from Mavericks according to [https://support.apple.com/kb/HT5293](https://support.apple.com/kb/HT5293). Install XQuartz from [https://xquartz.macosforge.org/landing](https://xquartz.macosforge.org/landing) and the problem goes away.

```
$ cat ~/.rvm/gems/ruby-2.0.0-p353@gravity/gems/rmagick-2.13.2/ext/RMagick/mkmf.log

checking for Ruby version >= 1.8.5... -------------------- yes
find_executable: checking for /usr/bin/clang... -------------------- yes
find_executable: checking for Magick-config... -------------------- yes
checking for ImageMagick version >= 6.4.9... -------------------- yes
checking for HDRI disabled version of ImageMagick... -------------------- yes
"/usr/bin/clang -o conftest
 -I~/.rvm/rubies/ruby-2.0.0-p353/include/ruby-2.0.0/x86_64-darwin13.0.0
 -I~/.rvm/rubies/ruby-2.0.0-p353/include/ruby-2.0.0/ruby/backward
 -I~/.rvm/rubies/ruby-2.0.0-p353/include/ruby-2.0.0
 -I.
 -I/usr/local/Cellar/imagemagick/6.7.1-1/include/ImageMagick
 -I/usr/local/Cellar/imagemagick/6.7.1-1/include/ImageMagick
 conftest.c
 -L.
 -L~/.rvm/rubies/ruby-2.0.0-p353/lib
 -L/usr/local/opt/libyaml/lib
 -L/usr/local/opt/readline/lib
 -L/usr/local/opt/libksba/lib
 -L/usr/local/opt/openssl/lib
 -L/usr/local/Cellar/imagemagick/6.7.1-1/lib
 -L/usr/X11/lib
 -L/usr/local/Cellar/imagemagick/6.7.1-1/lib
 -lMagickCore -llcms -ltiff -lfreetype -ljpeg -lXext
 -lSM -lICE -lX11 -lXt -lbz2 -lz -lm -lpthread -lltdl
 -lruby.2.0.0  -lpthread -ldl -lobjc "

ld: library not found for -lXext

clang: error: linker command failed with exit code 1 (use -v to see invocation)
```
