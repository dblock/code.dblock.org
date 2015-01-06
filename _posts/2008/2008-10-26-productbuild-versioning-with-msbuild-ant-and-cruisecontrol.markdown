---
layout: post
title: "Product/Build Versioning with MSBuild, ANT and CruiseControl"
redirect_from: "/productbuild-versioning-with-msbuild-ant-and-cruisecontrol"
date: 2008-10-26 13:30:00
tags: [build]
comments: true
---
![]({{ site.url }}/images/posts/2008/2008-10-26-productbuild-versioning-with-msbuild-ant-and-cruisecontrol/wheel.jpg)

_Versioning_ is probably the hottest area of reinventing a better wheel.

### Single Versioning Scheme

Do we really need a single versioning scheme? My answer is simple. Every company should strive towards unified processes. It makes people more interchangeable, avoids duplicate work and creates systems. Ultimately systems win, not individuals. A system can be derived from healthy competition of ideas and implementations, but once things are stable and everybody is entrenched in their ways, it is good to stir the pot, get people talking and standardize on one single method.

We have roughly 4 development teams, about ten subprojects with 7 versioning schemes. Trying to get everyone on a single one is a challenge and needs to be approached with care. I created a presentation entitled _ **"Product Versioning: or how management tells you to change something for no reason"** _and spent a lot of time convincing people not that my versioning scheme is the best, but that we need a single one. I've used the following arguments.

1. Sitting at any computer, including a customer site, we have hard time tracing back to the source code that has produced a build.
2. We have two builds with the same build number, which becomes very confusing when it comes to figuring out whether a customer has installed a patch.
3. There's only one test team, which has to context switch from product to product for their bug reporting processes.
4. There's only one development team, giving a developer the opportunity to work on another team represents a culture shock, which promotes people working on the same thing for too many years.
5. When creating a new project we waste a lot of time debating about versioning.

Finally, 7 versioning schemes across 4 development teams is best qualified in Russian as: "кто в лес, кто по дрова". Ceci explique cela.

### Requirements

It starts with conflicting _requirements _between various parts of the organization.

Engineering usually has conflicting requirements from product management and marketing. For example, on Windows the first three digits of the version matter for Windows installer and all the three parts must be numbers. But marketing likes versions like _2008.1_ or _Gold Edition_. Hence, _ **offer marketing the opportunity to set any version they like** _, one that has nothing to do with the engineering version. It's often as easy as adding text in the right places and managing it centrally.

Different engineers from various schools of thought usually have conflicting requirements. One of the managers who works for me believes that a build should be promoted to the test team and so a digit in the version must represent an auto-incremented number of builds promoted. Another manager thinks that the build number should be date-based, derived from the current year, month and day. The third manager agrees, but wants to use the Jewish calendar which creates more boundary problems. There's only one conclusion possible: _ **a single person must make this decision** _ and that person will not be liked. That's my job!

### Ingredients

Before setting a versioning scheme I must outline several ingredients of successful versioning.

1. Versioning must be completely hands-off on a daily basis. That is nobody should have to do anything manually or semi-automatically for versioning every day.
2. It should be quick and easy to implement.
3. Developer builds, qa builds, official builds, blue and yellow biulds should be versioned in the same manner.
4. Versioning should uniformly target the platforms you ship your product on.
5. It should be possible to quickly trace back from a version number to the source code that produced the build.
6. Versioning should apply to every kind of artifact that is produced: binaries, web pages, documents, etc.
7. There must be unambiguous interpretation of the version number. Two people looking at the same number must understand what it means.

### Versioning Scheme

Out of all conversations and options I've picked the following 4-digit scheme.

> **Major.Minor.SVN Revision.Zero
- **Major** : the major version of the product, changed manually with every product release with a large new feature set.
- **Minor** : the minor version of the product, changed manually with every minor product release containing some features.
- **SVN Revision** : the latest source-control revision of the codebase used for this build.
- **Zero** : the last number is 0. If there're more than one builds at the same revision, it is an auto-incremented number.

For example, 1.5.4567.0 means that this is product version 1.5 at SVN revision 4567.

### Implementation with MSBuild

