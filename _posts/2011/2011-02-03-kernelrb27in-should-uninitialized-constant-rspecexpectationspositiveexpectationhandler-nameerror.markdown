---
layout: post
title: "kernel.rb:27:in `should': uninitialized constant RSpec::Expectations::PositiveExpectationHandler (NameError)"
redirect_from: "/kernelrb27in-should-uninitialized-constant-rspecexpectationspositiveexpectationhandler-nameerror/"
date: 2011-02-03 23:23:44
tags: [rails, ruby, testing]
comments: true
dblog_post_id: 167
---
This one took a while and required extensive help from a rocket scientist. While running RSpec I got this.

```
.../test/ruby/1.9.1/bundler/gems/rspec-expectations-68f857b9b668/lib/rspec/expectations/extensions/kernel.rb:27:
  in `should': uninitialized constant RSpec::Expectations::PositiveExpectationHandler (NameError)
```

The problem was that you need to configure the expectations framework in _spec/spec_helper.rb_. The _expect_with :rspec_ is the fix.

{% highlight ruby %}
RSpec.configure do |config|
    config.mock_with :rspec
    config.expect_with :rspec
end
{% endhighlight %}

You can read more about rspec configuration [here](https://rspec.help/rspec/expectation-framework-integration/).
