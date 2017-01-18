---
layout: post
title: "The Jenkins AnsiColor Plugin You’ve All Been Waiting For"
redirect_from: "/the-jenkins-ansicolor-plugin-youve-all-been-waiting-for/"
date: 2011-09-04 12:28:27
tags: [jenkins, ruby, open source, build]
comments: true
dblog_post_id: 257
---
I’ve released [AnsiColor](https://wiki.jenkins-ci.org/display/JENKINS/AnsiColor+Plugin), a Jenkins plugin you’ve all been waiting for.

How long have you been waiting? Years. This question seems to popup regularly on the users list, [2009](http://jenkins.361315.n4.nabble.com/How-i-can-use-colors-in-output-td955080.html), [2011](http://groups.google.com/group/jenkinsci-users/browse_frm/thread/6c06f6c871353a92/df7fd56ecae7574a?lnk=gst&q=color+console#df7fd56ecae7574a) and again [recently](http://groups.google.com/group/jenkinsci-users/browse_frm/thread/aea4546a612f4bc4/caeca86316136e91?lnk=gst&q=color+console#caeca86316136e91). It looks like billions of Jenkins users are suffering from lack of color in console output. We’ve taken color for granted in our favorite shells and upgrading to Jenkins looks like a major step back. The absence of ANSI color support is particularly hurting the Ruby community and is likely the break-it or make-it barrier for the adoption of Jenkins by the latter. It’s well known that Ruby developers are a bunch of happy people and a world without color is a sad, sad world.

#### Install

![]({{ site.url }}/images/posts/2011/2011-09-04-the-jenkins-ansicolor-plugin-youve-all-been-waiting-for/image_5.jpg)

#### Enable in Your Build

![]({{ site.url }}/images/posts/2011/2011-09-04-the-jenkins-ansicolor-plugin-youve-all-been-waiting-for/image_13.jpg)

#### See Color

![]({{ site.url }}/images/posts/2011/2011-09-04-the-jenkins-ansicolor-plugin-youve-all-been-waiting-for/image_23.jpg)

#### Links

- Github: [https://github.com/dblock/jenkins-ansicolor-plugin](https://github.com/dblock/jenkins-ansicolor-plugin)
- Plugin: [https://wiki.jenkins-ci.org/display/JENKINS/AnsiColor+Plugin](https://wiki.jenkins-ci.org/display/JENKINS/AnsiColor+Plugin)
- This plugin was made possible by the JANSI parser: [https://github.com/fusesource/jansi/](https://github.com/fusesource/jansi/)

