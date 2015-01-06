---
layout: post
title: "Basic Workflow with htmlInstaller: HTML-based bootstrapper for DNI"
redirect_from: "/basic-workflow-with-htmlinstaller-html-based-bootstrapper-for-dni"
date: 2010-08-06 15:48:54
tags: [dotnetinstaller, msi, wix]
comments: true
---

Since the day I mentioned that I was working on an HTML-based bootstrapper, I began getting a regular stream of e-mails asking about my progress. I even get phone calls. It’s a very similar experience on the WIX mailing list where a question pops up about Burn, the WIX bootstrapper, now years in the making. So here it is, you can stop leaving me voicemails now and start playing with the first well-featured builds.

#### Motivation

We want a bootstrapper with as much control of the UI as humanly possible.

#### Get It

Download the [latest dotNetInstaller](https://github.com/dblock/dotnetinstaller). You’ll find _htmlInstaller.exe_ in the distribution. This is a UI driver based on [HTMLayout](http://www.terrainformatica.com/) and behaves very much like the existing dotNetInstaller.exe. These two now share the same execution engine and differ mostly in UI. Both support chained configurations, downloads, etc.

#### Run It

You can run htmlInstaller.exe on an existing bootstrapper configuration.

```
htmlInstaller.exe /configFile Configuration.xml
```

This is what you’re going to see.

![]({{ site.url }}/images/posts/2010/2010-08-06-basic-workflow-with-htmlinstaller-html-based-bootstrapper-for-dni/image_9.jpg)

Looks familiar? Unlike the dotNetInstaller.exe UI, this is a UI written in HTML rendered in an embedded browser. You get some new features, such as minimizing, maximizing and resizing of the window, right out of the box. And because the renderer is HTLM, controls flow and sizes adjust normally as in your browser. And because it’s HTML you will be able to skin the bootstrapper completely – those top bar buttons and the resize grip are also rendered by the HTML engine.

Here’s a resized window.

![]({{ site.url }}/images/posts/2010/2010-08-06-basic-workflow-with-htmlinstaller-html-based-bootstrapper-for-dni/image_13.jpg)

#### Progress

Hit Install with a working configuration. You’ll immediately notice that the progress bar is now embedded inside the bootstrapper UI. I got rid of the infamous K-2000 progress popup and replaced it with an HTML widget. Obviously, it’s completely customizable, and as any other control, optional.

![]({{ site.url }}/images/posts/2010/2010-08-06-basic-workflow-with-htmlinstaller-html-based-bootstrapper-for-dni/image_36.jpg)

You’ll still see prompts and errors in dialogs. Installers continue to show a separate UI, since the bootstrapper still runs msiexec for MSIs. I do plan to host the MSI installation eventually and provide a single progress bar through the entire process. Failures and bootstrapper prompts will end up being displayed in the bootstrapper UI itself in the 2.0 release if I can make it work.

#### HTML Source

Let’s look at the HTML source in this bootstrapper and see how we can make changes to it. There’re two documents embedded with htmlInstaller by default: _index.html_ and _style.css_. We’ll ignore the stylesheet and focus on the index.html page, examining it top-to-bottom.

```html
<html>
<head>
  <style type="text/css">
   @import url(style.css) screen;
  </style>
</head>
<body>
  <div id="topbar">
   <div id="caption"></div>
   <widget id="minimize" type="button">0</widget>
   <widget id="maximize" type="button">1</widget>
   <widget id="close" type="button">r</widget>
  </div>
  <div id="content">
   <div id="dialog_message">
    The following components will be installed:
   </div>
   <div id="components" />
   <div id="os" />
   <div id="error" />
   <widget type="progress" id="progress" />
   <div id="buttons">
    <input id="button_install" type="button" value="Install" />
    <input id="button_uninstall" type="button" value="Uninstall" />
    <input id="button_skip" type="button" value="Skip" />
    <input id="button_cancel" type="button" value="Cancel" />
   </div>
  </div>
  <div id="bottombar">
   <div id="status">Loaded</div>
   <div id="corner">o</div>
  </div>
</body>
</html>
```

This is a standard HTML page with an _html_ opening tag, a _head_ and a _body_. The stylesheet is imported with a custom HTML tag, `@import` – HTMLayout-specific tags are documented [here](http://www.terrainformatica.com/htmlayout/tags.whtm).

There’re a few built-in widgets defined by their _id_’s. All such widgets are optional and have well-known behavior within the bootstrapper.

- _topbar_: the top of the window that can be dragged
  - _caption_: bootstrapper title
  - _minimize_: will minimize the window when clicked
  - _maximize_: will maximize the window when clicked
  - _close_: will close the window when clicked
- _content_: all user controls must be within the content div – form fields are collected as bootstrapper variables during install
  - _components_: a list of components defined in the bootstrapper configuration
  - _os_: operating system label
  - _error_: error messages go here (currently not hooked up)
  - _progress_: a progress bar during installation
  - _buttons_: install, uninstall, skip (to next configuration) and cancel buttons
- _bottombar_: the bottom of the window that can host a resize grip
  - _status_: a status bar where progress text goes
  - _corner_: the resize grip that can be clicked and dragged to resize the window

#### Adding an Image

Let's customize the bootstrapper UI by adding this picture.

![picture]({{ site.url }}/images/posts/2010/2010-08-06-basic-workflow-with-htmlinstaller-html-based-bootstrapper-for-dni/picture_5.jpg)

We can insert an `img` tag anywhere in the HTML.

```html
<img src="picture.jpg" />
```

We must now embed the picture with the bootstrapper. This can be done with a new `/EmbedHtml` parameter to _InstallerLinker.exe_. For testing you can also put all files, including _htmlInstaller.exe_ in the same directory and run `htmlInstaller.exe /configFile Configuration.xml`. If a local _index.html_ exists, it will be picked up.

```
InstallerLinker.exe /Output:Setup.exe /Template:htmlInstaller.exe /Configuration:Configuration.xml /EmbedHtml:Samples\HtmlSetup\Picture /Verbose+
```

This produces Setup.exe that includes all the HTML files and our picture in the _Samples\HtmlSetup\Picture_ folder. Note that the HTML UI resized the component selector automatically to insert the picture, as expected.

![]({{ site.url }}/images/posts/2010/2010-08-06-basic-workflow-with-htmlinstaller-html-based-bootstrapper-for-dni/image_25.jpg)

#### Creating a Basic Workflow

You can now easily see how to create a basic workflow with two pages. Replace _index.html_ with a welcome page and create _setup.html_ with a new link back to the welcome page.

Here’s the result.

![]({{ site.url }}/images/posts/2010/2010-08-06-basic-workflow-with-htmlinstaller-html-based-bootstrapper-for-dni/image_34.jpg)

#### What’s Next?

For my day job needs I’m hoping to enable multiple configurations that a user can choose from within the same bootstrapper. My goal is to allow the end-user to choose scenario-based installs within a single package.

#### Questions / Bugs

Remember that this is very much work in progress. Don’t expect everything to work.

