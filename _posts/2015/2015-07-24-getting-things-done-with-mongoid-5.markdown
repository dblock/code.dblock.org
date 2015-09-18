---
layout: post
title: "Getting Things Done with Mongoid 5"
date: 2015-07-24
tags: [mongodb, mongoid, ruby]
comments: true
---
![mongoid]({{ site.url }}/images/posts/2015/2015-07-24-getting-things-done-with-mongoid-5/mongoid.jpg)

Mongoid 5 has been released. The repository has been moved to the MongoDB organization and is now fully supported by MongoDB, the company. Great!

Gems are being upgraded to Mongoid 5. I maintain half a dozen of those, so I am going to keep an up-to-date list of the gems that support the new version, which will incidentally help everyone find their favorite Mongoid gems to stay productive, much like [my 2011 post](/2011/05/27/ror-win-getting-things-done-with-mongodb-mongoid.html) did.

So far I have added Mongoid 5 suport to two, and it was fairly easy - [mongoid-scroll@d398c4e9](https://github.com/dblock/mongoid-scroll/commit/d398c4e9ce8279d4659dc26f18f3a77ef38decdb), [mongoid-tag-collectible@5813b77f](https://github.com/dblock/mongoid-tag-collectible/commit/5813b77f3981c5725f8253ff8b6df09e816f099b) and [mongoid-autoinc@2be7377a](https://github.com/InnovativeTravel/mongoid-autoinc/commit/2be7377aa54f25cecc77ded6a642e675d04e4f11) should help you add support to other gems.

Since writing this I have also published a [mongoid-compatibility gem](https://github.com/dblock/mongoid-compatibility) that avoids redundant version checking code and introduces a thin compatibility layer for things like `Moped::BSON::ObjectId.legal?(value)` (Mongoid 3) vs. `BSON::ObjectId.legal?(value)` (Mongoid 4 and 5).

### Supports Mongoid 5

- [Mongoid::Autoinc](https://github.com/suweller/mongoid-autoinc): A mongoid plugin to add auto incrementing fields to your documents.
- [Mongoid::CachedJson](https://github.com/dblock/mongoid-cached-json): Effective caching for nested JSON models.
- [Mongoid::Enum](https://github.com/thetron/mongoid-enum): Sweet enum sugar for your Mongoid documents.
- [Mongoid::Fulltext](https://github.com/artsy/mongoid_fulltext): An n-gram based full text search.
- [Mongoid::Geospatial](https://github.com/nofxx/mongoid-geospatial): A MongoDB/Mongoid Extension with optional GeoRuby/RGeo support.
- [Mongoid::History](https://github.com/aq1018/mongoid-history): Creates an audit trail for all changes in a model.
- [Mongoid::RSpec](https://github.com/mongoid-rspec/mongoid-rspec): RSpec matchers and macros for Mongoid.
- [Mongoid::Scroll](https://github.com/dblock/mongoid-scroll): Extension that enables infinite scrolling.
- [Mongoid::TagCollectible](https://github.com/dblock/mongoid-tag-collectible): Easily maintain a collection of Tag instances with aggregate counts from your model's tags.

### Does Not Support Mongoid 5

This is your opportunity to help! Please contribute.

- [CarrierWave::Mongoid](https://github.com/carrierwaveuploader/carrierwave-mongoid): Mongoid and MongoDB's GridFS support in CarrierWave.
- [Delayed::Backend::Mongoid](https://github.com/collectiveidea/delayed_job_mongoid): Mongoid backend for DelayedJob.
- [Delayed::ShallowMongoid](https://github.com/joeyAghion/delayed_job_shallow_mongoid): Short-circuits serialization of Mongoid model instances when a delayed job is called on them.
- [Kaminari](https://github.com/amatsuda/kaminari): Paginator for modern web app frameworks and ORMs, including Mongoid.
- [Mongoid::Atomic](https://github.com/jcoene/mongoid_atomic): Atomic updates support.
- [Mongoid::CollectionSnapshot](https://github.com/aaw/mongoid_collection_snapshot): Easy maintenence of collections of processed data.
- [Mongoid::Geo](https://github.com/kristianmandrup/mongoid-geo): Geo-based searched.
- [Mongoid::GridFs](https://github.com/ahoward/mongoid-grid_fs): A pure Mongoid/Moped implementation of the MongoDB GridFS specification.
- [Mongoid::Il8n](https://github.com/Papipo/mongoid_i18n): Localizable fields.
- [Mongoid::Locker](https://github.com/afeld/mongoid-locker): Document-level locking.
- [Mongoid::Multinenancy](https://github.com/PerfectMemory/mongoid-multitenancy): Adds the ability to scope Mongoid models to a tenant in a shared database strategy.
- [Mongoid::Orderable](https://github.com/pyromaniac/mongoid_orderable): Ordered list implementation.
- [Mongoid::Paranoia](https://github.com/simi/mongoid_paranoia): Enables a "soft delete" of Mongoid documents.
- [Mongoid::Sadstory](https://github.com/netguru/mongoid-sadstory): Adds support for multiparameter fields to mongoid 4.x series.
- [Mongoid::Search](https://github.com/mauriciozaffari/mongoid_search): Keyword-based search.
- [Mongoid::Shell](https://github.com/dblock/mongoid-shell): Derive shell commands from Mongoid sessions and configuration options.
- [Mongoid::Slug](https://github.com/digitalplaywright/mongoid-slug): Generates a URL slug/permalink based on fields in a Mongoid-based model.
- [Mongoid::Taggable](https://github.com/wilkerlucio/mongoid_taggable): Adds tags to documents and make documents searchable by all or some tags.
- [Mongoid::TaggableWithContext](https://github.com/aq1018/mongoid_taggable_with_context): Adds tagging support with pre-aggregation.
- [Mongoid::Token](https://github.com/thetron/mongoid_token): Short snappy tokens for Mongoid documents.
- [Mongoid::Tracking](https://github.com/twoixter/trackoid): Tracker for document changes, more suitable when you need to embed tracking logic such as increments.
- [Mongoid::Tree](https://github.com/ticktricktrack/mongoid_tree): Model tree structures.
- [Mongoid::Votable](https://github.com/vinova/voteable_mongo): Vote models up/down.
- [WillPaginateMongoid](https://github.com/lucasas/will_paginate_mongoid): Paginator for Mongoid.

### Missing a Useful Gem?

Please comment below or [make a PR](https://github.com/dblock/code.dblock.org) and update this post.
