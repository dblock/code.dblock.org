---
layout: post
title: "Waffle w/ Tomcat 5.5, 6 and 7"
redirect_from: "/waffle-w-tomcat-55-6-and-7"
date: 2010-11-02 23:19:31
tags: [tomcat, spring, waffle]
comments: true
---
I recently went through an exercise of trying to run Waffle Tomcat valves with various versions of Tomcat. Valves are those annoying types of filters that depend directly on the web server implementation, so a substantial amount of code changes were needed each time. I couldn’t get a single package that would work for all versions in a clean maintainable way.

Frankly, I think valves are evil. Nevertheless it’s often impractical to make a jump from a valve to a pure servlet filter, because it forces you to separate authentication and authorization. So for Waffle 1.4 we’re going to have working forks with valves for all versions of Tomcat.

We have the same problem with spring-security. Trunk supports 3.x. There’s now also a fork for spring-security 2.x.

If you’re selecting amongst the filters to do Windows single sign-on on a new system, by all means please use a servlet filter.

