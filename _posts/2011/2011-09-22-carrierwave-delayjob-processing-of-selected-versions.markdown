---
layout: post
title: "CarrierWave: DelayJob-Processing of Selected Versions"
redirect_from: "/carrierwave-delayjob-processing-of-selected-versions/"
date: 2011-09-22 23:30:43
tags: [carrierwave, s3, rails, ruby]
comments: true
dblog_post_id: 271
---
Our image upload pipeline has gotten a bit too long and no longer fits in the Heroku’s 30-second limit. We generate several image versions and would like to get a couple of sizes first and the larger processors to be delayed.  I’ve looked at a few solutions, first.

- [This article](https://www.randygirard.com/how-to-use-delayed-job-to-handle-your-carrierwave-processing/) describes how to delay all processors, but stores the original file for all versions, first. Other than being wasteful it has a real problem for the Cloudfront cache – if some large image were to be cached before the delayed job can resize it, we’d get an image of a wrong size for 24 hours.
- The [carrierwave_backgrounder](https://github.com/lardawge/carrierwave_backgrounder) gem is a better candidate. Unfortunately it relies on a local store and doesn’t work in a distributed environment. I think it shouldn’t be too hard to fetch the original image and then invoke the processors, but I wasn’t ready for a day-long project and it doesn’t quite do what I want – process some versions in the background.

So, here’s a slightly hacky solution to delay-processing of select [CarrierWave](https://github.com/jnicklas/carrierwave) image versions.

Let's make all processing conditional upon _:is_processing_delayed?_ and _:is_processing_immediate?_. You see where this is going.

{% highlight ruby %}
class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  def is_processing_delayed?(img = nil)
    !! @is_processing_delayed
  end

  def is_processing_immediate?(img = nil)
    ! is_processing_delayed?
  end

  def is_processing_delayed=(value)
    @is_processing_delayed = value
  end

  version :small, :if => :is_processing_immediate? do
    process :resize_to_limit => [200, 200]
  end

  version :medium, :if => :is_processing_immediate? do
    process :resize_to_limit => [260, 260]
  end

  version :watermarked, :if => :is_processing_delayed? do
    process :watermark
  end

  ...
end
{% endhighlight %}

By default processing is immediate, there’s nothing to do. Add the following to the model that is holding the uploader.

{% highlight ruby %}
def recreate_delayed_versions!
    image.is_processing_delayed = true
    image.recreate_versions!
end
{% endhighlight %}

Then delay the method normally in the model’s `after_save` with `self.delay.recreate_delayed_versions!` – that’s it.

It almost looks too simple. Improvements? Suggestions?
