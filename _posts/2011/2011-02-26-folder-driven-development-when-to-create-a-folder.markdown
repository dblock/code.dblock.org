---
layout: post
title: "Folder-Driven Development: when to create a folder?"
redirect_from: "/folder-driven-development-when-to-create-a-folder"
date: 2011-02-26 20:20:36
tags: [rails, ruby, architecture, testing]
comments: true
---
![](http://www.clker.com/cliparts/f/a/b/8/11949856441703715891another_folder_icon_01.svg.thumb.png)

I am a huge fan of the comical version of ["bug-driven development"](http://blogs.sun.com/toddfast/entry/bug_driven_development), which I earlier called "bug driven design". Today, I want to propose a new methodology: _folder-driven development_. I cannot take credit for inventing it, a colleague of mine suggested it earlier this week. I found the idea a useful subset of the _"divide to conquer"_ rule, and felt the need to put a bit of structure around it.

#### Guiding Principles

The basic idea behind folders is to reduce complexity. Before creating a folder, consider the following rules of thumb.

1. Create a folder that is meaningful
2. Make folders effective and productive
3. Be proud of your folders
4. Feel the need to create more folders.

Let’s examine one good and one bad example.

#### Java: Four Wrongs

The worst offender of the principles of folder-driven development is Java. By default, it forces you to organize classes in namespaces and namespaces into folders. This is the simple folder structure of the JNA project:

![image]({{ site.url }}/images/posts/2011/2011-02-26-folder-driven-development-when-to-create-a-folder/image%5b12%5d.jpg)

There’s no value in having the three top-level folders _src,_ _com_ and _sun_. Let's put this to the test against our rules of thumb.

1. _Create a folder that is meaningful_: both _com_, and _sun_ folders are completely useless and contain nothing else than one subfolder
2. _Make folders effective and productive_: every time I have to find source I must either _cd_ three too-many times or make several clicks to expand in the IDE; it’s all busy work
3. _Be proud of your folders_: since Sun sold to Oracle we have a bit less to be proud of; I’d love to delete the _sun_ folder, but it’s the kind of refactoring that is likely to create a fist fight on the JNA mailing list
4. _Feel the need to create more folders_: adding 1-3 I want to delete a few, not create more.

#### Rails: All Better

Rails looks like a substantial improvement. The top of the default structure created by _rails new app_ looks like this:

![image]({{ site.url }}/images/posts/2011/2011-02-26-folder-driven-development-when-to-create-a-folder/image%5b16%5d.jpg)

1. _Create a folder that is meaningful_: since Rails does MVC, folders like _models_, _views_ and _controllers_ make sense
2. _Make folders effective and productive_: it’s easy to find a model and easy to find a controller
3. _Be proud of your folders_: the helpers folder is often used as the garbage bin of functions, but a bit of discipline promotes refactoring of utility classes into clear models that one can be proud of
4. _Feel the need to create more folders_: when unrelated models start filling the models folder, consider adding subfolders.

Happy folder refactoring!

