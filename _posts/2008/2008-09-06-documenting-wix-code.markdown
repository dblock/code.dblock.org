---
layout: post
title: "Documenting WIX Code"
redirect_from: "/documenting-wix-code"
date: 2008-09-06 21:15:00
tags: [wix]
comments: true
---
Two sprints into working on a large deployment project I had already created two big installers under which the .wxs and .wxi files were multiplying only slower than components and features in them. For instance, there're 30 .wxi files that compose a single enterprise component installer accounting for 8 merge modules.

I knew from day one that I'll need to document all this, so I started writing documentation at the same time as the code. Unfortunately the amount of change in the source code was discouraging - I constantly had to go back and edit documentation trying to figure out everything I had changed. This wasn't going to scale. I needed a different solution.

**_Wix files are XML and we treat them as source code. They should be documented as source code!_**

We use [Doxygen](http://www.doxygen.org) to generate source code documentation. Doxygen supports filters: command line tools invoked for every file. It looks like all I need is a preprocessor that can transform a .wxs file into doxygen documentation!

A .wixproj project consists of .wxs, .wxi and .wxl files. I chose to take a .wxs file as input, which may have a Product or Merge XML node representing a product or a merge module respectively. Each .wxs file may contain a number of defines which need to be expanded. There may be includes that reference other files that might contain more wix xml, other includes, etc.

Here's an example:

```xml
<Product Id="*" Name="Test" Language="1033"
 Version="$(var.ProductVersion)"
 UpgradeCode="b6012b2a-d280-40bc-a236-6fdce2c9b84f">
<?define ProductVersion='5.5.0.0' ?>
<?include ..\Common\Properties.wxi ?>
```

To parse this, I [wrote a quick and dirty recursive preprocessor in C#](https://github.com/dblock/codeproject/blob/master/DoxygenFilters/WixDoxyFilter/WixPreprocessor.cs) that resolves all includes, expands defines and finally processes the result into a doxygen format. I wish wix had a preprocessor built-in just like the C++ preprocessor to avoid doing all that work. At least manipulating XML in .NET is straightforward and the Regex support is rich.

The most important feature of the preprocessor is to include comments above products, components, merge modules and features. Thus you can include true doxygen text which will appear in the final documentation.

```xml
<!-- This is a test MSI to demonstrate major upgrade. -->
<Product Id="$(var.ProductCode)" Name="Upgrade Test" Language="1033" ...="">
```

Here's a simple wix installer.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?define ProductVersion="3.0.0" ?>
<?define UpgradeCode="{3485E6A2-A1F3-4329-8BB5-ED8FFCF283D4}"?>
<?define ProductCode="*"?>
<?define PackageCode="{????????-????-????-????-????????????}"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
<!-- This is a test MSI to demonstrate major upgrade. -->
 <Product Id="$(var.ProductCode)" Name="Upgrade Test" Language="1033"
  Version="$(var.ProductVersion)" Codepage="1252" Manufacturer="$(var.Manufacturer)"
  UpgradeCode="$(var.UpgradeCode)">
  <Package Id="$(var.PackageCode)" Description="PackageDescription" Comments="Comments"
   Manufacturer="$(var.Manufacturer)" ...="" Keywords="Installer,MSI,Database" />
    <Directory Id="TARGETDIR" Name="SourceDir">
    <Directory Id="ProgramFilesFolder">
    <Directory Id="INSTALLLOCATION" Name="Upgrade Test">
    <!-- A test product component. -->
    <Component Id="ProductComponent" Guid="a847491a-6a4e-44ea-b54f-efc6126dd484">
     <File Id="UpgradeTest_wxs" Name="UpgradeTest.wxs" src="UpgradeTest.wxs" temp_src="UpgradeTest.wxs" />
    </Component>
   </Directory>
  </Directory>
 </Directory>
 <!-- A test product feature. -->
 <Feature Id="ProductFeature" Title="New Feature" Level="1">
  <ComponentRef Id="ProductComponent" />
  </Feature>
 </Product>
</Wix>
```

And the output that WixDoxyFilter produces.

```doxygen
/*! \page upgrade_test_wxs Upgrade Test
PackageDescription
 This is a test MSI to demonstrate major upgrade.
\section upgrade_test_wxs_conditions Prerequisites and Conditions
\section upgrade_test_wxs_features Features
\subsection upgrade_test_wxs_features_productfeature New Feature
 A test product feature.
\li \ref upgrade_test_wxs_components_productcomponent
\section upgrade_test_wxs_components Components
\subsection upgrade_test_wxs_components_productcomponent ProductComponent
 A test product component.
Component guid: a847491a-6a4e-44ea-b54f-efc6126dd484
\section upgrade_test_wxs_merges Merge Modules
*/
```

The last step is to tell Doxygen's Doxyfile to process .wxs files.

```doxyfile
FILE_PATTERNS = *.wxs *.xsd
FILTER_PATTERNS = *.wxs=tools\filters\WixDoxyFilter.exe \
 *.xsd=tools\filters\WixExtXsdDoxyFilter.exe
```

The result is exactly what I wanted: self-documenting products, merge modules, components and features, plus the ability to put relevant doxygen-formatted content into comments.

I also wrote a preprocessor for wix extension XSDs, source code [here](https://github.com/dblock/codeproject/tree/master/DoxygenFilters).
