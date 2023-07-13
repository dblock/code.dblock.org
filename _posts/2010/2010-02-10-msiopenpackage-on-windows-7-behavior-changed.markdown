---
layout: post
title: "MSIOpenPackage on Windows 7: behavior changed"
redirect_from: "/msiopenpackage-on-windows-7-behavior-changed/"
date: 2010-02-10 22:47:44
tags: [testing, msi, win32]
comments: true
dblog_post_id: 81
---
I was very happy upgrading to Windows 7. Virtually everything worked. All kinds of source code that I am writing compiles and runs without issues. It’s only a week later that I had to touch the [AppSecInc. Community MSI extensions](https://github.com/dblock/msiext) and discovered that most unit tests are failing. I talked about [unit testing custom actions earlier](/unit-testing-msi-custom-actions). I finally got to the bottom of it.

On Windows 7 the behavior of `MSIOpenPackage` has changed. We use it to run unit tests by creating a database (`MSICreateDatabase`) and calling `MSIOpenPackage` to get a working handle. On Windows 7 code that worked earlier always returns _0x80070645: This action is only valid for products that are currently installed_. This is one obscure error code! Why do I need an installed product to open an MSI package?

Microsoft.public.platformsdk.msi was helpful [[thread](https://groups.google.com/group/microsoft.public.platformsdk.msi/browse_thread/thread/5c3ffc48f1ecda30#)]. For `MsiOpenPackage` to succeed you now have to have a `Property` table with a populated `ProductCode` value in the MSI file itself. MsiExt shim code now looks like this. The two `Execute` statements are new. This incidentally demonstrates what fields you need in the MSI summary to get a valid MSI.

{% highlight autoit %}
_database.Create(_filename);

MsiDatabaseSummaryEntry summary_entries[] =
{
    { PID_TITLE, VT_LPSTR, L"MSI Shim Database" },
    { PID_SUBJECT, VT_LPSTR, L"MSI Shim Database" },
    { PID_AUTHOR, VT_LPSTR, L"AppSecInc." },
    { PID_TEMPLATE, VT_LPSTR, ";1033" },
    { PID_REVNUMBER, VT_LPSTR, "{00869AA3-A32E-4398-89B2-5C5DC7328C7C}" },
    { PID_PAGECOUNT, VT_I4, 100 },
    { PID_WORDCOUNT, VT_I4, 100 },
};

// A valid MSI must have a summary for MsiOpenPackage to succeed
_database.SetSummary(summary_entries, ARRAYSIZE(summary_entries));

// Windows 7 requires a property table with a ProductCode value
_database.Execute(L"CREATE TABLE `Property` (`Property` CHAR(72) NOT NULL, `Value` CHAR(0) NOT NULL LOCALIZABLE PRIMARY KEY `Property`)");
_database.Execute(L"INSERT INTO `Property` (`Property`, `Value`) VALUES ('ProductCode', '{07F7FB1B-992E-4a2d-805C-C803C98CFC42}')");

_database.Commit();
_database.Close();

Open(_filename);
{% endhighlight %}

Hope this saves you hours of fruitless debugging.

Maybe [Raymond](https://blogs.msdn.com/oldnewthing/) can answer why this change in behavior in Windows 7?
