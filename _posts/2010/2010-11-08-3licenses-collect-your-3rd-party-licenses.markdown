---
layout: post
title: "3Licenses: Collect Your 3rd Party Licenses"
redirect_from: "/3licenses-collect-your-3rd-party-licenses/"
date: 2010-11-08 14:25:14
tags: [3licenses, ant, open source, java, build]
comments: true
dblog_post_id: 141
---

![thirdparty]({{ site.url }}/images/posts/2010/2010-11-08-3licenses-collect-your-3rd-party-licenses/thirdparty_4.jpg)

I am pleased to announce the open-source release of [3Licenses](https://github.com/dblock/3licenses), an [AppSecInc](http://www.appsecinc.com)-sponsored project, pronounced "free licenses".

The overwhelming majority of 3rd party licenses require the application that uses them to reproduce the license verbatim in an artifact that is installed with the application itself. For instance, the BSD license states the following.

> _"Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution."_

Are you currently copying individual _license.txt_ files "by hand" or are you including license text in your documentation with copy/paste? You can do much better with 3Licenses.

- Integrates with ANT and Subversion.
- Detects common license file names.
- Automatically detects various license types.
- Uses svn:externals to derive thirdparty product versions.
- Outputs thirdparty license information into XML output.
- Combines multiple thirdparty license outputs into one.
- Transforms thirdparty license information into HTML with XSLT.
- Highlights missing licenses.
- Allows overriding of product names, versions and license types.
- **Coming soon** : MSBuild Support.

Here's what 3Licenses can produce.

![demo2]({{ site.url }}/images/posts/2010/2010-11-08-3licenses-collect-your-3rd-party-licenses/demo2_4.jpg)

