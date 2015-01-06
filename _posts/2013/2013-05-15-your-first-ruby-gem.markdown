---
layout: post
title: "Your First Ruby Gem"
redirect_from: "/your-first-ruby-gem/"
date: 2013-05-15 01:53:08
tags: [ruby, open source]
comments: true
---
![](http://photos1.meetupstatic.com/photos/event/6/5/a/3/global_20906019.jpeg)

I live-coded a new gem called [Ruby::Enum](https://github.com/dblock/ruby-enum) at [NYC.rb](http://www.meetup.com/NYC-rb/events/88141492/) on Tuesday. This library adds enum-like functionality to Ruby.

Here’s my checklist for creating a new gem.

#### Check the Name

Ruby gems are registered with [Rubygems](http://rubygems.org/) and managed in your projects using [Bundler](http://gembundler.com/). Search for the new gem name on Rubygems to make sure it's not taken.

#### Create a Folder

I organize all my code in _source_ and since I often fork code from others to contribute, create a subfolder with the Github username, including mine.

```
$ mkdir ~/source/ruby-enum/dblock
$ cd ~/source/ruby-enum/dblock
```

#### Initialize a Git Repository

```
$ git init
Initialized empty Git repository in /home/dblock/source/ruby-enum/dblock/.git/
```

#### Create a Github Repo

Create a new repository on [Github](http://github.com/).

![]({{ site.url }}/images/posts/2013/2013-05-15-your-first-ruby-gem/image4.jpg)

Add it as a remote.

```
$ git remote add origin git@github.com:dblock/ruby-enum.git
```

#### Create a Readme

Documentation is written in Markdown. Create and commit a _README.md_.

```
$ git commit -m "Added README."
[master acc5880] Added README.
1 file changed, 4 insertions(+)
create mode 100644 README.md
```

Push the README to Github.

```
$ git push origin master
Counting objects: 6, done.
Compressing objects: 100% (5/5), done.
Writing objects: 100% (6/6), 963 bytes, done.
Total 6 (delta 0), reused 0 (delta 0)
To git@github.com:dblock/ruby-enum.git
* [new branch]      master -> master
```

#### Add a License

Every project needs a license. I use [the MIT license](https://github.com/dblock/ruby-enum/blob/master/LICENSE.md) because it’s short and nobody has time to read licenses. Add a copyright notice to the README, don't forget future contributors.

```
Copyright (c) 2013, Daniel Doubrovkine and Contributors. All Rights Reserved.
This project is licenced under the [MIT License](LICENSE.md).
```

#### Gemfile

A Gemfile is something that comes with [Bundler](http://gembundler.com/) and declares gem dependencies.

Install Bundler.

```
$ gem install bundler
Fetching: bundler-1.3.5.gem (100%)
Successfully installed bundler-1.3.5
1 gem installed
Installing ri documentation for bundler-1.3.5...
Installing RDoc documentation for bundler-1.3.5...
```

Create a Gemfile. For now it just says where to get other gems from.

```ruby
source "http://rubygems.org"
```

Run `bundle install`.

```
$ bundle install
Resolving dependencies...
Your bundle is complete! Use `bundle show [gemname]` to see where a bundled gem is installed.
```

#### .gitignore

The generated Gemfile.lock should not be included, create a _.gitignore_.

```
Gemfile.lock
```

#### Enum Library

Create _lib/ruby-enum.rb _and _lib/ruby-enum/version.rb_.

```ruby
require 'ruby-enum/version'

module Ruby::Enum
  VERSION = '0.1.0'
end
```

#### Tests

You. Must. Test.

Add RSpec to _Gemfile_.

``` ruby
gem "rspec"
```

Tests need some setup, specifically to load the code in _lib_. Create _spec/spec_helper.rb_.

```ruby
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rspec'
require 'ruby-enum'
```

Create a test in _spec/ruby-enum/version.rb_.

```ruby
require 'spec_helper'
describe Ruby::Enum do
  it "has a version" do
    Ruby::Enum::VERSION.should_not be_nil
  end
end
```

Add .rspec to pretty-print test output.

```
--format documentation
--color
```

#### Gem Declaration

A _ruby-enum.gemspec_ is a gem declaration.

```ruby
$:.push File.expand_path("../lib", __FILE__)
require "ruby-enum/version"
Gem::Specification.new do |s|
  s.name = "ruby-enum"
  s.version = Ruby::Enum::VERSION
  s.authors = ["Daniel Doubrovkine"]
  s.email = "dblock@dblock.org"
  s.platform = Gem::Platform::RUBY
  s.required_rubygems_version = '>= 1.3.6'
  s.files = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
  s.homepage = "http://github.com/dblock/ruby-enum"
  s.licenses = ["MIT"]
  s.summary = "Enum-like Behavior for Ruby"
end
```

The declaration can be loaded in _Gemfile_, so that we can list dependencies in one place.

```ruby
source "http://rubygems.org"
gemspec
```

When running under Bundler, the _Gemfile_ will automatically be loaded, which will automatically load the gem specification.

```
$ bundle exec irb
1.9.3-p362 :001 > require 'ruby-enum'
=> true
1.9.3-p362 :002 > Ruby::Enum::VERSION
=> "0.1.0"
```

#### Rakefile

Bundler comes with a number of Rake tasks to release a gem. Add Rake to Gemfile.

```ruby
gem "rake"
```

Create a _Rakefile_.

```ruby
require 'rubygems'
require 'bundler/gem_tasks'
Bundler.setup(:default, :development)

$ rake -T
rake build    # Build ruby-enum-0.1.0.gem into the pkg directory.
rake install  # Build and install ruby-enum-0.1.0.gem into system gems.
rake release  # Create tag v0.1.0 and build and push ruby-enum-0.1.0.gem to Rubygems

$ rake build
ruby-enum 0.1.0 built to pkg/ruby-enum-0.1.0.gem.

Add _pkg_ to _.gitignore_.
```

#### Default Rakefile to Running Tests

```ruby
require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec
```

#### Travis-CI

Add _.travis.yml_, register the project on [travis-ci.org](https://travis-ci.org/) and add a badge.

```yaml
rvm:
  - 1.8.7
  - 1.9.3
  - 2.0.0
  - jruby-19mode
  - rbx-19mode
```

```
[![Build Status](https://travis-ci.org/dblock/ruby-enum.png)](https://travis-ci.org/dblock/ruby-enum)
```

![]({{ site.url }}/images/posts/2013/2013-05-15-your-first-ruby-gem/image5_1.jpg)

#### Enum Library Code

Include _ruby-enum/enum_. See [enum.rb](https://github.com/dblock/ruby-enum/blob/master/lib/ruby-enum/enum.rb) and [enum_spec.rb](https://github.com/dblock/ruby-enum/blob/master/spec/ruby-enum/enum_spec.rb) for the implementation.

#### Changelog

Create a CHANGELOG to list current and future updates.

```md
### 0.1.0 (5/14/2013)

* Initial public release - [@dblock](https://github.com/dblock).
```

#### Contributing

Add a contributing section to README.

```md
* Fork the project.
* Make your feature addition or bug fix with tests.
* Update CHANGELOG.
* Send a pull request. Bonus points for topic branches.
```

#### Release the Gem

```
$ rake release
```

#### Prepare for Next Release

Bump the version, add a _Next Release_ section to CHANGELOG.md.

```
### Next Release (TBD)

* Your Contribution Here
```

#### Source Code

All source code for the above can be found at [https://github.com/dblock/ruby-enum](https://github.com/dblock/ruby-enum).
