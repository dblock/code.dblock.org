---
layout: post
title: "How To Convert Numbers Into Words in Ruby (with numbers_and_words)"
redirect_from: "/how-to-convert-numbers-into-words-in-ruby-with-numbersandwords/"
date: 2012-03-23 21:37:49
tags: [ruby]
comments: true
---
You’d think someone has implemented simple conversion of numbers into English by now? For example 42 becomes "forty-two".

I found a few interesting posts, a couple of gems and even a competition. All had issues that fit in two buckets: they could only do English or their implementation was scary. While I didn’t really _need_ a converter that worked for different languages, none of the libraries inspired much confidence. Finally, I ran into a I18n implementation that was generic, well implemented and properly tested for Russian. It needed some minor English work, but you can be sure that the Russian version is _much_ more complicated.

A few pull requests later, please welcome a new gem, [numbers_and_words](https://github.com/kslazarev/numbers_and_words). [Kirill](https://github.com/kslazarev/) designed the library with conversion strategies and proper localization in-mind.

```ruby
I18n.with_locale(:en) { 42.to_words }
I18n.with_locale(:ru) { 42.to_words }
```

These produce "forty-two" and "сорок два".

And a fun one.

```ruby
2935174315119654654654654654.to_words
```

This is obviously _"two octillion nine hundred thirty-five septillion one hundred seventy-four sextillion three hundred fifteen quintillion one hundred nineteen quadrillion six hundred fifty-four trillion six hundred fifty-four billion six hundred fifty-four million six hundred fifty-four thousand six hundred fifty-four"_.

Can someone please contribute a Spanish version next?

[https://github.com/kslazarev/numbers_and_words](https://github.com/kslazarev/numbers_and_words)
