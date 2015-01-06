---
layout: post
title: "AppSecInc. MSI Extensions Open Sourced"
redirect_from: "/appsecinc-msi-extensions-open-sourced/"
date: 2009-11-20 18:15:00
tags: [codeproject, msi, wix]
comments: true
---
I am pleased to announce the open-sourcing of [AppSecInc. MSI Extensions](https://github.com/dblock/msiext).

AppSecInc. MSI Extensions is a collection of MSI custom actions and WIX extensions that extend Windows installer, originally developed by [Application Security Inc.](http://www.appsecinc.com). for a large enterprise product, and now open-sourced under the Eclipse Public License. The project grew incrementally implementing everything that wix didn't have out of the box. Code is fully unit-tested.

#### Wix Extensions

- System Tools: deals with copying, moving, deleting files out of sequence, compare versions, execute commands, process template files, copy registry keys, etc.
- Java Tools: deals with jar and unjar.
- Data Sources: deals with generic ODBC and specific MSAccess and MSSQL databases, SQL files, etc.
- User Privileges: deals with local users and groups.
- Common UI: dialogs for installing Windows services and databases with credentials.

#### Immediate Custom Actions

- Manipulating files, folders, registry, services.
- String template and regex processing.
- Active Directory functions.
- ODBC and DMO functions.
- Local users, groups, security and privileges.
- Encryption, decryption, signing.
- Xml file manipulation.
- TcpIp functions.

#### Additional Features

- Supports impersonation in all custom actions.

I plan to maintain the open-source project and encourage you to contribute.
