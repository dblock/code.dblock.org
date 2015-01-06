---
layout: post
title: "Carrierwave: Saving Best Image Geometry"
redirect_from: "/carrierwave-saving-best-image-geometry"
date: 2011-04-04 15:54:14
tags: [rails, ruby]
comments: true
---
I recently needed to find out the geometry of the image being uploaded via Carrierwave. Images come in many different sizes and shapes. What I want is to have a "best" image and store its actual size along with my image model.

#### Define a Best Image

First, lets define a "best" version of the image. That’s one that’s not being resized, only converted into JPG.

```ruby
class ArtworkUploader < CarrierWave::Uploader::Base
  version :best do
    process :convert => 'jpg'
  end
end
```

#### Fetch Geometry on Upload

Notice the process declarations above: both _resize_to_limit_ and _convert_ are methods of the uploader class. We can therefore add a new _get_geometry_ function and store the geometry of the uploaded image with this version.

```ruby
class ArtworkUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  version :best do
    process :convert => 'jpg'
    process :get_geometry

    def geometry
      @geometry
    end
  end

  def get_geometry
    if (@file)
      img = ::Magick::Image::read(@file.file).first
      @geometry = [img.columns, img.rows]
    end
  end
end
```

#### Save Geometry

Finally, we would like to store _best_width_ and _best_height_ with the _Image_ model. We use MongoId, so we can fetch the geometry _before_save_.

```ruby
class Image

  field :best_width
  field :best_height

  before_save :saving

  def saving
    geometry = self.image.best.geometry
    if (! geometry.nil?)
      self.best_width = geometry[0]
      self.best_height = geometry[1]
    end
  end

end
```

I think image geometry should be a built-in function and property of Carrierwave. Maybe this can be improved further and make it into the library?
