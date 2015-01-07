---
layout: post
title: "JacobGen: PROCESSOR_ARCHITECTURE vs. PROCESSOR_ARCHITEW6432 in MSBuild"
redirect_from: "/jacobgen-processorarchitecture-vs-processorarchitew6432-in-msbuild/"
date: 2010-11-21 15:02:29
tags: [waffle, java, msbuild]
comments: true
dblog_post_id: 145
---
I recently moved to a 64-bit Windows 7 and one of my project’s build broke.

```
Exception in thread "main" java.lang.UnsatisfiedLinkError:
    Tools\JacobGen\x86\jacobgen.dll: Can't load IA 32-bit .dll on a AMD 64-bit platform
        at java.lang.ClassLoader$NativeLibrary.load(Native Method)
        at java.lang.ClassLoader.loadLibrary0(ClassLoader.java:1803)
        at java.lang.ClassLoader.loadLibrary(ClassLoader.java:1728)
        at java.lang.Runtime.loadLibrary0(Runtime.java:823)
        at java.lang.System.loadLibrary(System.java:1028)
        at com.jacob.jacobgen.TypeLibInspector.<clinit>(TypeLibInspector.java:39)
        at com.jacob.jacobgen.Jacobgen.generate(Jacobgen.java:146)
        at com.jacob.jacobgen.Jacobgen.main(Jacobgen.java:544)
```

We use [JacobGen](http://sourceforge.net/projects/jacob-project) to generate a Java-COM bridge. It’s a convoluted setup: a C# library is exported to COM, then a bridge is generated to use it from Java. Some legacy applications still use this and while it works, I find it a bit too thick. I recommend implementing whatever you have in C# in Java and using [JNA](https://github.com/twall/jna) if you need to invoke native functions. While that’s nice in theory, we still need to fix the build.

I found the error strange, since JacobGen carries a 32-bit and a 64-bit native DLL and one would think that that intended to "just work" on a 64-bit system. This is how we call JacobGen:

{% highlight bat %}
@echo off
setlocal

set JRE=%JAVA_HOME%\bin\java.exe
set JACOBGEN_HOME=%~dp0

set CLASSPATH=%JACOBGEN_HOME%jacobgen.jar;%JACOBGEN_HOME%lib\viztool.jar;%JACOBGEN_HOME%lib\samskivert.jar

set PATH=%JACOBGEN_HOME%\%PROCESSOR_ARCHITECTURE%;%PATH%

"%JRE%" -Xint com.jacob.jacobgen.Jacobgen %1 %2 %3 %4 %5
endlocal
{% endhighlight %}

This looks perfectly correct – note that path set to `%PROCESSOR_ARCHITECTURE%`. I ran the batch file manually and the build succeeded without any changes!

The problem turned out to be in MSBuild, where 32-bit MSBuild re-defines `PROCESSOR_ARCHITECTURE` as `x86` ([helpful post](http://abstractcode.com/abstractblog/archive/2009/07/03/171.aspx)). Another variable, `PROCESSOR_ARCHITEW6432` is available on 64-bit systems and is set to `AMD64` in my setup. To fix the problem I added a couple of lines to Jacobgen.bat.

{% highlight bat %}
if NOT "%PROCESSOR_ARCHITEW6432%"=="" (
  set PROCESSOR_ARCHITECTURE=%PROCESSOR_ARCHITEW6432%
)
{% endhighlight %}
