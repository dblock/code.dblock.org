---
layout: post
title: "Mongoid 2.0.2 Dropped Pagination => Kaminari"
redirect_from: "/mongoid-202-dropped-pagination-kaminari/"
date: 2011-07-07 09:44:13
tags: [mongodb, rails, ruby]
comments: true
dblog_post_id: 228
---
I was a bit surprised to see mongoid drop pagination support in 2.0.2 ([here](https://github.com/mongoid/mongoid/commit/087c95aa706e4df50a6db0f302c42dd815df8b34) and [here](https://github.com/mongoid/mongoid/commit/f7f66f2345336ecc361ca27bbfa8f8a25443587f)). It got some people confused (see mongoid#983). In a project that uses [will_paginate](https://github.com/mislav/will_paginate), this results in very slow large queries, but no other breakage. It looks like Mongoid did the right thing though – their implementation was messy and other extensions do a much cleaner job.

Here’s what I had to do to switch from will_paginate to [kaminari](https://github.com/amatsuda/kaminari). The latter works well with Mongoid 2.0.2.

Replace will_paginate with kaminari in Gemfile.

{% highlight ruby %}
gem "kaminari", "0.12.4"
{% endhighlight %}

Replace all calls to `.paginate :page => params[:page], :per_page => 20` with the kaminari methods.

{% highlight ruby %}
Model.desc(:created_at).page(params[:page]).per(20)
{% endhighlight %}

There may be some loading order issues since kaminari injects methods on load. For delayed jobs I had to do the following in the initializer (see [#10](https://github.com/collectiveidea/delayed_job_mongoid/issues/10)).

{% highlight ruby %}
Delayed::Job.send(:include, Kaminari::MongoidExtension::Document)
{% endhighlight %}

If you have a shared pagination block (eg. _app/views/shared/pagination/_pagination.html.haml_) change it to use kaminari layouts.

{% highlight haml %}
#pagination
  = paginate items
{% endhighlight %}

There’s a pull request [#140](https://github.com/amatsuda/kaminari/pull/140/) for _page_entries_info_, it looks like it still has a couple of issues. We’ve added [config/initializers/kaminari.rb](https://gist.github.com/dblock/1111587) for now.

If you’re paginating arrays you can inject a few methods into a paged result set on-the-fly to make it play nice.

{% highlight ruby %}
@paged_result_set.instance_eval <<-EVAL
  def current_page
    #{params[:page] || 1}
  end
  def num_pages
    count
  end
  def limit_value
    20
  end
EVAL
{% endhighlight %}
