---
layout: post
title: "Writing DotNet Code on a Mac, No Administrator Privileges Required"
tags: [dotnet]
date: 2019-12-17
comments: true
---
I've been wanting to [write a sample for AWS Data Exchange](https://github.com/aws-samples/aws-dataexchange-api-samples/pull/27) in .NET. Been a while since I've written any C# code. Last time I used VirtualBox to run Windows. This time, I went the route of [Amazon Workspaces](https://aws.amazon.com/workspaces), which quickly gave me a Windows desktop, and as I was in the middle of figuring out how to get Administrator privileges on it to install the .NET SDK, and while I was downloading Visual Studio, one of my colleagues asked "Why Windows?". I couldn't come up with a good answer, so I re-did this on my Mac in about ten minutes, no special privileges required. This should work on any *nix, too.

Download and install .NET SDK using the [install script](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-install-script).

```
$ wget https://dot.net/v1/dotnet-install.sh
$ chmod 700 dotnet-install.sh
$ ./dotnet-install.sh --install-dir ~/Library/DotNet

dotnet-install: Downloading link: https://dotnetcli.azureedge.net/dotnet/Sdk/3.1.100/dotnet-sdk-3.1.100-osx-x64.tar.gz
dotnet-install: Extracting zip from https://dotnetcli.azureedge.net/dotnet/Sdk/3.1.100/dotnet-sdk-3.1.100-osx-x64.tar.gz
dotnet-install: Installation finished successfully.
```

Add .NET to `PATH`, edit `~/.bash_profile`.

```
# Add .NET to PATH
export PATH="$PATH:$HOME/Library/DotNet"
```

Create a new console app.

```
$ dotnet new console --name AwsDataExchangeSample
$ cd AwsDataExchangeSample
```

Add the AWS Data Exchange SDK from [Nuget](https://www.nuget.org/packages/AWSSDK.DataExchange/).

```
$ dotnet add package AWSSDK.DataExchange --version 3.3.100.15
```

Modify [the code](https://github.com/aws-samples/aws-dataexchange-api-samples/blob/master/subscribers/dotnet/all-entitled-datasets/Program.cs), run the app.

```
$ dotnet run Program.cs
```