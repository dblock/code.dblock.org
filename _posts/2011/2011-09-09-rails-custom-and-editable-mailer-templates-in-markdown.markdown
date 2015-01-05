---
layout: post
title: "Rails: Custom and Editable Mailer Templates in Markdown"
redirect_from: "/rails-custom-and-editable-mailer-templates-in-markdown"
date: 2011-09-09 00:20:32
tags: [devise, rails, ruby]
comments: true
---
You love markdown? We do too.

I’m going to show you how to enable dynamic authoring of mail templates in your Rails app in [Markdown](http://daringfireball.net/projects/markdown/). This includes [Devise](https://github.com/plataformatec/devise) mailers. You can already customize templates with files in _app/views_, but we’ll take an extra step and expose an editable model in the database and allow our application administrators to author and edit templates in Markdown.

#### Template Model

Let's add a _MailTemplate_ that can render itself to HTML using [Sanitize](https://github.com/rgrove/sanitize/) and [RDiscount](https://github.com/rtomayko/rdiscount). The class name will be the mailer and the method name, the mail action.

```ruby
class MailTemplate
  include Mongoid::Document
 
  field :class_name, :type => String
  field :method_name, :type => String
  field :subject, :type => String
  field :content, :type => String

  attr_accessible :content, :subject
 
  def to_html(context)
    template = ERB.new(content, 0, "%<>")
    template_result = template.result(context)
    Sanitize.clean(RDiscount.new(template_result).to_html.encode("UTF-8", undef: :replace), Sanitize::Config::RELAXED)
  end
end
```

We need to be able to render this in a mailer, so add a simple controller in _app/controllers/mail_templates_controller.rb._

```ruby
class MailTemplatesController < ApplicationController
  def show
    @mail_template = MailTemplate.find(params[:id])
  end
end
```

And a simple view, _app/views/mail_templates/show.html.haml_.

```haml
%div
  = @mail_template.to_html(@context).html_safe
```

You can add a form to edit such a mail template, left as an exercise.

There’re a lot of mailers, so having to create each template by hand doesn’t make a lot of sense. There’s no easy way to enumerate all mailers, so lets define the in some central location and write a Rake task to create these in the database. I wrote _app/mailers/mailers.rb._

```ruby
module Mailers
 
  ALL = {
    "Devise::Mailer" => [
      "confirmation_instructions",
      "reset_password_instructions",
      "unlock_instructions",
      "invitation_instructions"
    ]
  }
 
  def self.template_for(klass, method_name)
    method_name = method_name.to_s.gsub("_email", "")
    path = "#{Rails.root}/app/views/#{klass.to_s.underscore}/#{method_name.to_s}.md"
    raise "missing #{path}" unless File.exist?(path)
    File.read(path)
  end

  def self.load_template(klass, method_name)
    template = MailTemplate.new
    template.class_name = klass.to_s
    template.method_name = method_name.to_s
    template.content = template_for(klass, method_name)
    template
  end

  def self.load(klass, method_name)
    mail_template = MailTemplate.where(class_name: klass.to_s, method_name: method_name).first
    mail_template ||= Mailers.load_template(klass, method_name)
    mail_template
  end

  def self.create_templates!
    ALL.each_pair do |klass, method_names|
      method_names.each do |method_name|
        if MailTemplate.where(class_name: klass, method_name: method_name).blank?
          Rails.logger.info("creating #{klass}/#{method_name} e-mail template")
          Mailers.load_template(klass, method_name).save!
        end
      end
    end
  end
 
end
```

It’s all pretty straightforward. You can add other mailers to _Mailers.ALL_. A rake task can invoke _Mailers.create_templates!_ so that we get a record in the database with the default data. Here’s an example of _app/views/devise/mailer/reset_password_instructions.md_. Note that this is already written in markdown!

```md
Hello <%=@resource.email%>!
```
 
Someone has requested a link to change your password, and you can do this through the link below.

```md
[Change my password](http://example.com/users/password/edit?reset_password_token=<%=@resource.reset_password_token%>)

If you didn't request a password reset, please ignore this email.
Your password won't change until you access the link above and create a new one.
```

#### Overriding Devise

We want to override the Devise mailer and fetch the mail template, if available. Add _app/mailers/devise_mailer.rb_. The mailer will fetch a template from _Mailers_ and render it.

```ruby
class DeviseMailer < Devise::Mailer
 
  def template_paths
    "devise/mailer"
  end

  def devise_mail(record, action)
    initialize_from_record(record)
    @context = binding
    @mail_template = Mailers.load("Devise::Mailer", action)
    headers = headers_for(action)
    template_view = "mail_templates/show.html.haml"
    headers[:subject] = @mail_template.subject unless @mail_template.subject.blank?
    mail headers do |format|
      format.html do
        render template_view
      end
    end
  end

end
```

Declare the mailer in _config/initializers/devise.rb_.

```ruby
Devise.setup do |config|
  config.mailer = "DeviseMailer"
  ...
end
```

#### Tests

A simple test is to make sure we can actually render an e-mail. Here’s what my _spec/mailers/devise_mailer_spec.rb_ looks like.


```ruby
require "spec_helper"
 
describe DeviseMailer do
  before(:each) do
    @user = Fabricate(:user)
    @user.stub!(:confirmation_token).and_return("confirmation-token")
    @user.stub!(:unlock_token).and_return("unlock-token")
  end
  Mailers::ALL["Devise::Mailer"].each do |method_name|
    it "should respond to #{method_name}" do
      DeviseMailer.should respond_to method_name
    end
    it "#{method_name} should attempt to load a MailTemplate" do
      mail_template = Fabricate(:mail_template)
      Mailers.should_receive(:load).with("Devise::Mailer", method_name.to_sym).and_return(mail_template)
      DeviseMailer.send(method_name, @user)
    end
    it "#{method_name} should have a proper body" do
      mail = DeviseMailer.send(method_name, @user)
      mail.to.should_not be_blank
      mail.from.should_not be_blank
    end
  end
end
```

#### Next steps?

You tell me. I think we should be able to sink a lot of the functionality implemented in the _Mailers_ module in various parts of the system. Starting with the _.md_ rendering.
