---
layout: post
title: "dotNetInstaller Setup Bootstrapper 1.7 Ships"
redirect_from: "/dotnetinstaller-setup-bootstrapper-17-ships/"
date: 2009-10-02 04:44:34
tags: [dotnetinstaller]
comments: true
dblog_post_id: 57
---
I shipped [dotNetInstaller](https://github.com/dblock/dotnetinstaller) 1.7 yesterday. Download it [here](https://github.com/dblock/dotnetinstaller/). You can see the long list of [what's new on the release page](https://github.com/dblock/dotnetinstaller/Release/ProjectReleases.aspx?ReleaseId=30174), but that's not the topic of my post.

There has been a large volume of regressions since 1.5 as many new features were implemented in 1.6. We're using dotNetInstaller heavily at my day job, so I needed to create a situation where I don't have to go back fixing the same bugs, over and over again. I just don't have time for that in the long run, I need to move on and work on some real enterprise software problems.

It took me a couple of weeks of commute (this is my free time pet project) to rewrite the C++ portion of the bootstrapper, splitting the code in a general utility library and business logic with virtually 100% unit test coverage. That eventually did yield a very reliable foundation that I can be proud of. I've done the same for projects about twenty times the size of dotNetInstaller, so this was a piece of cake. I am actually surprised how small the bootstrapper is once all the redundant mechanics boiled away.

Then I worked on unit testing end-to-end execution scenarios. That was done in .NET, driving the C++ bootstrapper in either silent or basic UI modes. I mostly implemented tests for the regressions that users reported, and there were quite a few that were overlooked in 1.6. Test driven development really works, having more and more regression tests kept hitting me with failures as I was reintroducing one bug while making code changes to fix another. Eventually the rate of bugs went down and changes became a lot more localized.

All-in-all I think more contributors can now jump in and make code changes easily without being scared of breaking everything. Send me some useful patches on CodePlex. Party on.

#### Update (2015)

dotNetInstaller now lives [on Github](https://github.com/dblock/dotnetinstaller).
