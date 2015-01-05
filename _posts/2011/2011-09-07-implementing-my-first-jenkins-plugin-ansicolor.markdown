---
layout: post
title: "Implementing My First Jenkins Plugin: AnsiColor"
redirect_from: "/implementing-my-first-jenkins-plugin-ansicolor"
date: 2011-09-07 12:07:05
tags: [jenkins, java]
comments: true
---
![jenkins]({{ site.url }}/images/posts/2011/2011-09-07-implementing-my-first-jenkins-plugin-ansicolor/jenkins%5b3%5d.jpg)

I installed Jenkins last week for the very first time. A couple of days later I was able to publish my first plugin, called [AnsiColor](https://wiki.jenkins-ci.org/display/JENKINS/AnsiColor+Plugin), which colorizes ANSI output. It’s the [plugin you’ve all been waiting for](http://code.dblock.org/the-jenkins-ansicolor-plugin-youve-all-been-waiting-for).

The [Jenkins plugin tutorial](https://wiki.jenkins-ci.org/display/JENKINS/Plugin+tutorial) is quite good, I recommend you just follow it. It has a maven-based cookbook to generate a new project. But if you’re like me, you’ll reconstruct a plugin from scratch (and possibly trade time for a better understanding). I’ll just mention a few things that could have been helpful to me.

#### Basics

A plugin extends _hudson.Plugin_. This class isn’t even necessary, but it’s a good opportunity to setup a logger that’s going to tell us that the plugin is actually being loaded. Whether you’re testing the plugin locally or running a production instance of Jenkins, this will come handy.

```java
public class PluginImpl extends Plugin {
  private final static Logger LOG = Logger.getLogger(PluginImpl.class.getName());

  public void start() throws Exception {
    LOG.info("starting ansicolor plugin");
  }
}
```

#### Processing Build Output

Our goal is to process build output and insert HTML color markup. So the first task is to find a Jenkins extension point from [here](https://wiki.jenkins-ci.org/display/JENKINS/Extension+points) that exposes build log data. I found the very promising [ConsoleLogFilter](https://wiki.jenkins-ci.org/display/JENKINS/Extension+points#Extensionpoints-hudson.console.ConsoleLogFilter). A simple extension is marked with _@Extension _and I thought I was done.

```java
@Extension
public class AnsiColorConsoleLogFilter extends ConsoleLogFilter {

  @SuppressWarnings("unchecked")
  @Override
  public OutputStream decorateLogger(AbstractBuild build, OutputStream logger)
      throws IOException, InterruptedException {
    return new AnsiColorizer(logger, build.getCharset());
  }

}
```

What’s that _AnsiColorizer_? It’s a stream processing class that inherits from _hudson.console.LineTransformationOutputStream _that overrides a method called _eol_, called for each output line. It decorates our logger. Notice that the bytes passed into the _eol_ method are pre-allocated, hence the _len_ parameter. You get a lot more bytes than in the current line, but it’s garbage from previous output after _len_.

The following code will strip all ANSI markup.

```java
@Override
protected void eol(byte[] b, int len) throws IOException {
  String ansiEncodedString = new String(b, 0, len);
  AnsiString ansiString = new AnsiString(ansiEncodedString);
  String plainString = ansiString.getPlain().toString();
  byte[] plainBytes = plainString.getBytes();
  out.write(plainBytes, 0, plainBytes.length);
}
```

Pretty simple, right? Well, it only works if we want to remove stuff or add text and doesn’t work for HTML. Console output gets HTML-encoded as it passed through subsequent filtering, so inserting HTML, such as color, will end up encoded too. Sad face.

#### Console Notes

Jenkins has another extension point, [BuildWrapper](https://wiki.jenkins-ci.org/display/JENKINS/Extension+points#Extensionpoints-hudson.tasks.BuildWrapper). It will add an option to every build project to enable the decoration of the build logger to which we can attach a [ConsoleAnnotationDescriptor](https://wiki.jenkins-ci.org/display/JENKINS/Extension+points#Extensionpoints-hudson.console.ConsoleAnnotationDescriptor). All this is rather convoluted, but constructed with good intentions of being able to stream data. As a recent Rubyist I raised all of my eyebrows time-and-again – I forgot how much people love factories in Java. Anyway, that lets you insert _ConsoleNote_ elements before and after a line of log output. The note is HTML. But ANSI characters can be anywhere in the string, so how is this helpful?

Let's use the extra brain cells that didn’t die while sorting out wrappers, factories, decorators and annotators. Given a string, such as `Hello ]32mCruel Java World`, how do we make it display `"Hello <span style="color: green">Cruel Java World</span>` given that we can only prepend and append text? Like this.

```
Hello <span style="color: green">Cruel Java World</span>
<span style="display: none">Hello ]32mCruel Java World</span>
```

I know, it’s a total hack, but it works and nobody will complain.

```java
String colorizedData = colorize(this.data);
if (! colorizedData.contentEquals(this.data)) {
  text.addMarkup(charPos, colorizedData);
  text.addMarkup(charPos, charPos + text.length(), "<span style=\"display: none;\">", "</span>");
}
```

![ansicolor]({{ site.url }}/images/posts/2011/2011-09-07-implementing-my-first-jenkins-plugin-ansicolor/ansicolor%5b4%5d.jpg)

#### Source Code

Full plugin source code is [here on Github](https://github.com/dblock/jenkins-ansicolor-plugin).