We use [MSBuild Community Tasks](http://msbuildtasks.tigris.org/) to generate the version number.

#### Versioning C# Assemblies

1. Generate a GlobalAssemblyInfo.cs version file.
2. Edit AssemblyInfo.cs in each project and reduce it down to AssemblyTitle, AssemblyDescription and AssemblyGUID.
3. Add the generated GlobalAssemblyInfo.cs as a link to each project. When adding a file in Visual Studio, the Add button drops down to add a file as a link.

The following MSBuild script generates the version file.

#### Versioning C++ Code

1. Use a template version header file (version.h.template).
2. Generate replacement fields for the template file using an MSBuild script.
3. Replace the fields in the template to produce version.h.
4. Use a generic version.rc file that includes version.h.
5. Include version.rc in all resources files instead of a hardcoded OSVERSIONINFO resource.

A Version.h.template file looks like this.

 VERSION_PRODUCTVERSION_VALUE VERSION_VALUE

The template replacement, task from [MSBuild Community Tasks](http://msbuildtasks.tigris.org/).

And the version.rc file to include in every other .rc file.

<font color="#0000ff" size="2"><font color="#0000ff" size="2">
<p>#ifndef</p></font></font> <font color="#0000ff" size="2"><font color="#0000ff" size="2">
<p>#ifndef</p></font></font> <font color="#0000ff" size="2"><font color="#0000ff" size="2">
<p>#ifndef</p></font></font> <font color="#0000ff" size="2"><font color="#0000ff" size="2">
<p>#ifndef</p></font></font> <font color="#0000ff" size="2"><font color="#0000ff" size="2">
<p>#ifndef</p></font></font> <font color="#0000ff" size="2"><font color="#0000ff" size="2">
<p>#ifndef</p></font></font> <font color="#0000ff" size="2"><font color="#0000ff" size="2">
<p>#ifndef</p></font></font> <font color="#0000ff" size="2"><font color="#0000ff" size="2">
<p>#ifndef</p></font></font><font color="#0000ff" size="2"><font color="#0000ff" size="2">#endif
<p>#ifndef</p></font></font><font color="#0000ff" size="2"><font color="#0000ff" size="2">#endif
<p>#ifndef</p></font></font>
<p>VS_VERSION_INFO VERSIONINFO<br>FILEVERSION VERSION_FILEVERSION<br>PRODUCTVERSION VERSION_PRODUCTVERSION<br>FILEFLAGSMASK 0x3fL<br></p></font>

#### Versioning Other Targets

The same template idea applies to all kinds of targets. For example, the doxygen documentation.

### Implementation with Ant

The major and minor version (property version.majorminor) are stored in the version.properties file. The file is included in the ant build script.

The following code fragment gets the svn revision of the current directory.



Finally, the auto-incremented build number is generated with the following tag (which should be run once per build, somewhere in initialization).

This sets the build.number property. The build files may then use the version.full property, created in the following way.

### Implementation in CruiseControl

CruiseControl supports the concept of build publishers and labellers that work together to pickup built artifacts and deposit then in a destination folder. With my versioning scheme it's easy to create matching folder names and build numbers. None of the built-in CruiseControl.NET labellers fully support our versioning scheme but there is a [Google code project](http://code.google.com/p/svnrevisionlabeller/) available that implements an SVN Revision Labeller that works nicely with this versioning. To install this plug-in, just download [the zip file](http://svnrevisionlabeller.googlecode.com/files/ccnet.SvnRevisionLabeller.plugin.20080311-1.0.3.zip), unzip it and drop ccnet.SvnRevisionLabeller.dll into your CruiseControl.NET server directory (for example, C:\Program Files\CruiseControl.NET\server).

Now you can add the SVN version labeller to your CruiseControl config file. Here's a sample config file:

Each build's artifacts (the entire C:\source\myproject\target\Release directory) will be published under the publishDir to the directory Major.Minor.SVNRev.Bump, where Major and Minor correspond to the text in the project/labeller/major and project/labeller/minor tags from the XML above, SVNRev is the revision of HEAD in the SVN repository at project/labeller/url in the XML above, and Bump is a number that increments by 1 on each build and resets to 0 each time the SVN revision changes between builds. This means that any build triggered by the SVN commit of revision X will be published to a directory labelled Major.Minor.X.0. If builds are triggered manually or on a schedule before revision X+1 is committed, those builds will be published to Major.Minor.X.1, Major.Minor.X.2, etc.

### Unit Testing

We also unit test versions. We want to make sure that all our binaries are properly versioned. The following NUnit test works for both .NET assemblies and Windows native binaries.

}

  FileVersionInfo versionInfo = FileVersionInfo.GetVersionInfo(filename);
   versionInfo.FilePrivatePart);

### Notes

Incrementing the major or minor build number is done during branching. The only place to do it is the MSBuild project file or the ANT properties file. There're no other manual steps, ever.

Another great thing about this versioning scheme is that we can now build with CruiseControl on a trigger. Every check-in can generate a build. We don't do daily scheduled builds any more. This is truly agile, continuous integration.

### Questions?

Always welcome, dblock at dblock dot org.

