---
layout: post
title: "Setting up Cron to run Rake Tasks"
redirect_from: "/setting-up-cron-to-run-rake-tasks/"
date: 2011-03-31 14:40:43
tags: [rake, mongodb]
comments: true
dblog_post_id: 193
---
![]({{ site.url }}/images/posts/2011/2011-03-31-setting-up-cron-to-run-rake-tasks/image_6.jpg)

This is the last piece of the dev-ops puzzle. We want our [MongoDB backup](/2011/03/31/a-rake-task-for-backing-up-a-mongodb-database.html) to run nightly. Let's create a _:cron_ task

{% highlight ruby %}
task :cron => :environment do
  Rake::Task['db:production:backup'].invoke
end
{% endhighlight %}

We are going ot use [whenever](https://github.com/javan/whenever) to avoid the ugly syntax of cron. Whenever is configured in _config/schedule.rb_.

{% highlight ruby %}
set :output, "/tmp/cron_log.log"

every 1.day, :at => '3:30 am' do
  rake 'cron'
end
{% endhighlight %}

To propagate the settings to crontab, use the following command.

```
$ whenever --update-crontab
```

All credit for this one goes to [@sarcilav](https://web.archive.org/web/20120629110557/https://blog.sarcilav.com//) – I wanted to wrap up our dev-ops story in one place on my blog.
