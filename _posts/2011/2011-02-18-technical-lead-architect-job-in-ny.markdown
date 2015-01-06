---
layout: post
title: "Technical Lead / Architect Job in NY"
redirect_from: "/technical-lead-architect-job-in-ny/"
date: 2011-02-18 01:07:18
tags: [shatter, appsecinc, gwt, jobs, architecture, security, java, .net, people]
comments: true
---
![architect]({{ site.url }}/images/posts/2011/2011-02-18-technical-lead-architect-job-in-ny/architect_3.jpg)

AppSecInc has an [opening](http://www.appsecinc.com/aboutus/careers/Technical-Lead-Architect.shtml) for a technical lead slash software architect. This is a pretty cool job for someone who has a pragmatic approach to software development, enjoys complex architectural software problems and wants to work with a whole range of Enterprise-y technologies with some awesome people located right here in New York City. This is your chance to put your hands into something very big and very expensive and learn a lot about what kind of software powers the very large businesses out there. Plus you get to meet a few real white hat hackers and talk about it with your friends, go visit some facilities that don’t exist on maps and talk to people who have multiple passports and whose actual name is unknown :)

The main responsibility is to be the primary architect on the flagship software, [DbProtect](http://www.appsecinc.com/products/dbprotect/index.shtml), which won an award at [RSA](http://www.rsaconference.com/2011/usa/) yesterday. DbProtect finds database security vulnerabilities, analyzes database traffic live and digs through user rights and roles in those databases. Out come compliance reports that are the headache of every large and small organization.

DbProtect is powered by the best knowledgebase out there produced by [TeamSHATTER](http://www.teamshatter.com/), some of the smartest people in the room. It’s shrink-wrapped software, AppSecInc doesn’t run it for it’s clients. It’s a suite of enterprise services (written in Java), managed by a central console (written in [gwt](http://code.google.com/webtoolkit/)). There’re agents which collect massive amounts of data (largest deployments in production have something like 500 scanners and sensors distributed worldwide), controlled by a workflow system (based on [saraswati](http://code.google.com/p/sarasvati/)). Services bring this data into a warehouse that runs on SQL Server and a reporting system built on [IBM Cognos](http://www-01.ibm.com/software/data/cognos/) produces output off that. Agents are written in C++ (some are cross-platform) and C# (WCF), while everything else is written in Java. There’s a lot more to this and some real hard work has been done to make this enterprise-grade. Now is the time for an architect to own the next steps, including a proper SDK and the next level of scale (yes, people want to run thousands of scanners and sensors and store 7 years worth of data).

Job description and how to apply: [http://www.appsecinc.com/aboutus/careers/Technical-Lead-Architect.shtml](http://www.appsecinc.com/aboutus/careers/Technical-Lead-Architect.shtml "http://www.appsecinc.com/aboutus/careers/Technical-Lead-Architect.shtml"). More jobs [here](http://www.appsecinc.com/aboutus/careers/positions.shtml).

