---
layout: post
title: "The program can’t start because msvcrt-ruby18.dll is missing from your computer."
redirect_from: "/the-program-cant-start-because-msvcrt-ruby18dll-is-missing-from-your-computer/"
date: 2011-01-14 21:50:59
tags: [rails, ruby, win32]
comments: true
dblog_post_id: 156
---
So I’ve been playing with Ruby. Yes, I am using a Windows 7 64-bit laptop and yes, despite the common message from most people on the Internet encouraging me to run Ubuntu, things work just fine.

One of the problems I ran into was the infamous _"The program can’t start because msvcrt-ruby18.dll is missing from your computer."_ error message.

![]({{ site.url }}/images/posts/2011/2011-01-14-the-program-cant-start-because-msvcrt-ruby18dll-is-missing-from-your-computer/image3.jpg)

I can’t believe how hard it is to find information about the real cause of this error! The only sensible information comes from [this](http://stackoverflow.com/questions/4572753/getting-the-error-msvcrt-ruby18-dll-is-missing-when-running-watir-scripts-after) thread: _You've probably installed some binary gems that was built against msvcrt-ruby18.dll._ Aha, there’s a native library that was built against the C runtime that ships with Ruby 1.8 (that obviously doesn’t exist with 1.9.2). Let's get rid of it, but instead of hunting down a gem by guessing, we can automate this process.

{% highlight bat %}
for /F %i in ( 'gem list --local' ) do ( echo "Loading %i ..." &amp; ruby -r rubygems -e "require '%i'" )
{% endhighlight %}

You get a popup after the offending gems (in my case _mysql _and _heroku_). Uninstalling those gems fixes the issue. Obviously I need Heroku for Rails applications, so I am just going to continue to have to live with this message for a while. Whatever Heroku tries to load doesn’t seem to affect heroku functionality that I am using.
