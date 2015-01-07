---
layout: post
title: "Warning: Toplevel Constant XYZ Referenced Admin:XYZ"
redirect_from: "/warning-toplevel-constant-xyz-referenced-adminxyz/"
date: 2012-01-08 00:09:25
tags: [rspec, rails, ruby]
comments: true
dblog_post_id: 306
---
I posted [this](http://www.ruby-forum.com/topic/1506818) to a Ruby forum a while ago.

> _I got controllers in a namespace and controllers outside of the namespace. For example, I have a PagesController and a Admin::PagesController. When I run rspec from the top, tests pass and I get the following warning: __spec/controllers/admin/pages_controller_spec.rb:4: warning: toplevel constant PagesController referenced by Admin::PagesController.__ This makes no sense. I do have a PagesController and an Admin::PagesController and specs for both that are declared properly._

This was only happening under Spork, so I posted [a similar question](http://groups.google.com/group/sporkgem/browse_thread/thread/54dfd1e885ad5373) to the sporkgem list.

I also found a workaround, to require the Admin controllers first in _spec/spec_helper.rb_.

{% highlight ruby %}
Dir[File.expand_path("app/controllers/admin/\*.rb")].each do |file|
  require file
end
{% endhighlight %}

Finally, [@tilsammans](https://twitter.com/#!/tilsammans) figured it out. It’s the same problem as what I have: an Admin namespace and an Admin class.

> _It was because I also had a class Admin, as well as a namespace Admin. Since Admin was a class (a model) it inherited from Object which made the top-level ApplicationController available inside the Admin namespace. The reply by Andrew White on _ [_http://groups.google.com/group/rubyonrails-core/browse_thread/thread/bab5e87ee10d2ecb_](http://groups.google.com/group/rubyonrails-core/browse_thread/thread/bab5e87ee10d2ecb)_ lead me to find the right answer. In the end I renamed Admin to AdminUser and everything fell into place._

This is rather counterintuitive and one would think Ruby should somehow handle this situation, but it at least makes technical sense.
