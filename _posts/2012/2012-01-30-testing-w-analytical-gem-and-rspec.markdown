---
layout: post
title: "Testing w/ Analytical Gem and RSpec"
redirect_from: "/testing-w-analytical-gem-and-rspec/"
date: 2012-01-30 21:07:14
tags: [rails, ruby, testing]
comments: true
dblog_post_id: 312
---
We use the [Analytical](https://github.com/jkrall/analytical) gem to include various thirdparty Javascripts in our Rails application. Our test environment was configured with dummy values in _config/analytical.yml_.

{% highlight yaml %}
production:
  google:
    key: <%= ENV['GOOGLE_UA'] %>
  kiss_metrics:
    js_url_key: <%= ENV['KISS_METRICS_URL_KEY'] %>
test:
  google:
    key: 'UA-12345'
  kiss_metrics:
    js_url_key: 12345
development:
{% endhighlight %}

We wrote a few simple tests to make sure the analytical code is being included properly. For example, we can check whether Google Analytics is included on the splash page.

{% highlight ruby %}
context "google analytics" do
  it "should appear on the splash page" do
    visit "/"
    within :css, "script[type='text/javascript']:contains('.google-analytics.com/')" do
      page.should have_content("UA-12345")
    end
  end
end
{% endhighlight %}

Or, more complicated, test whether a user ID is sent to Kissmetrics.

{% highlight ruby %}
context "kiss-metrics analytics" do
  it "should appear on the splash page" do
    visit "/"
    within :css, "script[type='text/javascript']:contains('kissmetrics.com/')" do
      page.should have_content("12345")
    end
  end
  context "logged-in user" do
    before(:each) do
      login_as @user
      visit "/"
    end
    it "should appear on the search page" do
      within :css, "script[type='text/javascript']:contains('kissmetrics.com/')" do
        page.should have_content("12345")
      end
    end
    it "should include user id" do
      within :css, "script[type='text/javascript']:contains(\"identify\")" do
        page.should have_content("[\"identify\", \"#{@user.id}\"]);")
      end
    end
  end
end
{% endhighlight %}

The drawback of this approach is that the Analytical code is included with every other test that doesn’t need it. With every Capybara test that runs in a browser, this hits DNS, then makes an HTTP request to Google and Kissmetrics. We cannot stub that with VCR or another gem because we’re using a real browser. But we can selectively enable Analytics without a configuration file by emptying the _:test_ block in _config/analytical.yml _by configuring it before any test that needs it.

{% highlight ruby %}
before :each do
    @analytical_options = ApplicationController.analytical_options.dup
    ApplicationController.analytical_options = @analytical_options.merge({
        :modules => [:google, :kiss_metrics],
        :google => { :key => "UA-12345" },
        :kiss_metrics => { :js_url_key => 12345 }
    })
end

after :each do
    ApplicationController.analytical_options = @analytical_options
end
{% endhighlight %}

It helps to be open-source. Looking at the internals of Analytical, its options are processed inside each controller on load, then merged with request options on every request before anything is rendered. The code above updates the configuration between those two steps. Note that since we’re modifying a static we have to make sure to cleanup after ourselves.
