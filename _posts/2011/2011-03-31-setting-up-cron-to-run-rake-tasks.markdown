---
layout: post
title: "Setting up Cron to run Rake Tasks"
redirect_from: "/setting-up-cron-to-run-rake-tasks"
date: 2011-03-31 14:40:43
tags: [rake, mongodb]
comments: true
---
![image]({{ site.url }}/images/posts/2011/2011-03-31-setting-up-cron-to-run-rake-tasks/image%5b6%5d.jpg)

This is the last piece of the dev-ops puzzle. We want our [MongoDB backup](http://code.dblock.org/ShowPost.aspx?id=192) to run nightly. Let's create a _:cron_ task

```ruby
task :cron => :environment do
  Rake::Task['db:production:backup'].invoke
end
```

We are going ot use [whenever](https://github.com/javan/whenever) to avoid the ugly syntax of cron. Whenever is configured in _config/schedule.rb_.

```ruby
set :output, "/tmp/cron_log.log"
 
every 1.day, :at => '3:30 am' do
  rake 'cron'
end
```

To propagate the settings to crontab, use the following command.

```
$ whenever --update-crontab
```

All credit for this one goes to [@sarcilav](http://blog.sarcilav.com/) – I wanted to wrap up our dev-ops story in one place on my blog.
