---
layout: post
title: "Rails: opinionated directory structure"
redirect_from: "/rails-opinionated-directory-structure/"
date: 2011-02-13 04:37:26
tags: [rails, ruby]
comments: true
dblog_post_id: 171
---
One thing that has been irritating me is the default Rails _app/models_ directory. It doesn’t support subdirectories, so models that deal with the database and classes that deal with overriding methods in core classes are often put in the same _app/models_ directory. Putting apples next to potatoes doesn’t make our kitchen well-organized.

This can be easily fixed by telling Rails to load all sub-directories under models, in _config/application.rb_.

{% highlight ruby %}
# Load all subdirectories of app/models.
config.autoload_paths += Dir["#{Rails.root}/app/models/\*\*/\*"]
{% endhighlight %}
