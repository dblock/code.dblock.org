---
layout: post
title: "Mongoid_fulltext: full-text n-gram search for your MongoDB models"
redirect_from: "/mongoidfulltext-full-text-n-gram-search-for-your-mongodb-models/"
date: 2011-04-05 19:27:06
tags: [art.sy, mongodb, rails, ruby, open source]
comments: true
dblog_post_id: 195
---
![ngrams]({{ site.url }}/images/posts/2011/2011-04-05-mongoidfulltext-full-text-n-gram-search-for-your-mongodb-models/ngrams_4.jpg)

I am pleased to announce [mongoid_fulltext](https://github.com/artsy/mongoid_fulltext), an open-source full-text search implementation for your MongoId models in Ruby.

We’ve been using [mongoid_search](https://github.com/mauriciozaffari/mongoid_search) for sometime now for auto-complete. It’s a fine component that splits sentences and uses MongoDB to index them. Unfortunately it doesn’t rank them, so results come in order of appearance. In contrast, mongoid-fulltext uses n-gram matching (with n=3 right now), so we index all of the substrings of length 3 from text that we want to search on. If you search for "damian hirst", mongoid_fulltext does lookups for "dam", "ami", "mia", "ian", "an ", "n h", " hi", "hir", "irs", and "rst" and combines the results to get a most likely match. This also means users can make simple spelling mistakes and still find something relevant. In addition, you can index multiple collections in a single index, producing best matching results within several models. Finally, mongoid-fulltext leverages MongoDB native indexing and map-reduce.

This library is written by [@aaw](https://github.com/aaw), who implements most of [art.sy](https://artsy.net/) search technology. All due credit goes entirely to him.
