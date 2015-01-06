---
layout: post
title: "How to do a Debug, Release or both builds with MSBuild"
redirect_from: "/how-to-do-a-debug-release-or-both-builds-with-msbuild/"
date: 2009-02-13 18:15:00
tags: [msbuild]
comments: true
---
In a previous post I've described how to do [product/build versioning with MSBuild](/ShowPost.aspx?id=19). Another common build aspect is building different flavors of code: Debug vs. Release.

All the projects I work on now have a very simple MSBuild script that allows you to build either Debug or Release, defaulting to Debug for developers. Our CruiseControl configurations build Release. Comes a shared libraries project, which needs to do Debug, Release or both. How can I accomplish this with MSBuild?

### Default Configuration

Let's define a property for the default configuration, ie. when no Configuration is specified on the command line.

```xml
<PropertyGroup Condition="'$(Configuration)'==''">
 <Configuration>Debug</Configuration>
</PropertyGroup>
```

### Multiple Configurations

What if multiple configurations were specified? For example, _Debug;Release_. We want to transform a single property into an array of task parameters. There's a brain-twisting way of doing this with MSBuild.

```xml
<Target Name="configurations">
 <CreateItem Include="$(Configuration)">
  <Output TaskParameter="Include" ItemName="Configuration" />
 </CreateItem>
</Target>
```

It seems that the above code does nothing, but it creates an item called _Configuration_ that can be specified as input to another target.

```xml
<Target Name="showconfigurations" DependsOnTargets="configurations" Inputs="@(Configuration)" Outputs="target\%(Configuration.FileName)">
 <Message Importance="high" Text="Building project, %(Configuration.Identity) ..." />
</Target>
```

Try it.

```
> msbuild test.proj /t:showconfigurations
Building project, Debug

> msbuild test.proj /t:showconfigurations /p:Configuration=Release
Building project, Release ...

> msbuild test.proj /t:showconfigurations /p:Configuration="Debug;Release"
Building project, Debug ...
Building project, Release ...
```

### Target Inputs

Finally, change all the targets that depend on the configuration name accordingly and use `%(Configuration.Identity)` rather than `$(Configuration)` in those tasks.

```xml
<Target Name="version" DependsOnTargets="configurations" Inputs="@(Configuration)" Outputs="target\%(Configuration.FileName)">
 <Version Major="$(MajorVersion)" Minor="$(MinorVersion)">
 <Output TaskParameter="Major" PropertyName="Major" />
 <Output TaskParameter="Minor" PropertyName="Minor" />
 <Output TaskParameter="Revision" PropertyName="Revision" />
 </Version>
 <Message Text="Version: $(Major).$(Minor).$(Build).$(Revision) (%(Configuration.Identity))"/>
 ...
</Target>
```
