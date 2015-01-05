---
layout: post
title: "DataMapper: promoting columns into classes"
redirect_from: "/datamapper-promoting-columns-into-classes"
date: 2011-02-11 06:45:11
tags: [mysql, datamapper, mongodb, ruby, databases]
comments: true
---
I recently had to deal with reading a schema in a MySQL database in Ruby and migrating data to MongoDB. It has been made real easy with [DataMapper](http://datamapper.org), an awesome library that doesn’t force me into creating a complete and rigid model  for the MySQL database.

Today’s problem looks as follows. I have a table called _fruits_. Each _fruit _has a field called _color _amongst two dozen other fields. Colors are referred by name, for example  _yellow_ or _green_. What I would like to do is to promote the colors into a first class object, therefore creating a collection of colors based on the data in the _fruits_ table. Effectively I’d like to `SELECT DISTINCT color from fruits`, but I’d like the results to be of type `Color`.

Turns out to be very straightforward with DataMapper.

```ruby
class Color
  include DataMapper::Resource
  storage_names[:default] = "fruits"
  property :name, String, :field => "color"
  
  class << self
    alias_method :_all, :all

    def all
      coll = []
      repository(:default).adapter.select("SELECT DISTINCT color FROM fruits").each do |c|
        coll << Color.new({name: c})
      end
      coll
    end
  end
end
```

This creates a class called `Color` with a `name` field that comes from the `color` column of the _fruits_ table. We replace the `Color.all` method with our own implementation that makes a `DISTINCT` query at the adapter level. As a bonus you can see how you can rename the all method (we don’t really call the old `_all` implementation here, but it’s often useful). This lets you do `Color.all`.
