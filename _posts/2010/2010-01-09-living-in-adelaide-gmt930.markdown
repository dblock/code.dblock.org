---
layout: post
title: "Living in Adelaide, GMT+9:30"
redirect_from: "/living-in-adelaide-gmt930"
date: 2010-01-09 13:40:25
tags: [.net, asp.net]
comments: true
---
Someone kindly reported [a bug entitled "Times Rounding Off"](http://www.foodcandy.com/BugView.aspx?id=713) on [FoodCandy.com](http://www.foodcandy.com/).

> _"I just created a new event, scheduled to start at 6:30 PM on December 14th. When it displays, it shows a start time of 6:00 PM. If I edit it, it shows 6:30 PM."_

I tried to reproduce at no avail. After-all, it’s not that complicated to display a time correctly, especially when it’s the same one as the user enters. How could I have possibly introduced a bug in something this simple? Could this be a user error? So to nail this down, I got a recording of what the user sees.

![]({{ site.url }}/images/posts/2010/2010-01-09-living-in-adelaide-gmt930/image_7.jpg)

Looks like a MAC. That’s the problem! It’s a conspiracy of Apple against Microsoft. There must be code in Safari that changes 6:30 to 6:00 every time it hits a website written in .NET.

![]({{ site.url }}/images/posts/2010/2010-01-09-living-in-adelaide-gmt930/image_11.jpg)

The screenshots are convincing. The problem exists. And the cause is right there on the screen. The browser' time zone is _Adelaide (GMT+09:30)_. Adelaide, turns out, is the capital of South Australia and has a population of just over a million people. It has a superb climate and cheap housing. It also has a time zone that is nine and a half hours away from UTC. Nine and a half? That’s weird, I’ve never paid attention to half-hour time zones. Turns out there’re others, including Kathmandu, GMT+5:45. Debugging the code it was clear that my entire time-zone system was rounding hours. And now I remember why.

When I started dealing with time zones, I added code that let the user choose which time zone he’s in and defaulted the value to the browser time zone. The latter comes from a browser cookie, x-VisitorTimeZoneOffset. I wrongly assumed that the offset is an int, so it did int.Parse. That was the first mistake because in Adelaide the browser time zone would be +9.5. I wanted this value to become a TimeSpan, but this is not serializable,  hence all methods that needed the user’s time zone offset took an int. Adelaide time zone offset would be 9 and all the times, stored in UTC and converted to the user’s time zone were wrong by 30 minutes.

In order to fix this I had to make a few changes.

1. Fix [TimeZoneInformation.cs](https://github.com/dblock/sncore/blob/master/SnCore.Tools/TimeZoneInformation.cs) to return TimeSpan instead of an int for UTC bias and to parse the browser time zone offset as a float. TimeZoneInformation is, btw, a very helpful class that originated [here](http://www.codeproject.com/dotnet/WorldClock.asp) and is capable of enumerating system time zones and do the time zone math taking care of daylight savings and stuff like that.
2. Change all native methods that took an int UTC bias to take a TimeSpan.
3. Change all SOAP methods that took an int UTC bias to take a long UTC bias in ticks. This makes it serializable and I can new TimeSpan(ticks) on the server or client side.
4. Change the code that adjusts UTC times to Add a TimeSpan and not AddHours a UTC bias.
5. Write some [unit tests for TimeZoneInformation](https://github.com/dblock/sncore/blob/master/SnCore.Tools.Tests/TimeZoneInformationTest.cs).

And finally, ask someone in Adelaide to test this for me.

![]({{ site.url }}/images/posts/2010/2010-01-09-living-in-adelaide-gmt930/image_20.jpg)

