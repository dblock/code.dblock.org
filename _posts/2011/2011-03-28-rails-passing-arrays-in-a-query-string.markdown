---
layout: post
title: "Rails: Passing Arrays in a Query String"
redirect_from: "/rails-passing-arrays-in-a-query-string/"
date: 2011-03-28 22:07:16
tags: [rails, ruby]
comments: true
dblog_post_id: 190
---
I found this quite unusual. I needed to receive an array with some nested hashes part of a query string into a JSON API. Passing encoded JSON wasn’t looking hot. Turns out, in Rails, this can be done with the `[]` syntax.

```
/stuff?widget[]=first-widget&gadget[]=a-gadget&widget[]=another%20widget
```

What the heck is this [] syntax?! Why is there multiple widget entries?! There’re a few good articles on this, including [this one](http://rails.nuvvo.com/lesson/6371-action-controller-parameters). Web developers apparently have been doing this forever. I am far behind :(

Here’s what Rails parses from this query string.

```
{
    :widget => ["first-widget",  "another widget"],
    :gadget => ["a-gadget"]
}
```

Awesome.
