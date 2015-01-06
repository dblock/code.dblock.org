---
layout: post
title: "Rails Editable Mail Templates w/Preview from 37Signals"
redirect_from: "/rails-editable-mail-templates-wpreview-from-37signals"
date: 2011-09-15 06:41:26
tags: [rails, ruby]
comments: true
---
Last time we added custom editable mail templates to our mailers and made them Markdown format [[read first](/rails-custom-and-editable-mailer-templates-in-markdown)]. Awesome. Let's add a preview to the templates with [37-signals mail_view](https://github.com/37signals/mail_view). I don’t know how we lived without this before!

#### Gemfile

```ruby
gem "mail_view", :git => "https://github.com/37signals/mail_view"
```

#### Routes

Remember how we pre-declared our mailers in a hash. This is going to come in handy for _config/routes.rb_.

```ruby
Mailers::ALL.each_pair do |klass, method_names|
  mount "#{klass.gsub('::', '')}::Preview".constantize => "mail_templates/#{klass.underscore}/preview"
end
```

Now we have a _mail_templates/devise/mailer/preview/reset_password_instructions_ path for a Devise::Mailer mailer!

#### Preview

This needs to route somewhere. Let's add a preview into our overridden _DeviseMailer_.

```ruby
class DeviseMailer < Devise::Mailer
  def template_paths
    "devise/mailer"
  end

  def devise_mail(record, action)
    ...
  end

  class Preview < MailView
    def invitation_instructions
      DeviseMailer.devise_mail(
        User.new({email: 'chuck@example.com',
            name: 'Chuck Norris',
            invitation_token: 'invitation-token'}),
        :invitation_instructions)
    end
  end
end
```

Why Chuck Norris? I’ve been enjoying the [Chuck Norris Jenkins Plugin](https://wiki.jenkins-ci.org/display/JENKINS/ChuckNorris+Plugin) too much lately. Chuck Norris can preview mail templates in PDF!

Here’s our mail templates admin page with a link to the preview (_mail_templates/index.html.haml_).

```haml
%h1 Mail Templates

%table
  %tr
    %th Class Name
    %th Method Name
    %th Subject
    %th
    %th

  - @mail_templates.each do |mail_template|
    %tr
      %td= mail_template.class_name
      %td= mail_template.method_name
      %td= mail_template.subject
      %td.admin_actions= link_to 'Edit', edit_mail_template_path(mail_template)
      %td.admin_actions= link_to 'Preview',
        "/admin/mail_templates/#{mail_template.class_name.underscore}/preview/#{mail_template.method_name}",
        :target => '_blank'
```

Well, that’s it. You need to add a _Preview_ class for every mailer.

#### Screenshot

![reset-password]({{ site.url }}/images/posts/2011/2011-09-15-rails-editable-mail-templates-wpreview-from-37signals/reset-password%5b12%5d.jpg)
