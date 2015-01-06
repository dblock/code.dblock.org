---
layout: post
title: "Compass: Invalid US-ASCII character 'xE2'"
redirect_from: "/compass-invalid-us-ascii-character-xe2/"
date: 2011-06-09 21:13:48
tags: [rails, ruby]
comments: true
---
This one drove me crazy for a while. Compass would fail with “Syntax error: Invalid US-ASCII character "\xE2". So I checked the files, found nothing changed since last time and spent a while googling. Finally found the culprit, explained [here](https://github.com/haml/haml/issues/269).

The easiest workaround is to set `LANG=en_US.UTF-8` in the system’s environment.
