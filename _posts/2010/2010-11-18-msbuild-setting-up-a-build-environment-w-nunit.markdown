---
layout: post
title: "MSBuild: Setting Up a Build Environment w/ NUnit"
redirect_from: "/msbuild-setting-up-a-build-environment-w-nunit/"
date: 2010-11-18 14:25:27
tags: [nunit, testing, .net, build, msbuild]
comments: true
---
![crane]({{ site.url }}/images/posts/2010/2010-11-18-msbuild-setting-up-a-build-environment-w-nunit/crane_5.jpg)

Here’re a few helpful tricks for setting up a build environment, finding the most recent version of [NUnit](http://www.nunit.org/) and using it with [MSBuild Community Tasks](http://msbuildtasks.tigris.org/) programmatically (assuming you’re not checking in NUnit alongside your source code, which you probably should).

We wrap build into a _build.cmd_ that sets up a basic build environment. This avoids users the headache of launching anything except a command prompt upfront. We want a certain version of Visual Studio, targeting  a certain version of .NET Framework and NUnit. This is a typical project setup.

#### Finding Program Files

The first difficulty is to figure out where 32-bit Program Files is. On 32-bit machines this is typically `C:\Program Files` and on 64-bit machines, `C:\Program Files (x86)`. The `ProgramFiles` environment variable points to the native Program Files, but we want the 32-bit one.

```bat
set ProgramFilesDir=%ProgramFiles%
if NOT "%ProgramFiles(x86)%"=="" set ProgramFilesDir=%ProgramFiles(x86)%
```

#### Visual Studio

This one is simple. We want to call _vcvarsall.bat_ for a given version of Visual Studio. This sets up the Visual Studio build environment.

```bat
set VisualStudioCmd=%ProgramFilesDir%\Microsoft Visual Studio 9.0\VC\vcvarsall.bat
if EXIST "%VisualStudioCmd%" call "%VisualStudioCmd%"
```

#### .NET Framework

We can simply define the version of .NET Framework and it’s path. In this case we want 3.5, but we could also specify any version available in `%SystemRoot%\Microsoft.NET\Framework`.

```bat
set FrameworkVersion=v3.5
set FrameworkDir=%SystemRoot%\Microsoft.NET\Framework
```

#### NUnit

NUnit is a bit trickier since we don’t know the version of NUnit installed on this machine. Plus NUnit project has been doing some moving files around. We will define NUnitBinDir and we will also check whether we found it.

```bat
for /D %%n in ( "%ProgramFilesDir%\NUnit*" ) do (
  set NUnitDir=%%~n
)

if EXIST "%NUnitDir%\bin" set NUnitBinDir=%NUnitDir%\bin
if EXIST "%NUnitDir%\bin\net-2.0" set NUnitBinDir=%NUnitDir%\bin\net-2.0

if NOT EXIST "%NUnitBinDir%" echo Missing NUnit, expected in %NUnitDir%
if NOT EXIST "%NUnitBinDir%" exit /b -1
```

`NUnitBinDir` can be reused with MSBuild Community Tasks in an MSBuild .proj file (in our case we want 32-bit NUnit).

```xml
<NUnit Assemblies="@(UnitTestAssemblies)" ToolPath="$(NUnitBinDir)" Force32Bit="true" />
```

#### Building

The final step is to setup PATH and shell to MSBuild proper.

```bat
PATH=%FrameworkDir%\%FrameworkVersion%;%NUnitDir%;%JAVA_HOME%\bin;%PATH%

msbuild.exe Project.proj /t:%\*
if NOT %ERRORLEVEL%==0 exit /b %ERRORLEVEL%
```

#### Examples

I tend to use a stock _build.cmd_ in many projects and it has simplified our life quite a bit. Here’s a [complete one](https://github.com/dblock/resourcelib/blob/master/build.cmd). You can type `build all /p:Configuration=Release` for example to build the project release configuration.
