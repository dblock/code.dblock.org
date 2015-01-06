---
layout: post
title: "Selecting items from a dropdown with Capybara, Selenium (Firefox) & JQuery"
redirect_from: "/selecting-items-from-a-dropdown-with-capybara-selenium-firefox-jquery"
date: 2011-08-12 00:15:35
tags: [selenium, capybara, firefox, rails, ruby, testing]
comments: true
---
I am having a weird problem with Capybara and Selenium (Firefox) selecting items in a dropdown.

We are editing a _Widget_ that has a dropdown for _size _on the page with values 1-10. We can use a simple form, like this.

```haml
= simple_form_for @widget do |f|
  = f.input :name
  = f.input :description
  = f.input :size, collection: 1..10
  = f.submit "Save"
```

The test code is pretty straightforward too.

```ruby
context "capybara", :driver => :selenium do
  before(:each) do
    @widget = Fabricate(:widget, :size => 3)
  end
  it "saves 5 to widget.size" do
    visit "/widget/#{@widget.id}/edit"
    page.select("5", :from => "widget_size")
    click_button "Save"
    current_path.should == "/widgets"
    @widget.reload.size.should == 2
  end
end
```

If you watch this test execute in the browser, the dropdown box that lets the user select the size is clicked on, the value "5" is located and the dropdown closes. Well, not quite. The value changes according to Capybara (fetching the value after _page.select_ confirms this), but the dropdown seems to continue displaying. Weird.

![]({{ site.url }}/images/posts/2011/2011-08-12-selecting-items-from-a-dropdown-with-capybara-selenium-firefox-jquery/image%5b9%5d.jpg)

If you post this form, the value that you get in the controller is still "3", so something is really broken. As a workaround a JQuery selection works.

```ruby
page.execute_script("$('#widget_size').val('5')")
```

Let's file a bug in Capybara to start, [https://github.com/jnicklas/capybara/issues/448](https://github.com/jnicklas/capybara/issues/448).

Ideas?
