---
layout: post
title: "AppSecInc. Community MSI Extensions 1.2 Released"
redirect_from: "/appsecinc-community-msi-extensions-12-released/"
date: 2010-11-09 07:56:03
tags: [appsecinc, open source, msi, wix]
comments: true
---
![msiext]({{ site.url }}/images/posts/2010/2010-11-09-appsecinc-community-msi-extensions-12-released/msiext_3.jpg)

We take our custom actions seriously.

This is the second open-source release of our [community MSI custom actions and WIX extensions](https://github.com/dblock/msiext/). Here’re some highlights.

- Added support for SQL error commands and sqlvariant in all ODBC and SQLServer custom actions and extensions.
- Corrected a number of issues with SQL Server 2000 in ODBC custom actions and extensions.
- Added `Win32_GetSpecialFolderPath`, `GenerateRandomString`, `Win32_GenerateGuidString`, `Win32_IsValidGuid`, `Win32_ReadFile`, `Win32_WriteFile`, `Service_Exists`, `String_LTrim` and `String_RTrim` custom actions.
- Added UTF-8 support for template custom actions.

This project builds on years of experience authoring C++ custom actions and Wix extensions for our flagship enterprise product. All custom actions and extensions are unit-tested and production quality.
