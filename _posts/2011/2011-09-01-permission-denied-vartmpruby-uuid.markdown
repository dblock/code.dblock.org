---
layout: post
title: "Permission denied - /var/tmp/ruby-uuid"
redirect_from: "/permission-denied-vartmpruby-uuid/"
date: 2011-09-01 11:17:32
tags: [rails, ruby, testing]
comments: true
dblog_post_id: 252
---
I’ve been fighting a trivial RoR controller test failure on a new build machine. The spec is rather trivial.

{% highlight ruby %}
def mock_widget(stubs={})
  @mock_widget ||= mock_model(Widget, stubs).as_null_object
end

it "assigns a newly created widget as @widget" do
  Widget.stub(:new) { mock_widget }
  post :create, :widget => {'these' => 'params'}
  assigns(:widget).should be(mock_widget)
end
{% endhighlight %}

Exceptions in Rails controllers are eaten in RSpec tests. So whenever I have a controller spec failure, I add a begin/rescue block in it. This is hacky, but gets the job done.

{% highlight ruby %}
def create
  begin
    ...
  rescue Exception => e
    puts e.message
    puts e.backtrace
    raise e
  end
end
{% endhighlight %}

Today’s spec failure was rather curious.

```
Permission denied - /var/tmp/ruby-uuid
/home/jenkins/.rvm/gems/ruby-1.9.2-p290/gems/uuid-2.3.2/lib/uuid.rb:354:in `initialize'
/home/jenkins/.rvm/gems/ruby-1.9.2-p290/gems/uuid-2.3.2/lib/uuid.rb:354:in `open'
/home/jenkins/.rvm/gems/ruby-1.9.2-p290/gems/uuid-2.3.2/lib/uuid.rb:354:in `open_lock'
/home/jenkins/.rvm/gems/ruby-1.9.2-p290/gems/uuid-2.3.2/lib/uuid.rb:322:in `next_sequence'
/home/jenkins/.rvm/gems/ruby-1.9.2-p290/gems/uuid-2.3.2/lib/uuid.rb:256:in `initialize'
/var/lib/jenkins/jobs/gravity-master/workspace/app/controllers/admin/widgets_controller.rb:35:in `new'
/var/lib/jenkins/jobs/gravity-master/workspace/app/controllers/admin/widgets_controller.rb:35:in `widget_hash'
/var/lib/jenkins/jobs/gravity-master/workspace/app/controllers/admin/widgets_controller.rb:12:in `create'
```

The culprit was [ruby-uuid](https://github.com/spectra/ruby-uuid/), an old library that creates a temporary file with a fixed name. If you run tests under different user accounts, the second run will yield a permission denied. Time to switch the UUID library, to maybe [this one](https://github.com/sporkmonger/uuidtools).
