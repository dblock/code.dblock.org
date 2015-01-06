---
layout: post
title: "Serving Compressed Rails Assets from S3 via Cloudfront"
redirect_from: "/serving-compressed-rails-assets-from-s3-via-cloudfront/"
date: 2011-12-09 04:56:19
tags: [cloudfront, s3, rails, ruby]
comments: true
dblog_post_id: 299
---
I wrote about how we do asset packaging with Rails, how we Jammit and push them to S3 in [this post](/rails-s3-cloudfront-jammit-heroku-100). We’ve had a few surprises since then, one that had to do with compressed assets.

If a browser sends an _Accept-Encoding: gzip _header for a resource that has both an uncompressed and a compressed copy (eg. _client.js_ and _client.js.gz_), the server can respond with the compressed version of the file along with the original Content-Type (eg. _text/css_) and _Content-Encoding: gzip_ headers. This is called content negotiation. Unfortunately S3 has very poor negotiation skills. CloudFront CDN does better, but only if the server behind it supports it. So putting a CloudFront in front of S3 produces the same effect and Amazon recommends using a custom origin server (a fancy word for another web server), other than S3 if you want to enable content negotiation. We’d rather not serve static assets from Heroku because it requires checking them into source control. And we’d rather not add a web server that we have to maintain – too much infrastructure when multiplied by the number of developers.

The solution is, as usual, to monkey-patch rails. We’re going to tell our Rails application to serve a compressed file if the browser includes the right headers by rendering an URL to the compressed version.

In Rails 3.0 (your mileage will vary for 3.1) paths to assets are written via [ActionView::Helpers::AssetTagHelper](http://api.rubyonrails.org/v3.0.9/classes/ActionView/Helpers/AssetTagHelper.html)’s _path_to_javascript_ and _path_to_stylesheet_. We can figure out browser capabilities by examining _request.env['HTTP_ACCEPT_ENCODING']_ and rewrite those URLs to our liking.

```ruby
module ActionView
  module Helpers
    module AssetTagHelper
      def accept_encoding?(encoding)
        (request.env['HTTP_ACCEPT_ENCODING'] || '').split(',').include?(encoding)
      end
      def rewrite_path_to_gzip?(source)
        (! config.asset_host.blank?) and (source =~ /assets\//) and accept_encoding?('gzip')
      end
      def path_to_javascript(source)
        source = rewrite_path_to_gzip(source) if rewrite_path_to_gzip?(source)
        compute_public_path(source, 'javascripts', 'js')
      end
      def path_to_stylesheet(source)
        source = rewrite_path_to_gzip(source) if rewrite_path_to_gzip?(source)
        compute_public_path(source, 'stylesheets', 'css')
      end
      def rewrite_path_to_gzip(source)
        source + ".cgz"
      end
    end
  end
end
```

[config/initializers/asset_tag_helper.rb and spec/initializers/rails/asset_tag_helper_spec.rb](https://gist.github.com/1451946)_

The .cgz extension replaces the .gz extension to workaround a [bug in Safari](http://stackoverflow.com/questions/1235116/safari-and-gzip). The `rewrite_path_to_gzip?` check ensures that we’re rendering something under _assets_ and that we’re using an external server (not in development). Your condition may be different.

Finally, we must set the proper content encoding headers when pushing the assets to S3. Here’s the meat of our Rake task.

```ruby
File.open(entry) do |entry_file|
  content_options = {}
  content_type = MIME::Types.type_for(entry)[0]
  content_options['x-amz-acl'] = 'public-read'
  if entry.ends_with?('.gz')
    uncompressed_entry = entry[0..-4]
    entry = "#{uncompressed_entry}.cgz"
    content_type = MIME::Types.type_for(uncompressed_entry)[0]
    content_options['content-encoding'] = 'gzip'
  end
  content_options['content-type'] = content_type.to_s
  key = 'assets/'
  key += entry.slice(from.length + 1, entry.length - from.length - 1)
  s3i.put(to, key, entry_file, content_options)
end
```

Note that the Content-Type for a _.css.gz_ file is the same as for a _.css_ file (_text/css_) and that Content-Encoding is set to _gzip_.

To verify that your implementation worked, examine the page source and make sure you got a _.css.cgz_ link for stylesheets. Then, navigate to the _.css.cgz_ URL – it should display an uncompressed CSS_._

For purists, this implementation is really bad. A browser may request a web page with _Accept-Encoding: gzip_, but then request the CSS from another server without it. I am going to decide that this never happens in real life.
