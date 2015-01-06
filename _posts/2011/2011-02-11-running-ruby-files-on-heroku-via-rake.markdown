---
layout: post
title: "Running ruby files on Heroku via rake"
redirect_from: "/running-ruby-files-on-heroku-via-rake"
date: 2011-02-11 04:33:57
tags: [rake, heroku, rails, ruby]
comments: true
---
Let’s say you have some Ruby file that you want to run on [Heroku](http://heroku.com/). For example, I have _stuff\things.rb_. The easiest way to run the file on Heroku seems to inspire ourselves from db:seeds an write a Rake task in _lib/tasks/stuff_things.rake_.

```ruby
namespace :stuff do
 
  require 'logger'
  
  desc 'Run stuff/things.rb'
  task :things => :environment do
    file = File.join(Rails.root, 'stuff', 'things.rb')
    puts "Runnng #{file}"
    load(file) if File.exist?(file)
  end
 
end
```

You can run `heroku rake stuff:things`.

