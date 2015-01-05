---
layout: post
title: "Iterating over lists in MSBuild"
redirect_from: "/iterating-over-lists-in-msbuild"
date: 2010-07-07 20:33:31
tags: [msbuild]
comments: true
---
I never remember how to do this, so here’s a refresher. In MSBuild you can easily define a list with properties and iterate over it.

```xml
<Project DefaultTargets="all" xmlns="http://schemas.microsoft.com/developer/msbuild/2003" >
  <ItemGroup>
    <Squirrel Include="Bob">
      <Color>green</Color>
      <Teeth>white</Teeth>
    </Squirrel>
    <Squirrel Include="Marc">
      <Color>orange</Color>
      <Teeth>yellow</Teeth>
    </Squirrel>
  </ItemGroup>
  <Target Name="ShowSquirrels" Inputs="@Squirrel" Outputs="%(Squirrel.Identity)">
    <Message Text="%(Squirrel.Identity) is an %(Squirrel.Color) squirrel with %(Squirrel.Teeth) teeth" />
  </Target>
</Project>
```

Run the sample above with `msbuild test.proj /t:ShowSquirrels`.
