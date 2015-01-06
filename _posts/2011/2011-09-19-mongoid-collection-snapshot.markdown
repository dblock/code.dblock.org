---
layout: post
title: "Mongoid Collection Snapshot"
redirect_from: "/mongoid-collection-snapshot/"
date: 2011-09-19 12:08:53
tags: [mongodb, ruby]
comments: true
dblog_post_id: 269
---
Another fine open-source contribution from [@aaw](https://github.com/aaw), [mongoid_collection_snapshot](https://github.com/aaw/mongoid_collection_snapshot): easy maintenance of collections of processed data in MongoDB with the Mongoid ODM.

[github.com/aaw/mongoid_collection_snapshot](https://github.com/aaw/mongoid_collection_snapshot)

This turned out to be extremely useful in many map-reduce scenarios where we do lengthy computations that output data that is used as a complete and consistent set. For example, calculating average prices across ranges of items (the example in the documentation). Another good use can be for tags stored as arrays of strings – you want to know how many items are tagged with a given entry. We can now take [my incremental tag count map-reduce](/improving-tags-mapreduce-with-mongodb-18x) and replace it with a much more trivial implementation that uses this gem.
