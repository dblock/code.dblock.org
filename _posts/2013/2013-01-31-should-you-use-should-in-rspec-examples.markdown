---
layout: post
title: "Should you use 'Should' in RSpec Examples?"
redirect_from: "/should-you-use-should-in-rspec-examples/"
date: 2013-01-31 12:55:37
tags: [rspec, ruby, testing]
comments: true
dblog_post_id: 372
---
There’re two kinds of developers: those who use _should_ in RSpec examples and those who use present tense.

{% highlight ruby %}
describe Fridge do
  when "plugged in" do
    before do
      subject.plug!
    end

    it "should keep food cold" do
      subject.temperature.should be between(35).and(38).degrees
    end
  end
end
{% endhighlight %}

{% highlight ruby %}
describe Fridge do
  when "plugged in" do
    before do
      subject.plug!
    end

    it "keeps food cold" do
      subject.temperature.should be between(35).and(38).degrees
    end
  end
end
{% endhighlight %}

Should you use _should_?

My short answer is **no** , you shouldn’t. Write your examples in present tense. Two reasons.

- BDD often refers to examples as documentation. Imagine that your fridge’s documentation said "when plugged in, it should keep food cold". IMO it should say "when plugged in, it keeps food cold".
- Using "should" makes the text longer by a few characters. We have over [3000 specs in one projects](https://artsy.github.io/blog/2012/05/15/how-to-organize-over-3000-rspec-specs-and-retry-test-failures/), probably saving a megabyte worth of test descriptions by not using "should". Shorter is better.

Thx [@mzikherman](https://twitter.com/mzikherman) for heavily contributing to this thought.
