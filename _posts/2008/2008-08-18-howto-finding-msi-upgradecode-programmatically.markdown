---
layout: post
title: "Finding MSI UpgradeCode programmatically"
redirect_from: "/howto-finding-msi-upgradecode-programmatically/"
date: 2008-08-18 19:15:00
tags: [msi]
comments: true
dblog_post_id: 8
---
It's not hard, but rather frustrating to find.

{% highlight autoit %}
Set installer = CreateObject("WindowsInstaller.Installer")
On Error Resume Next
For Each prod In installer.ProductsEx("", "", 7)
   sLocalPkg = prod.InstallProperty("LocalPackage")
   set oDB = installer.OpenDataBase(sLocalPkg, 0)
   sQuery = "SELECT `Value` FROM `Property` WHERE `Property` = 'UpgradeCode'"
   Set oView = oDB.OpenView(sQuery)
   oView.Execute
   Set oRecord = oView.Fetch
   If Not (oRecord is Nothing) Then
    sUpgradeCode = oRecord.StringData(1)
    WScript.Echo sUpgradeCode & ": " & prod.InstallProperty("ProductName") & " - " & prod.ProductCode
   End If
Next
{% endhighlight %}
