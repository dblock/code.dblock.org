---
layout: post
title: "BSON::InvalidKeyName: key must not contain '.' or ‘$’"
redirect_from: "/bsoninvalidkeyname-key-must-not-contain-or/"
date: 2011-02-04 15:14:01
tags: [mongodb, ruby]
comments: true
---
I ran into an error from Mongo, _BSON::InvalidKeyName: key must not contain '.'_ (or sometimes ‘$’ instead of ‘.’). It would happen randomly under RSpec (I do plan to check out Cucumber and Steak - together with BiSON this is going to be delicious), which presents a nice exception summary rather than a full stack trace. The first lesson was how to catch and re-raise a Ruby exceptions to output more detail. I wrapped the failing code with a _begin/rescue_ block.

```ruby
begin
    # offending code
rescue Exception => e
    puts e.backtrace
    raise $!
end
```

This gave a full stack trace for the exception.

```
C:/Ruby/lib/ruby/gems/1.9.1/gems/bson-1.1.5/lib/bson/bson_c.rb:24:in `serialize'
C:/Ruby/lib/ruby/gems/1.9.1/gems/bson-1.1.5/lib/bson/bson_c.rb:24:in `serialize'
C:/Ruby/lib/ruby/gems/1.9.1/gems/mongo-1.1.5/lib/mongo/collection.rb:775:in `block in insert_documents'
C:/Ruby/lib/ruby/gems/1.9.1/gems/mongo-1.1.5/lib/mongo/collection.rb:774:in `each'
C:/Ruby/lib/ruby/gems/1.9.1/gems/mongo-1.1.5/lib/mongo/collection.rb:774:in `insert_documents'
C:/Ruby/lib/ruby/gems/1.9.1/gems/mongo-1.1.5/lib/mongo/collection.rb:278:in `insert'
C:/Ruby/lib/ruby/gems/1.9.1/gems/mongoid-2.0.0.rc.1/lib/mongoid/collections/master.rb:15:in `block (2 levels) in <class:Master>'
C:/Ruby/lib/ruby/gems/1.9.1/gems/mongoid-2.0.0.rc.1/lib/mongoid/collection.rb:20:in `block (2 levels) in <class:Collection>'
C:/Ruby/lib/ruby/gems/1.9.1/gems/mongoid-2.0.0.rc.1/lib/mongoid/persistence/insert.rb:55:in `insert'
C:/Ruby/lib/ruby/gems/1.9.1/gems/mongoid-2.0.0.rc.1/lib/mongoid/persistence/insert.rb:31:in `block (2 levels) in persist'
C:/Ruby/lib/ruby/gems/1.9.1/gems/activesupport-3.0.3/lib/active_support/callbacks.rb:433:in `_run_save_callbacks'
C:/Ruby/lib/ruby/gems/1.9.1/gems/activesupport-3.0.3/lib/active_support/callbacks.rb:93:in `run_callbacks'
...
```

BSON serializes documents and collections into a binary stream that gets sent to MongoDB. That bson_c.rb is a thin wrapper on top of some native code. Rather than using my obsolete C/C++ skills and digging into C code I decided to check whether there was a newer version of bson. I am on 1.1.5, but there’s already a 1.2.0 update. Problem went away after swapping for a newer version. Someone must have done something right. If you know the actual bug fixed, please do share.
