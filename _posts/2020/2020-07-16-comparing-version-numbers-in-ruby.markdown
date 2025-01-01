---
layout: post
title: "Comparing Version Numbers in Ruby"
date: 2020-07-16
tags: [ruby]
comments: true
---
Time and [again](https://github.com/ruby-grape/grape/pull/2091#discussion_r455763685), and [again](https://github.com/opensearch-project/opensearch-ruby/pull/76#discussion_r910422525), developers fail to compare gem or ruby version numbers correctly. It's an easy mistake to make.

```ruby
> RUBY_VERSION
 => "2.6.6"
> RUBY_VERSION > '2.7.7'
 => false # ok
> RUBY_VERSION > '2.6.5'
 => true # ok
> RUBY_VERSION > '2.10.0'
 => true # ouch
```

Using `to_f` is another common mistake.

```ruby
> RUBY_VERSION
 => "2.10.0"
> RUBY_VERSION.to_f < 2.7
 => false # ouch
> RUBY_VERSION.to_f
 => 2.1
```

There's a [great post](https://metaredux.com/posts/2018/10/28/a-better-way-to-compare-versions-in-ruby.html) that comes up on top of Google that recommends using `Gem::Version`.

```ruby
> Gem::Version.new(RUBY_VERSION)
 => #<Gem::Version "2.6.6">
> Gem::Version.new(RUBY_VERSION) > Gem::Version.new('2.7.7')
 => false # ok
> Gem::Version.new(RUBY_VERSION) > Gem::Version.new('2.6.5')
 => true # ok
 > Gem::Version.new(RUBY_VERSION) > Gem::Version.new('2.10.0')
 => false # ok
```

This works correctly, including for pre-release versions.

```ruby
> Gem::Version.new(RUBY_VERSION) > Gem::Version.new('2.6.6.pre1')
 => true
```

However, especially in this last case it may not be what you want. In fact, it's almost never what you want. Consider the following example with `RUBY_VERSION = 2.6.6.pre1`.

```ruby
if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.6.6')
  # this code works with any 2.6.6, including 2.6.6.pre1
else
  # this code works with 2.6.5 or older
end
```

This doesn't work because "2.6.6.pre1" is not newer than "2.6.6".

```ruby
> Gem::Version.new('2.6.6.pre1') >= Gem::Version.new('2.6.6')
 => false
 ```

The desired effect can be achieved easily.

```ruby
if Gem::Version.new(RUBY_VERSION).release >= Gem::Version.new('2.6.6')
  # this code works with any 2.6.6, including 2.6.6.pre1
else
  # this code works with 2.6.5 or older
end
```

Another common pattern that I have observed is to check versions at runtime.

```ruby
def do_something
  if Gem::Version.new(RUBY_VERSION).release >= Gem::Version.new('2.6.6')
    # this code works with any 2.6.6, including 2.6.6.pre1
  else
    # this code works with 2.6.5 or older
  end
end
```

Avoid evaluating this `if` multiple times by declaring different methods depending on the Ruby version.

```ruby
if Gem::Version.new(RUBY_VERSION).release >= Gem::Version.new('2.6.6')
  def do_something
    # this code works with any 2.6.6, including 2.6.6.pre1
  end
else
  def do_something
    # this code works with 2.6.5 or older
  end
end
```

We can also hide this implementation detail in some cases using the [with-version](https://github.com/dblock/with-version) gem. Consider contributing to support more if-then-else scenarios.

```ruby
with_minimum_ruby '2.6.6' do
  # this code works with 2.6.6 or newer, including 2.6.6.pre1
end
```
