---
layout: post
title: "RoR Win: 'Getting Things Done' with MongoDB Mongoid"
redirect_from: "/ror-win-getting-things-done-with-mongodb-mongoid/"
date: 2011-05-27 12:33:18
tags: [mongodb, rails, ruby]
comments: true
dblog_post_id: 210
---
![mongoid-logo-small]({{ site.url }}/images/posts/2011/2011-05-27-ror-win-getting-things-done-with-mongodb-mongoid/mongoid-logo-small_2.jpg)

We high five each other and claim "Rails Win!" when someone finds a gem that solves a really big problem in ~~a few lines~~ one line of code. In this post I’ll list a few interesting addons to the RoR [Mongoid ORM](http://mongoid.org/) that are slowly adding up to a feature-rich ecosystem of plug-and-play modules that work with [Mongoid](http://mongoid.org/). This list should convince you that you should at least [try MongoDB](http://www.mongodb.org/). You can get a ton of functionality "for free".

- [Mongoid::Timestamps](http://mongoid.org/docs/extras.html): adds a timestamp to a model. IMHO all useful models should have a _created_at_ and a _modified_at_ field – it’s just a matter of time till someone asks you when your widget was modified. We use this.
- [Mongoid::Versioning](http://mongoid.org/docs/extras.html): stores multiple versions of the document. We’ve tried to use this, but ended up switching to Mongoid::History (below).
- [Mongoid::Paranoya](http://mongoid.org/docs/extras.html): marks documents as deleted instead of actually deleting them.
- [Mongoid::Slug](https://github.com/papercavalier/mongoid-slug): adds a URL-like field to a model. For example, our public API uses this field instead of the BSON ID itself, making the data portable across systems.
- [Mongoid::History](https://github.com/aq1018/mongoid-history): creates an audit trail for all changes in a model. It’s possible to undo and redo changes as well. We integrate this with our authentication and tag the identity of the person who made the change. I’ve been pushing features into this gem recently, including basic support for tracking object destruction.
- [Mongoid::Tracking](https://github.com/twoixter/trackoid): another tracker for document changes, more suitable when you need to embed tracking logic such as increments.
- [Mongoid::Taggable](https://github.com/wilkerlucio/mongoid_taggable): adds tags to documents and make documents searchable by all or some tags.
- [Mongoid::TaggableWithContext](https://github.com/aq1018/mongoid_taggable_with_context): adds tagging support with pre-aggregation.
- [Mongoid::Fulltext](https://github.com/aaw/mongoid_fulltext): an n-gram based full text search. We wrote this to power auto-complete and avoid having an external search engine system. It has been growing nicely with improved relevance math and features like indexing multiple models that can be queried at-once.
- [Mongoid::Search](https://github.com/mauriciozaffari/mongoid_search): keyword-based search.
- [Mongoid::Geo](https://github.com/kristianmandrup/mongoid-geo): geo-based searched.
- [Mongoid::Il8n](https://github.com/Papipo/mongoid_i18n): localizable fields.
- [Mongoid::Votable](https://github.com/vinova/voteable_mongo): vote models up/down.
- [Mongoid::Tree](https://github.com/ticktricktrack/mongoid_tree): model tree structures.
- [Mongoid::Orderable](https://github.com/arkxu/mongoid_order) and [ActsAsList::Mongoid](https://github.com/kristianmandrup/acts_as_list_mongoid): makes your models orderable.
- [Mongoid::Atomic](https://github.com/jcoene/mongoid_atomic): atomic updates.

This is all made possible by the fact that MongoDB documents don’t need a schema and that mongoid has a very simple callback mechanism that can invoke your function when an object is created, modified or destroyed. If you want a skeleton for writing an extension, look at the [source code of Mongoid::Fulltext](https://github.com/aaw/mongoid_fulltext/blob/master/lib/mongoid_fulltext.rb) – yes, the whole thing is 150 lines of code.

What other useful mongoid gems do you know about?
