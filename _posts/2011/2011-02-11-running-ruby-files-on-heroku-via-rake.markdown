---
layout: post
title: "Running ruby files on Heroku via rake"
redirect_from: "/running-ruby-files-on-heroku-via-rake/"
date: 2011-02-11 04:33:57
tags: [rake, heroku, rails, ruby]
comments: true
dblog_post_id: 169
---
Let’s say you have some Ruby file that you want to run on [Heroku](https://heroku.com/). For example, I have _stuff\things.rb_. The easiest way to run the file on Heroku seems to inspire ourselves from db:seeds an write a Rake task in _lib/tasks/stuff_things.rake_.

{% highlight ruby %}
namespace :stuff do

  require 'logger'

  desc 'Run stuff/things.rb'
  task :things => :environment do
    file = File.join(Rails.root, 'stuff', 'things.rb')
    puts "Runnng #{file}"
    load(file) if File.exist?(file)
  end

end
{% endhighlight %}

You can run `heroku rake stuff:things`.

