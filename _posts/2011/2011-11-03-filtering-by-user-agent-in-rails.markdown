---
layout: post
title: "Filtering by User-Agent in Rails"
redirect_from: "/filtering-by-user-agent-in-rails"
date: 2011-11-03 13:15:30
tags: [rails, ruby]
comments: true
---
Let's filter out some unwanted browsers from displaying broken pages in our Rails application. We could disallow IE6, for example, but allow IE7, 8 and 9.

Bring in the _useragent_ gem – we’ll need to take it from a popular [jillion fork](https://github.com/jilion/useragent) –  it has a ton of fixes that became too hard to merge back to its parent. The latter has many bugs in version comparisons to make it useful for our purposes as of the time of writing this.

```ruby
gem "useragent", :git => "https://github.com/jilion/useragent.git"
```

We can add an _app_initialization _to _ApplicationController_ that all controllers derive from which will render an error page if the browser is not supported.

```ruby
class ApplicationController < ActionController::Base
  include ApplicationHelper
 
  before_filter :app_initialization
 
  def app_initialization
    if is_browser_unsupported?
      render :template => "errors/browser", :status => 406, :layout => false
    end
  end
 
end
```

The template can be a page placed in _app/views/errors/browser.html.haml_.

```haml
%html
  %head
    = include_stylesheets :common
    = include_stylesheets :errors
  %body
  
    %h1 Your browser is not supported. We're working on it.
 
    .user_agent
      = @user_agent
```

Finally, declare an array of supported and an array of unsupported browsers within ApplicationController. A supported browser is a structure of browser name and version. An unsupported browser name is sufficient. We first check whether the browser is explicitly unsupported, then whether the version of a supported browser is bigger or equal to a specific one.

```ruby
Browser = Struct.new(:browser, :version)
SUPPORTED_BROWSERS = [
  Browser.new("Chrome", "10.0"),
  Browser.new("Safari", "3.0"),
  Browser.new("Firefox", "3.6"),
  Browser.new("Internet Explorer", "9.0"),
]
 
UNSUPPORTED_BROWSERS = [
  "Opera", "Opera Mini"
]
```

Finally, we let everyone with an unknown browser through – we can’t possibly whitelist hundreds of search engine user-agents.

```ruby
def is_browser_unsupported?
  return false if (Rails.env.test? and request.user_agent.blank?)
  @user_agent = UserAgent.parse(request.user_agent)
  return true if UNSUPPORTED_BROWSERS.include?(@user_agent.browser)
  return true if SUPPORTED_BROWSERS.any? { |browser| @user_agent < browser }
  false
end
```
