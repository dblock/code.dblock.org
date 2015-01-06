---
layout: post
title: "How do I get the name of an object’s type in JavaScript?"
redirect_from: "/how-do-i-get-the-name-of-an-objects-type-in-javascript/"
date: 2012-10-13 21:19:02
tags: [backbone.js, javascript, rspec, art.sy, testing]
comments: true
dblog_post_id: 351
---
I love reflection, especially the Ruby kind. JavaScript reflection, though, can exhibit interesting runtime behavior.

I needed to do something for a given object type, so I wanted to get the name of an object’s type in JavaScript. StackOverflow has a few good discussions on this topic [here](http://stackoverflow.com/questions/332422/how-do-i-get-the-name-of-an-objects-type-in-javascript) and [here](http://stackoverflow.com/questions/11690894/coffeescript-using-instanceof-vs-class-constructor-name).  I wrote this innocent piece of CoffeeScript last week.

```coffeescript
if item.constructor.name == "Spline"
  alert("Reticulated spline: #{item.reticulated}");
```

It worked great in my dev environment and in tests, but failed in staging and would have failed in production had we not noticed. I put in a debugger and, surprise, _item.constructor.name_ was "d". WTF? Turned out, this was caused by the fact that we produced minified JavaScript during asset packaging. All functions and class names were replaced by single character names.

Because _item_ was a Backbone model, the solution was to introduce _modelName_ into it and check that.

```coffeescript
class App.Models.Spline extends Backbone.Model
  modelName: "Spline"
```

If you’re minifying JavaScript, make sure to turn this on in tests and catch similar bugs early. We use [Jammit](http://documentcloud.github.com/jammit/), so this is done by setting _package_assets_ to _always_ in _assets.yml_ (setting it to _on_ in tests has no effect).
