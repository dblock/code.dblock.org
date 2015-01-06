---
layout: post
title: "Unit Testing MSI Custom Actions"
redirect_from: "/unit-testing-msi-custom-actions"
date: 2008-08-18 03:00:00
tags: [wix]
comments: true
---
### Prologue

I've been doing a lot of [Wix](http://wixtoolset.org/) lately. Actually for the past six years or so: I was a believer since my last couple of years at [The Evil Empire](http://www.microsoft.com). [Wix](http://wixtoolset.org/) is easy, but custom actions aren't so much. Unit testing custom actions is the topic of this post.

My team at my real job has been rebuilding deployment and installation for a rather large application and had to write three large installers and many custom actions that don't exist in the wix toolset. We started a long time ago, all the work is in C++. And since many prior fiascos have left me a believer in agile practices, I wanted to figure out how to unit test these many custom actions.

A coworker wrote a shim that implemented some MSI functions. With clever conditional compilation we built unit tests for all simple CAs. But once we started writing more complex deferred custom actions coffee conversations at Casa Cupcake turned into providing a SQL engine in the shim vs. parsing SQL. It smelled too complex, cumbersome and sounded like a lot of work, which would have taken away from coffee time!

After some research I found a much better model: creating a hosting a real MSI, which I will demonstrate in this post.

### Creating an MSI

Manufacturing an empty MSI is easy if you read MSDN documentation.

```c
MSIHANDLE hdb = NULL;
```

The result is an empty MSI, but if you try to open it with [Orca](http://msdn.microsoft.com/en-us/library/aa370557.aspx), it will fail without explanation. It seems like you must set at least three properties in order to make this a workable MSI:

- [PID_REVNUMBER](http://msdn.microsoft.com/en-us/library/aa372870(VS.85).aspx): For an installation package, the Revision Number Summary property contains the [package code](http://msdn.microsoft.com/en-us/library/aa370946(VS.85).aspx) for the installer package.
- [PID_WORDCOUNT](http://msdn.microsoft.com/en-us/library/aa372870(VS.85).aspx): In the summary information of an installation package, the Word Count Summary property indicates the type of source file image.
- [PID_PAGECOUNT](http://msdn.microsoft.com/en-us/library/aa370570(VS.85).aspx): The Page Count Summary property contains the minimum installer version required by the installation package.

You have to get the summary information for the number of summary info items that you're going to set, set the properties, persist them to disk and commit the MSI to disk.

```c
MSIHANDLE hsummary = NULL;
MsiGetSummaryInformation(hdb, NULL, 7, & hsummary);
MsiSummaryInfoSetPropertyA(hsummary, PID_REVNUMBER, VT_LPSTR, 0, NULL, "{00000000-0000-0000-0000-000000000000}");
MsiSummaryInfoSetPropertyA(hsummary, PID_SUBJECT, VT_LPSTR, 0, NULL, "Test MSI");
MsiSummaryInfoSetPropertyA(hsummary, PID_TITLE, VT_LPSTR, 0, NULL, "Test MSI");
MsiSummaryInfoSetPropertyA(hsummary, PID_AUTHOR, VT_LPSTR, 0, NULL, "dB.");
MsiSummaryInfoSetPropertyA(hsummary, PID_TEMPLATE, VT_LPSTR, 0, NULL, ";1033");
MsiSummaryInfoSetProperty(hsummary, PID_PAGECOUNT, VT_I4, 100, NULL, NULL);
MsiSummaryInfoSetProperty(hsummary, PID_WORDCOUNT, VT_I4, 100, NULL, NULL);
// persist the summary in the stream
MsiSummaryInfoPersist(hsummary);
MsiCloseHandle(hsummary);
// commit changes to disk
MsiDatabaseCommit(hdb);
```

You'll be able to open the MSI with [Orca](http://msdn.microsoft.com/en-us/library/aa370557.aspx) now.

### Opening an MSI Package

You can open an MSI package now and use it as if it were part on an installation. If you have just created it, MsiOpenPackage takes a handle in the format of #id. Otherwise you can just specify the full file path to the MSI package.

```c
// reopen as an MSI package, this function accepts opened handles in form of #handle
wchar_t handle[12] = { 0 };
_snwprintf(handle, ARRAYSIZE(handle), L"#%d", (UINT) hdb);
MSIHANDLE hproduct = NULL;
MsiOpenPackage(handle, & hproduct);
```

### Calling a Custom Action

There're two ways of calling the custom. You can import the CustomAction table that contains the name and reference to your CA, subject of another future post. This works for all types of custom actions, but it can get a little involved since you have to import several tables: CustomAction and Binary. For simpler C++ custom actions, simply fetch the CA's entry point and pass the MSI handle obtained from MsiOpenPackage.

```c
// load CustomAction.dll
HMODULE hca = LoadLibrary(L"CustomAction.dll");
// find the address of SetProperty1CustomAction
typedef int (__stdcall * LPCUSTOMACTION) (MSIHANDLE h);
LPCUSTOMACTION lpca = (LPCUSTOMACTION) GetProcAddress(hca, "SetProperty1CustomAction");
// call the custom action
lpca(hproduct);
```

### Unit Testing a Custom Action

You can now integrate this method with [CppUnit](http://cppunit.sourceforge.net/) or any other unit-testing framework. Just call regular MSI functions. We've managed almost 100% code-coverage today for two dozen CAs. We still don't know how to properly invoke deferred custom actions, but it doesn't prevent unit-testing.

### Source Code

I wrote a complete demo: a custom action and a small test that calls it, which you can find on [Github](https://github.com/dblock/codeproject/tree/master/UnitTestingCustomActions/Source).

