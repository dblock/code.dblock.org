---
layout: post
title: "Carrierwave: Full Control over Changing (S3) Upload Path Name"
redirect_from: "/carrierwave-full-control-over-changing-s3-upload-path-name"
date: 2011-03-22 11:59:55
tags: [s3, rails, ruby]
comments: true
---
Today, we will be uploading JPG, BMP or TIFF images to Amazon S3 that are attached to a model.

We also need to upload images to different S3 buckets for different Heroku applications (personal, dev, staging). We also would like to upload images locally for development purposes and fake upload when writing RSpec tests. We handle this with a gem called [Carrierwave](https://github.com/jnicklas/carrierwave). I’ve seen components that do this in many languages, but  I challenge you to get end-to-end multi-file upload in 20 lines of code or less in an hour. I continue to be amazed by how many similar problems have been solved with reusable components, tribute to the successful combination of Ruby, Rails, Github and open-source practices that actually work.

I needed to change the directory structure and the naming of the files. We started with defining _paperclip_path - _Carrierwave is an improvement over [Paperclip](https://github.com/thoughtbot/paperclip), a system to attach files to ActiveRecord records and has some backward compatibility elements. We use the same uploader for two related models, so it was convenient to define a single template path.

```ruby
include CarrierWave::Compatibility::Paperclip
 
def paperclip_path
   ":class/:id/:basename_:style.:extension"
end
```

Next, we wanted to change the _:id_ in the path to _:slug_ – an auto-generated short name with [mongoid_slug](https://github.com/papercavalier/mongoid-slug). Looking at the Paperclip-compatibility code it was clearly not possible without rewriting the whole thing.

Carrierwave recommends [overriding store_dir in the uploader](http://groups.google.com/group/carrierwave/browse_thread/thread/54a2860211109780), but it only gives you a way to modify the directory name, not the whole path with the file name. Digging through the source, I found a way to change the entire path by overriding _store_path_. Note how we access the model being uploaded with _model_.

```ruby
def store_path(for_file = filename)
  self.model.class.name.underscore.pluralize + "/" + self.model.slug + "/" + (version_name || :original).to_s + ".jpg"
end
```
