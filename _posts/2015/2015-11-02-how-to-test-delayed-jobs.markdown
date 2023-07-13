---
layout: post
title: "How To Test Delayed Jobs"
date: 2015-11-02
tags: [testing, delayed job, ruby, rspec]
comments: true
---
There're two ways to test [delayed jobs](https://github.com/collectiveidea/delayed_job) under RSpec.

The first is to use the library "as is", invoking `Delayed::Worker.new.work_off` and examining the job results.

{% highlight ruby %}
# create a new spline
spline = Spline.new(reticulated: false)

expect do
  # reticulate a spline in a delayed job
  spline.delay.reticulate!
end.to change(Delayed::Job, :count).by(1)

# execute all delayed jobs, successful jobs are deleted
expect do
  Delayed::Worker.new.work_off
end.to change(Delayed::Job, :count).by(-1)

expect(spline.reload.reticulated?).to be true
{% endhighlight %}

Unfortunately, this requires a lot of extra work to reach exceptions generated inside the delayed job worker.

A second solution that immediately executes delayed jobs has the advantage of failing loudly, predictably, and inline within your tests.

Create and `require` a `spec/support/delayed_job.rb` in your `spec_helper.rb`.

{% highlight ruby %}
RSpec.configure do |config|
  config.before do
    Delayed::Worker.delay_jobs = false
  end
end
{% endhighlight %}

This causes immediate execution of the job in the [following code](https://github.com/collectiveidea/delayed_job/blob/v4.1.0/lib/delayed/backend/base.rb#L35).

{% highlight ruby %}
Delayed::Worker.delay_job?(job) ? job.save : job.invoke_job
{% endhighlight %}

[Since 4.1.0](https://github.com/collectiveidea/delayed_job/commit/ce88693429188a63793b16daaab67056a4e4e0bf), `Delayed::Worker.delay_jobs` can also be a `Proc`. You may want to delay jobs that are scheduled in the future and immediately execute all other jobs. This is our default setup in [Ruby projects at Artsy](https://artsy.github.io).

{% highlight ruby %}
RSpec.configure do |config|
  config.before do
    Delayed::Worker.delay_jobs = ->(job) {
      job.run_at && job.run_at > Time.now.utc
    }
  end
end
{% endhighlight %}

If you must turn off this behavior in a specific test, set `Delayed::Worker.delay_jobs` to `true`.
