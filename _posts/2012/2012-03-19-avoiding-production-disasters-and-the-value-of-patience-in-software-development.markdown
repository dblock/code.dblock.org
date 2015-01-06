---
layout: post
title: "Avoiding Production Disasters and The Value of Patience in Software Development"
redirect_from: "/avoiding-production-disasters-and-the-value-of-patience-in-software-development"
date: 2012-03-19 12:28:43
tags: [teams, testing, people]
comments: true
---
I am not a patient person. But years of software practice have taught me how to take my time while coding or how to, otherwise, remove time from the equation.

#### Manual Tasks Become Features

Otherwise known as _process becomes automation_.

You need a lot of patience when operating a manual change on a live system. You’re always _this_ close to dropping the _users_ table. So I learned a decent way to prevent mistakes: always run commands in a test environment, first. But that’s the same as walking on a cable between two chairs, before trying it between two skyscrapers – there’s still no safety net.

![]({{ site.url }}/images/posts/2012/2012-03-19-avoiding-production-disasters-and-the-value-of-patience-in-software-development/image_3.jpg)

_"first, he tried it at home between two chairs"_

Instead, transform any manual task into a feature. In the Ruby world we write Rake tasks.

The cost of transforming a task into a feature is about half a day of work. But it’s still less than one production disaster for every 100 such instances.

#### Automated Tasks Become Business Logic with Tests

Automation is good, but testing is better. Consider the following task that sends some kind of reminder e-mail.

```ruby
desc "Send a reminder to all users that haven't been reminded yet."
  task :remind => :environment do |t, args|
    User.all.each do |user|
      next if user.reminded?
      user.update_attributes!({ reminded_at: Time.now.utc })
      ReminderMailer.delay.reminder_email(user)
    end
  end
end
```

It’s pretty concise. Unfortunately, _user.reminded?_ has a bug and you now have a communication disaster on your hands.

![]({{ site.url }}/images/posts/2012/2012-03-19-avoiding-production-disasters-and-the-value-of-patience-in-software-development/image_18.jpg)

"he just reminded a million users that their delinquent account is about to be suspended"

We can move this entire logic into the _User_ model and write a test.

```ruby
class User
  def reminded?
      !! reminded_at
  end

  def remind!
      raise "reminder already sent" if reminded?
      update_attributes!({ reminded_at: Time.now.utc })
      ReminderMailer.delay.reminder_email(self)
  end
end
```

The test can cover other important aspects, such as the actual source and destination of the e-mail.

```ruby
describe "remind!" do
  before :each do
    @user = Fabricate :user
  end

  it "should send a reminder to a user" do
    emails_count = ActionMailer::Base.deliveries.count
    @user.remind!
    ActionMailer::Base.deliveries.count.should == emails_count + 1
    reminder_email = ActionMailer::Base.deliveries.last
    reminder_email.from.first.should == "support@acme.com"
    reminder_email.to.first.should == @user.email
    @user.reminded?.should be_true
  end

  it "should not send a reminder email more than once" do
    @user.remind!
    emails_count = ActionMailer::Base.deliveries.count
    lambda { @invitation.remind! }.should raise_error("reminder already sent")
    ActionMailer::Base.deliveries.count.should == emails_count
  end
end
```

And the task is simpler.

```ruby
desc "Send a reminder to all users that haven't been reminded yet."
  task :remind => :environment do |t, args|
    User.all.each do |user|
      next if user.reminded?
      user.remind!
    end
  end
end
```

The cost of this change depends on the complexity of the task, but it tends toward zero. Tests take time to implement, but save debugging and regression time. Operational, or "machine" cost is roughly half a day, because the changes must go through continuous integration and a deploy before they can be run.

#### Friday Changes Become Monday Changes

Why do something today when you can do it tomorrow?

It’s Friday night and happy hour is about to start. Plan that next deploy for Monday morning, when everybody is in the office.

![]({{ site.url }}/images/posts/2012/2012-03-19-avoiding-production-disasters-and-the-value-of-patience-in-software-development/image_22.jpg)

_"she just spent her week-end undoing Friday’s mess"_

Spending a week-end in the office fixing what you (or someone else) broke on a Friday shoots your Monday’s productivity. You’ll feel like exhausted heroes, at the cost of three days of work (week-end included) multiplied by the number of people involved.

#### This Week Becomes This or Next Sprint

I firmly believe in under-promising and over-delivering.

![]({{ site.url }}/images/posts/2012/2012-03-19-avoiding-production-disasters-and-the-value-of-patience-in-software-development/image_26.jpg)

_"he over-promised and under-delivered"_

Never promise anything for tomorrow, day-after-tomorrow or even this week.

I see the best engineers learn to answer requests with "this sprint" and working really hard and getting it done for the next day. I love that. They don’t have an impossible deadline, and aren’t required to cut corners and can do things patiently (implement the request as a feature, write tests and get a code review).

The person on the receiving end is juggling a hundred things too, and generally they don’t expect anything to be done immediately, either. They also never remember when something was done in a day vs. two or five, but they remember well when something made in a hurry produced a production outage.

#### Asking a Person Becomes Asking The Team

As the team via the team lead when you need a feature.

![]({{ site.url }}/images/posts/2012/2012-03-19-avoiding-production-disasters-and-the-value-of-patience-in-software-development/image_30.jpg)

_"she will gladly implement your feature request, right now"_

We’re creatures of habit. So we ask the same person who implemented our previous request to do it again. Asking a team lead is really not a matter of process, – I don’t get offended when someone goes directly to a developer to ask for something (in fact, I love when this happens in some cases) – it’s a matter of actually getting you what’s important, first. A team lead has a complete view of everything that’s going on and will be able to find hands for your request. It will get done much sooner.

It’s Friday afternoon and you’re about to make a clean break and grab a beer. Someone wants you, a developer, to e-mail a million users and remind them about their account being suspended. Rewind through my blog post.
