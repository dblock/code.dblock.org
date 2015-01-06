---
layout: post
title: "Introducing Gem-Licenses: Collect 3rd Party Licenses in RoR Projects"
redirect_from: "/introducing-gem-licenses-collect-3rd-party-licenses-in-ror-projects/"
date: 2011-07-26 17:16:50
tags: [rails, ruby, 3licenses, open source]
comments: true
---
Yet again I have to deal with 3rd party licenses, this time in RoR. It’s a pretty common thing to do for technical managers and in my last job I ended up creating [3licenses](https://github.com/dblock/3licenses/). For starters, we must know which open-source licenses are used. This can be a daunting exercise for large or complex projects. Then, you have to maintain the list and make sure it’s accurate with every release. Figuring out which licenses are used in 3rd party gems is relatively easy, because each gem spec contains a licenses array, we can do something like this.

```ruby
Gem.loaded_specs.each do |key, spec|
    spec.licenses.each do |license|
        puts "#{spec} => #{license}"
    end
end
```

But not so fast. Out of about 80 gems that we use, less than 10 had a proper license manifest. Half had a valid _LICENSE_ file that clearly stated which license they use and others carried a license that needed review, mostly matching the MIT license word-to-word. Three turned out not to have a license at all and reaching out to the component authors was needed.

Enter [gem-licenses](https://github.com/dblock/gem-licenses). It’s meant to be a skeleton for a project that can effectively guess which license a project uses. I did a rudimentary regex job, but I’d like someone to contribute a much more intelligent system to identify a project’s license.

Here’s a Rake task I added to our project. It generates a list of gems and licenses, good enough to start with to make a list.

```ruby
require 'gem_licenses'

task :licenses do
  Gem.licenses.each do |license, gems|
    puts "#{license}"
    gems.sort_by { |gem| gem.name }.each do |gem|
      puts "\* #{gem.name} #{gem.version} (#{gem.homepage}) - #{gem.summary}"
    end
  end
end
```

Finally, if you are a gem author, please take the time  to specify which license your project is published under in the .gemspec. If you’re using Jeweler, specify _gem.license_.

```ruby
Jeweler::Tasks.new do |gem|
  gem.name = "gem-licenses"
  gem.homepage = "http://github.com/dblock/gem-licenses"
  gem.license = "MIT"
  gem.summary = "List all gem licenses."
  gem.description = "Attempts to figure out what licenses various gems use."
  gem.email = "dblock@dblock.org"
  gem.authors = ["Daniel Doubrovkine"]
end
```

Now that we have the list of licenses we must ensure that we’re in compliance with the licenses. Listing those is the first step. Then we have to make sure that we’re not using any polluting licenses that require us to make any of our or our partner’s proprietary source code available. That’s something lawyers do.
