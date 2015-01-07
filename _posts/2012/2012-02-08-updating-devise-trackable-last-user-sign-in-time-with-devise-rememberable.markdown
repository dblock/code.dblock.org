---
layout: post
title: "Updating Devise Trackable Last User Sign-In Time with Devise Rememberable"
redirect_from: "/updating-devise-trackable-last-user-sign-in-time-with-devise-rememberable/"
date: 2012-02-08 15:48:07
tags: [devise, rails, ruby]
comments: true
dblog_post_id: 315
---
[Devise](https://github.com/plataformatec/devise) has a _:trackable _strategy which updates the user’s last sign-in time, remote IP and increments a counter in the _User_ model upon successful logon. This is implemented in [Devise::Models::Trackable.update_tracked_fields!](https://github.com/plataformatec/devise/blob/master/lib/devise/models/trackable.rb) and invoked as a Warden callback in [devise/hooks/trackable.rb](https://github.com/plataformatec/devise/blob/master/lib/devise/hooks/trackable.rb).

{% highlight ruby %}
Warden::Manager.after_set_user :except => :fetch do |record, warden, options|
  if record.respond_to?(:update_tracked_fields!) && warden.authenticated?(options[:scope]) && !warden.request.env['devise.skip_trackable']
    record.update_tracked_fields!(warden.request)
  end
end
{% endhighlight %}

Warden will invoke the callback every time _warden.set_user_ is called, which is done once per logon with _:event => :authenticate_ in the options. But when used with the _:rememberable_ strategy, a returning user is not logging on – he continues a previous session. The callback is invoked with an _:event => :fetch_ in the options, which is explicitly excluded in the code above.

Of course, we might not see things in the same eye. A user returning 24 hours later might as well be logging in again. Let's add a callback that will update tracked fields in this case (to _config/initializers/devise_trackable.rb_).

{% highlight ruby %}
Warden::Manager.after_set_user do |record, warden, options|
  if record.respond_to?(:update_tracked_fields!) && warden.authenticated?(options[:scope]) && ! warden.request.env['devise.skip_trackable'] &&
    (record.last_sign_in_at.nil? || (Date.today - record.last_sign_in_at.to_date).to_i >= 1)
    record.update_tracked_fields!(warden.request)
  end
end
{% endhighlight %}

Is there a better way to do this? Maybe something worth contributing in one way or another to Devise?
