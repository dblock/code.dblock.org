---
layout: post
title: "Internet Explorer Refuses to read CSS from S3/CloudFront"
redirect_from: "/internet-explorer-refuses-to-read-css-from-s3cloudfront/"
date: 2011-06-12 20:22:15
tags: [cloudfront, s3]
comments: true
dblog_post_id: 218
---
One of the issues that we ran to with implementing S3/CloudFront was that Internet Explorer refused to read CSS files from our CDN URL. The site would work beautifully in Chrome or Firefox and would ignore stylesheets in IE. Fortunately, IE9 has some good developer tools. This is what IE says in its console.

![SEC7113: CSS was ignored due to mime type mismatch]({{ site.url }}/images/posts/2011/2011-06-12-internet-explorer-refuses-to-read-css-from-s3cloudfront/image_4.jpg)

Examining the HTTP response I quickly found out that the content-type came back blank. Turns out that our S3 sync code was not setting the content type and right_aws adds a blank content-type (lowercase) because Amazon S3 would otherwise reject it. Here’s a nice fix to my [previous post](/rails-s3-cloudfront-jammit-heroku-100).

{% highlight ruby %}
content_type = MIME::Types.type_for(entry)[0]
logger.info("[#{Time.now}] uploading #{key} (#{content_type})")
s3i.put(to, key, File.open(entry), {
  'x-amz-acl' => 'public-read',
  'content-type' => content_type.to_s
})
{% endhighlight %}
