---
layout: post
title: "RSpec: Fuubar + Breaking Tests into Suites"
redirect_from: "/rspec-fuubar-breaking-tests-into-suites"
date: 2011-08-16 12:34:29
tags: [rspec, art.sy, rake, rails, ruby, testing]
comments: true
---
Inspired by [this post](http://kpumuk.info/ruby-on-rails/my-top-7-rspec-best-practices/) on RSpec best practices and updated for RSpec2.

We’re rapidly approaching 2000 tests in our main project, adding about 100 tests every week. Everyone got really crafty at figuring out the optimal terminal window width to make the twenty or so rows of green and yellow dots from RSpec progress to align nicely. So we replaced the RSpec formatter with the awesome [Fuubar](https://github.com/jeffkreeftmeijer/fuubar) (see [introductory post](http://jeffkreeftmeijer.com/2010/fuubar-the-instafailing-rspec-progress-bar-formatter/)) which now gives us ETA and shows error details as they appear. Nice.

![]({{ site.url }}/images/posts/2011/2011-08-16-rspec-fuubar-breaking-tests-into-suites/image_11.jpg)

The really annoying part of RSpec is that tests can run in any order. This depends on file timestamps as RSpec globs the files. What I’d really want is to run short domain model tests first and long UI Capybara tests last. This way I’ll be catching errors sooner. Let's break the tests up into suites. Add _lib/tasks/test_suites.rake_. Note that _pattern_ can take an array and that this actually generates Rake tasks.

```ruby
require 'rspec/core/rake_task'

SPEC_SUITES = [
  { :id => :models, :title => 'model tests', :pattern => "spec/models/\*\*/\*_spec.rb" },
  { :id => :api, :title => 'api tests', :pattern => "spec/api/\*\*/\*_spec.rb" },
  { :id => :controllers, :title => 'controller tests', :pattern => "spec/controllers/\*\*/\*_spec.rb" },
  { :id => :views, :title => 'view tests', :pattern => "spec/views/\*\*/\*_spec.rb" },
  { :id => :misc, :title => 'misc tests',
      :pattern => ["spec/lib/\*\*/\*_spec.rb", "spec/mailers/\*\*/\*_spec.rb"] },
]

namespace :spec do
  namespace :suite do
    SPEC_SUITES.each do |suite|
      desc "Run all specs in #{suite[:title]} spec suite"
      RSpec::Core::RakeTask.new(suite[:id]) do |t|
        t.pattern = suite[:pattern]
        t.verbose = false
      end
    end
    desc "Run all spec suites"
    task :all => :environment do
      SPEC_SUITES.each do |suite|
        logger.info "Running #{suite[:title]} ..."
        Rake::Task["spec:suite:#{suite[:id]}"].execute
      end
    end
  end
end
```

Run `rake -T` for a list of generated tasks. We can now run `rake spec:suite:all` or individual suites with, for example, `rake spec:suite:models`.

