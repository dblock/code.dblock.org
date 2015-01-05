---
layout: post
title: "Dirty Panel Extender (ASP.NET AJAX)"
redirect_from: "/dirty-panel-extender-aspnet-ajax"
date: 2008-08-10 18:08:51
tags: [asp.net]
comments: true
---
![ASP.NET Ajax Dirty Panel Extender in Action](http://www.codeproject.com/KB/ajax/ajaxdirtypanelextender/screenshot.jpg)

[FoodCandy](http://www.foodcandy.com) is a rich social network that offers users many web forms to fill. For example, users can post articles and edit lengthy profiles. Often they click on a link that takes them away from the page or press the wrong key (e.g. backspace that navigates to the previous page). In both cases their changes get lost. And it is always frustrating to have to re-enter the same text twice. Wouldn't it be nice to warn the user that he has unsaved data and give him an opportunity to cancel, then save his data?

This is a Panel Extender for ASP.NET AJAX 1.0 that automatically detects if any input control inside it was changed and shows an alert if the user tries to leave the page before saving the data. The extender supports most HTML input controls and can detect whether either data, selection or both have changed.

[[CodeProject Article](http://www.codeproject.com/KB/ajax/ajaxdirtypanelextender.aspx)]
