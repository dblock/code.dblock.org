---
layout: post
title: "RSpec + Capybara Don’t Return a Proper Exit Code"
redirect_from: "/rspec-capybara-dont-return-a-proper-exit-code/"
date: 2011-06-23 16:19:53
tags: [rails, ruby, open source, testing, people]
comments: true
dblog_post_id: 221
---
We’ve been trying to fix an issue with our continuous integration where Capybara tests were failing, but the CI process reported success. Rather annoying for CI!

We started by adding some logging to our test Rake task to see the error code returned from RSpec. This shows the PID and the exit code, explicitly failing when the exit status is either false or a non-zero error code.

```ruby
rc = system("bundle exec rspec spec")
logger.info "rspec spec #{$?}"
fail "rspec spec failed with exit code #{$?.exitstatus}" if (rc.nil? || ! rc || $?.exitstatus != 0)
```

The culprit turned out to be a bug in Ruby ([#4400](http://redmine.ruby-lang.org/issues/show/4400), present in 1.9.2-p180) where nested _at_exit_ calls are not unwound in reverse order of registration. There’s a long thread ( [capybara #178](https://github.com/jnicklas/capybara/issues/178)) that discusses it. What happens is that the Capybara driver registers an _at_exit_ block to terminate the browser, which executes after the RSpec _at_exit_ block and causes the calling process to loose a previously set exit code. There’s a neat workaround that was committed to minitest ([diff](https://github.com/seattlerb/minitest/commit/979406d726fa1866aba6dc4e3ed7692a4758c0ec)) and applying the same workaround to _rspec-core_ ([pull #410](https://github.com/rspec/rspec-core/pull/410), [diff](https://github.com/dblock/rspec-core/commit/1cf9265989e976888baf7ea838ba70e50b5f4707), or just try [my fork](https://github.com/dblock/rspec-core)) resolves this issue. I hope rspec-core takes my pull request, it looks pretty innocent.

There’s also a fun part to the story: [@febuiles](http://twitter.com/febuiles) who I had the pleasure to work with for a bit, tweeted this:

![]({{ site.url }}/images/posts/2011/2011-06-23-rspec-capybara-dont-return-a-proper-exit-code/image_5.jpg)

That’s what I love about open-source, it’s a small world that enables quick and meaningful impact.
