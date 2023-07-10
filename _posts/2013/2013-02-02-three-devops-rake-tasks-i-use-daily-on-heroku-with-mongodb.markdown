---
layout: post
title: "Three DevOps Rake Tasks I Use Daily on Heroku with MongoDB"
redirect_from: "/three-devops-rake-tasks-i-use-daily-on-heroku-with-mongodb/"
date: 2013-02-02 06:21:21
tags: [deployment, mongoid, rake, heroku, mongodb]
comments: true
dblog_post_id: 373
---
![]({{ site.url }}/images/posts/2013/2013-02-02-three-devops-rake-tasks-i-use-daily-on-heroku-with-mongodb/image_3.jpg)

Heroku and MongoDB enable the kind of frictionless devops workflow every mature software organization wants and spends mountains of money on. It begins with a 1-box developer setup in which I can checkout source code and be ready to start development after a _bundle install, _and continues with a _git push_ to a Heroku staging environment that deploys the application for last minute integration testing  and, finally, production. Each separate Heroku instance has its own configuration and resources. My code also needs sensible defaults for development. For example, _mongoid.yml_ lists _localhost:27017_ as the development database host and _ENV['MONGOHQ_HOST_LIST']_ for production.

However, in true devops, I want to be able to reach into a remote environment programmatically, run commands remotely or connect two environments together, as long as we have access to them. In this post I’ll propose an implementation of three tasks that have become part of the daily routine of one of my projects.

1. Execute a Rake task with local code modifications and the configuration of a production environment.
2. Open a shell to the primary node of the MongoDB on my development Heroku environment.
3. Dump a single table from a production database before doing something scary.

We’ll accomplish the above with help from two new gems: [mongoid-shell](https://github.com/dblock/mongoid-shell) and [heroku-commander](https://github.com/dblock/heroku-commander). Add those to your Gemfile in the _:development_ section.

And, please remember, that with great power (and the word "production" in much of what follows) comes a lot of responsibility.

#### Execute a Rake task with local code modifications and the configuration of a production environment.

This is made possible by [heroku-commander](https://github.com/dblock/heroku-commander). The library wraps the Heroku CLI (intro [here](https://artsy.github.io/blog/2013/01/31/create-mongodb-command-lines-with-mongo/)) and will run _heroku config –s_. It’s now easy to reach out to a Heroku application and retrieve its configuration programmatically without worrying about API keys (by default it will use the Heroku app defined via the "heroku" GIT remote). We will also need a bit of code to apply our application’s naming convention. This lets me change the execution environment to the one of a remote Heroku application, in Ruby.

{% highlight ruby %}
module Heroku
 class Config < Hash
   def self.set_env_from!(env)
     app = case env.to_sym
       when :heroku, :development then nil
       else "app-#{env}"
     end
     require 'heroku-commander'
     config = Heroku::Commander.new({ :app => app }).config
     config.each do |k, v|
       ENV[k] = v
     end
   end
 end
end
{% endhighlight %}

So how do I run a task locally, but configured as _production_? With the following Rake task.

{% highlight ruby %}
namespace :heroku do
 desc "Load environment vars from Heroku config into ENV."
 task :config_from_env do
   env = ENV['RAILS_ENV'] || Rails.env
   raise "RAILS_ENV or Rails.env must be specified" unless env
   Heroku::Config.set_env_from! env
 end
end
{% endhighlight %}

Run `RAILS_ENV=production rake heroku:config_from_env my:task`.

#### Open a shell to the primary node of the MongoDB on my development Heroku environment.

First, figure out the remote MongoDB configuration, then execute the _mongo_ shell command. It’s important to know that the built-in system command doesn’t raise an error when the process returns a non-zero status code. Let's add a _system!_ function that fixes that.

{% highlight ruby %}
def system!(cmdline)
 logger.info("[#{Time.now}] #{cmdline}")
 rc = system(cmdline)
 fail "failed with exit code #{$?.exitstatus}" if (rc.nil? || ! rc || $?.exitstatus != 0)
end
{% endhighlight %}

Instead of making MongoDB command lines manually, I’ve used a new gem called [mongoid-shell](https://github.com/dblock/mongoid-shell) (intro [here](https://artsy.github.io/blog/2013/01/31/create-mongodb-command-lines-with-mongo/)).

{% highlight ruby %}
namespace :db do
 [:staging, :production, :heroku].each do |env|
   namespace env do
     task :shell do
       require 'mongoid-shell'
       Heroku::Config.set_env_from!(env)
       config = File.join(Rails.root, "config/mongoid.yml")
       Mongoid.load! config, env
       system! Mongoid::Shell::Commands::Mongo.new.to_s
     end
   end
 end
end
{% endhighlight %}

Run `rake db:production:shell`.

#### Dump a single table from a production database before doing something scary.

We all do backups and other important things, daily. But when manipulating production data I want to have the last safeguard with the freshest data from the collection I am about to update. Dump a MongoDB collection locally.

{% highlight ruby %}
namespace :db do
 [:production, :staging, :heroku].each do |env|
   namespace env do
     task :dump, [:collections] => :environment do |t, args|
       require 'mongoid-shell'
       Heroku::Config.set_env_from!(env)
       config = File.join(Rails.root, "config/mongoid.yml")
       Mongoid.load! config, env
       collections = args[:collections].split(/[\s|,]+/)
       collections.each do |collection|
         system! Mongoid::Shell::Commands::Mongodump.new({ collection: collection }).to_s
       end
     end
   end
 end
end
{% endhighlight %}

#### Points

Thanks to [@joeyAghion](https://twitter.com/joeyAghion) and [@fancyremarker](https://twitter.com/fancyremarker) who are responsible for many of the core concepts above.
