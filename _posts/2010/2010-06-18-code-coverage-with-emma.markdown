---
layout: post
title: "Code Coverage with EMMA"
redirect_from: "/code-coverage-with-emma"
date: 2010-06-18 12:24:02
tags: [emma, waffle, testing, java]
comments: true
---
![image]({{ site.url }}/images/posts/2010/2010-06-18-code-coverage-with-emma/image%5b9%5d.jpg)

I’ve written an unusually high number of unit tests for the Java portion of [Waffle](https://github.com/dblock/waffle/), mostly because the project became popular really fast with all those Java people trying to do Windows authentication. Some have succeeded and some filed several rather complicated bug reports that dealt with concurrency, sessions across HTTP requests, etc. It all needed to be unit-tested in order to make industrial-grade software.

If you asked me yesterday, I would have said that Waffle unit tests cover 99% of the code. But Emma says otherwise, and it’s probably right.

#### Running Emma with JUnit

It took me half an hour to integrate Emma. Pretty easy. You should do it too.

I downloaded Emma from [http://emma.sourceforge.net](http://emma.sourceforge.net) and added it to ThirdParty/emma. What I want next is a _cover_ target that can execute all unit tests with code coverage. We’re doing this in ANT with JUnit.

_Define Emma JARs Location and ClassPath_

```xml
<property name="emma.dir" value="${thirdparty.dir}/emma/lib" />
<path id="emma.classpath" >
  <fileset dir="${thirdparty.dir}/emma/lib">
    <include name="emma.jar" />
    <include name="emma_ant.jar" />
  </fileset>
</path>
```

_Instrument Files_

I went the route of not changing my build tasks and instrumenting the .class files already built. Then I swap in those files with the instrumented ones. Note that Emma only generates .class files for instrumentable classes – those not containing debugging information, interface definitions and such aren’t included.

```xml
<target name="instrument">
  <echo message="Instrumenting ${waffle.lib}" />
  <path id="build.classpath">
    <pathelement path="${waffle.lib}"/>
  </path>
  <emma>
    <instr instrpathref="build.classpath" destdir="${waffle.cover}/lib"
              metadatafile="${waffle.cover}/metadata.emma" merge="true" />
  </emma>
  <copy todir="${waffle.lib}">
    <fileset dir="${waffle.cover}/lib" includes="**/*" />
  </copy>
</target>
```

_Running Tests_

The tests are run the same way as before, but we need to tell Emma where to write its output.

```xml
<junit ...
  <jvmarg value="-Demma.coverage.out.file=${waffle.cover}/coverage.emma" />
</junit>
```

_Generating an EMMA Report_

Finally, we want to get a nice HTML document that summarizes coverage.

```xml
<target name="cover-report">
    <emma>
        <report sourcepath="${waffle.src}">
            <fileset dir="${waffle.cover}">
                <include name="*.emma" />
            </fileset>
            <html outfile="${waffle.cover}/coverage.html" />
        </report>
    </emma>
</target>
```
Here’s an output.

![image]({{ site.url }}/images/posts/2010/2010-06-18-code-coverage-with-emma/image%5b10%5d.jpg)

I see a lot of red. Emma doesn’t think I am doing such a great job after-all.

#### Links

- [EMMA on SourceForge](http://emma.sourceforge.net/)

