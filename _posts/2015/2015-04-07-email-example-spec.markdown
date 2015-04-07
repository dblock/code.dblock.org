---
layout: post
title: "ActionMailer Integration Testing with Email-Example-Spec"
date: 2015-04-07
tags: [ruby, rails, actionmailer, testing]
comments: true
---
Introducing [email-example-spec](https://github.com/dblock/email-example-spec), integration testing for your ActionMailer e-mails.

Testing e-mail body, subject, to and from addresses with expectations works, but somehow pesky e-mail template bugs constantly make it into production. Sometimes it's broken HTML and sometimes it's different content between the text and the HTML part because of a `@variable` typo. An integration test lets you visualize the generated e-mail, and I frequently share the output inside our Github repo with the business team for review.

### Install

{% highlight ruby %}
gem 'email-example-spec'
{% endhighlight %}

### Configure

{% highlight ruby %}
EmailExampleSpec.configure do |config|
  config.record = true # record new e-mails, don't commit this!
  config.fixture_path = File.join(Rails.root, 'spec/support/fixtures/emails')
end
{% endhighlight %}

### Use

{% highlight ruby %}
describe WelcomeMailer do
  let(:user) { User.new }
  subject do
    WelcomeMailer.welcome(user)
  end
  it 'works' do
    expect(subject).to match_email_example_in 'welcome_mail.txt'
  end
end
{% endhighlight %}

