---
layout: post
title: "Custom RSpec Meta Tag Validator"
redirect_from: "/custom-rspec-meta-tag-validator/"
date: 2013-12-13 22:24:17
tags: [rspec, capybara, ruby]
comments: true
---
I’ve written my share of RSpec tests that look for specific meta tags in a web page under Capybara. It would be nice to be able to spell the following.

```ruby
visit "/"
page.should have_meta {
 "keywords" => "spline, reticulating",
 "description" => "Splines are being reticulated here."
}
```

Easy. This is my _spec/support/matchers/have_meta.rb_.

```ruby
class HaveMeta
 attr_accessor :expected_val, :actual_val, :attribute

 def initialize(expected)
   @expected = expected
 end

 def matches?(page)
   @expected.all? do |key, val|
     meta = page.find(:xpath, "//head/meta[@property='#{key}' or @name='#{key}']")
     self.actual_val = meta ? meta.native.attribute("content") : nil
     self.expected_val = val
     self.attribute = key
     actual_val.include? expected_val
   end
 end

 def failure_message_for_should
   "expected '#{attribute}' to contain '#{expected_val}' in '#{actual_val}'"
 end
end

def have_meta(expected)
 HaveMeta.new(expected)
end
```

This is a lot better than having to compare strings or making manual XPath queries.
