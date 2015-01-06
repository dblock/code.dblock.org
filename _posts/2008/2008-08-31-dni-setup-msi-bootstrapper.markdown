---
layout: post
title: "DNI: setup (msi) bootstrapper"
redirect_from: "/dni-setup-msi-bootstrapper"
date: 2008-08-31 22:45:00
tags: [msi]
comments: true
---
I've been heavily contributing to a project called DNI or dotNetInstaller in the past several months. DNI is a setup bootstrapper that basically chains multiple MSIs together and allows to conditionally install pre-requisites.

The [Wix](http://wixtoolset.org/) mailing list is full of conversations about a bootstrapper and it looks like someone at Microsoft is dedicating himself full time to making this happen. The timeframe is 2009 though and we must ship software in the meantime. We have decided to find a bootstrapper technology that is "good enough" and settled on DNI. My team has contributed several major features to the upcoming version 1.4.

- Support for deployment on 64-bit platforms
- Embedding all dependencies into a single Setup.exe
- Embedding OS resource info; branding setup with company and version information

There're two dozen other features contributed by developers around the world, notably silent install. This made DNI a very well featured boostrapper with some rich capabilities.

DNI's design is not the best and a lot of things could be done better. But it's a project born of rather practical needs and works well. If you're looking for a bootstrapper right now, check it out.

- [Original CodeProject Article](http://www.codeproject.com/KB/install/dotNetInstaller.aspx)
- [dotNetInstaller on Github](https://github.com/dblock/dotnetinstaller)

