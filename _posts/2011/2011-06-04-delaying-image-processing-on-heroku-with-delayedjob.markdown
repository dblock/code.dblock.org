---
layout: post
title: "Delaying Image Processing on Heroku with delayed_job"
redirect_from: "/delaying-image-processing-on-heroku-with-delayedjob/"
date: 2011-06-04 20:11:20
tags: [heroku, mongodb, rails, ruby]
comments: true
---
**There’s a Gem for That Too**

In a previous article I described how to process an image in the Carrierwave pipeline to extract it’s geometry. It all works very well until a large amount of people start uploading high resolution images, including 100 megabyte TIFFs, all at once. I’ve noticed that this hogs a Heroku dyno for an extra 1 to 30 seconds depending on the image size. Today we’ll offload this processing into a queue with [delayed_job](https://github.com/collectiveidea/delayed_job). The latter was originally extracted from Shopify and continued development on [this fork](https://github.com/collectiveidea/delayed_job). We’ll throw in [delayed_job_mongoid](https://github.com/collectiveidea/delayed_job_mongoid), since we’re a MongoDB shop.

```ruby
gem "delayed_job", "2.1.4"
gem "delayed_job_mongoid", "1.0.2"
```

#### Extracting Image Geometry

We’ll use a simple example as our geometry processor. It reads the image and extracts it’s width and height.

```ruby
def get_geometry
    himage = ::Magick::Image::read(@file).first
    begin
     geometry = [himage.columns, himage.rows]
    ensure
      himage.destroy! if himage
    end
    geometry
end
```

Previously we would run this method before saving the image, making our users wait. Now we would like to delay this operation after the image has been saved. With _delayed_job_ this is not quite as simple as calling `.delay.get_geometry`. This method is going to execute asynchronously, so it requires more context, such as the model to update. The following variation is something that can actually be delayed.

```ruby
class ImageGeometryProcessor
  def process(id, file)
    himage = ::Magick::Image::read(file).first
    begin
      image = Image.find(id)
      image.update_attributes!({
          :best_width => himage.columns,
          :best_height => himage.rows
      })
    ensure
      himage.destroy! if himage
    end
  end
end
```

We’re passing in the id of the model to be updated and the image file that has just been uploaded. In our world we upload images to Amazon S3, so my first implementation would save the file being uploaded into a temporary location, would queue the job and finally delete the temporary file after processing finished. That worked well until I deployed the application to Heroku. Can you spot my beginner mistake?

On Heroku each dyno is an independent entity, a piece of virtual hardware with its own file system, memory and isolated disk space. Each dyno performing an upload would write the file to a temporary folder and the delayed job worker would be failing because it couldn’t find the file. Those two live on separate servers. This is actually a good thing - Heroku forced us to build truly parallel software, disk IO could easily be our next bottleneck.

We will now write a self-contained processor that gets the image url from the image before processing it. We’ll incur the cost of re-downloading the image, but it’s not as important since this is happening in the background.

```ruby
class ImageGeometryProcessor
  def process(id)
    image = Image.find(id)
    himage = ::Magick::Image::read(image.image_url).first
    begin
      image.update_attributes!({
          :best_width => himage.columns,
          :best_height => himage.rows
      })
    ensure
      himage.destroy! if himage
    end
  end
end
```

Let's trigger the geometry processor from the _after_save_ callback of our image.

```ruby
class Image
  after_save :saved

  def saved
    if image.file?
      # delay processing of image geometry
      ImageGeometryProcessor.new.delay.process(id)
    end
  end
end
```

Can you spot my second beginner mistake?

This may cause an infinite loop since _update_attributes_ executes callbacks, including _after_save_. An image will get processed, updated and then scheduled to be processed again after the update. The only thing protecting us is the fragile _image.file?_ that returns true if a file has just been uploaded. In the real world we do a lot more in this callback, so lets suppress callbacks from within the delayed job. My favorite solution is the following code placed in [config/initializers/without_callbacks.rb](https://gist.github.com/1008302).

Finally, the geometry processor can take some final shape.

```ruby
class ImageGeometryProcessor

  def process(id)
    image = Image.find(id)
    himage = ::Magick::Image::read(image.image_url).first
    begin
      Image.without_callbacks([:saved]) do
        image.update_attributes!({
          :best_width => himage.columns,
          :best_height => himage.rows
        })
      end
    ensure
      himage.destroy! if himage
    end
  end

end
```

#### Workers

To test this in a local environment run `rake jobs:work` in parallel to `rails server`. On Heroku you will have to add a worker dyno by running `heroku workers 1` as described in [http://devcenter.heroku.com/articles/delayed-job](http://devcenter.heroku.com/articles/delayed-job).

#### Viewing Workers

System administrators will find it convenient to see delayed jobs in the UI. [Here’s our view and controller](https://gist.github.com/1008298) that appear in the admin interface to get you started.

