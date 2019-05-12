---
layout: post
title: "Wrapping the Idee Pixmatch RESTful API in a Ruby Gem"
redirect_from: "/wrapping-the-idee-pixmatch-restful-api-in-a-ruby-gem/"
date: 2011-04-14 02:03:57
tags: [artsy, rails, ruby]
comments: true
dblog_post_id: 198
---
I had a nice time today wrapping up the [Idee Pixmatch API](https://web.archive.org/web/20120626084848/http://ideeinc.com/products/pixmatch/) in a Ruby gem. PixMatch is a general image matching engine that allows you to perform large scale image comparisons and I wanted to upload a few million images and check it out.

![pixmatch-sample]({{ site.url }}/images/posts/2011/2011-04-14-wrapping-the-idee-pixmatch-restful-api-in-a-ruby-gem/pixmatch-sample_7.jpg)

The resulting gem is [here](https://github.com/dblock/pixmatch), MIT licensed. I copied the file structure from [skittles](https://github.com/anthonator/skittles) which copied it from [twitter](https://github.com/jnunemaker/twitter). Open-source neatly promotes copy-paste these days – we at [artsy](https://artsy.net) call it collage!

There’re two kinds of requests in Pixmatch: simple REST GETs and POSTs and multipart posts with image data. I ended up not using the RESTful request wrappers that exist in both and instead switched to [rest-client](https://github.com/archiloque/rest-client), a much simpler and more powerful framework. To upload images we need to be posting a multipart payload where file names are images[0], images[1], etc.  I remember it taking me a week to write multipart client support in C++ ten years ago. Today it’s a no-brainer made possible by rest-client.

{% highlight ruby %}
def add(files)
  files_hash = { }
  payload = files.each { |f| files_hash["images[#{files_hash.size}]"] = f.is_a?(File) ? f : File.new(f, "rb") }
  RestClient::Request.new({ method: :post, url: "http://api.tineye.com/rest&method=add", payload: payload }).execute
end
{% endhighlight %}

Now calling _add_ on a bunch of files is pretty.

{% highlight ruby %}
Pixmatch.add(Dir.glob("images/\*.jpg"))
{% endhighlight %}

Pixmatch is not available publicly, e-mail info[at]ideeinc.com to get started.
