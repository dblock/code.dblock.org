---
layout: post
title: "Ruby Enumerable Detect with Value"
redirect_from: "/ruby-enumerable-detect-with-value/"
date: 2013-12-21 18:39:02
tags: [ruby, open source]
comments: true
dblog_post_id: 402
---
Given an _Enumerable_, you can _detect_ a value that matches a condition. But what if you want the result of the evaluation? You can now use _Enumerable##detect_value _from the [enumerable-detect-value](https://github.com/dblock/enumerable-detect-value) gem.

Consider an example where you have an expensive _Geocoder.search_ operation and a list of addresses, two of which are fake. The function returns _nil_ for a fake address. We would like to find the geo-location of the first real address.

```ruby
addresses = [
 '221B Baker Street, London, UK', # Sherlock Holmes
 '1428 Elm Street, Springwood, Ohio', # Nightmare on Elm Street
 '350 5th Ave, New York, NY' # Empire State Building
]

first_real_address = addresses.detect do |address|
 Geocoder.search(address)
end

first_real_address # 350 5th Ave, New York, NY
```

We would now have to call _Geocoder.search_ on _first_real_address_ twice.

Instead, using _detect_value_ you can return the geo-location of the first real address.

```ruby
first_geo_location = addresses.detect_value do |address|
 Geocoder.search(address)
end

first_geo_location # lat: 40.74830, lng: -73.98554
```

The [implementation for detect_value](https://github.com/dblock/enumerable-detect-value/blob/master/lib/enumerable-detect-value.rb) is straightforward.

```ruby
module Enumerable
 # Returns the first result of the block that is not nil.
 def detect_value(&block)
   each do |el|
     result = yield el
     return result if result
   end
   nil
 end
end
```

I don’t think this can this be done with the current Ruby standard library without introducing a temporary variable, and _Enumerable##Lazy_ won’t help_._
