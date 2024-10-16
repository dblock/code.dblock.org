---
layout: post
title: "Syntax Highlighting in Markdown Content with Recarpet, Coderay and Rails"
redirect_from: "/syntax-highlighting-in-markdown-content-with-recarpet-coderay-and-rails/"
date: 2014-08-31 15:08:14
tags: [artsy, rails, ruby]
comments: true
dblog_post_id: 421
---
I wanted Ruby and JSON code blocks ala [Github’s Flavored Markdown](https://help.github.com/articles/github-flavored-markdown) when rendering markdown documents in [doppler](https://github.com/artsy/doppler). The idea is that we can API documentation authored in markdown, and rendered within a Rails application.

The first, harder part, is doing markdown rendering with syntax  highlighting. You render markdown with your favorite markdown gem (eg. [Redcarpet](https://github.com/vmg/redcarpet)), then parse the document and replace all code divs with a syntax highlighted version produced by [Coderay](https://github.com/rubychan/coderay). I had to also do some div swapping to avoid nested `<pre>` and `<code>` blocks.

{% highlight ruby %}
require 'redcarpet'
require 'coderay'

module MarkdownHelper
 def render_markdown(text)
   renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML, fenced_code_blocks: true)
   doc = Nokogiri::HTML::DocumentFragment.parse(renderer.render(text))
   doc.css('code[@class]').each do |code|
     div = CodeRay.scan(code.text.rstrip, code[:class].to_sym).div
     code = code.replace(div)
     code.first.parent.swap(code.first)
   end
   doc.to_s
 end
end
{% endhighlight %}

We can use this in a controller, assuming content lives in _app/voews/content_. Bonus: caching.

{% highlight ruby %}
class PagesController < ApplicationController
 include MarkdownHelper

 def show
   fail 'Invalid Id' unless params[:id] =~ /^[\w\/]\*$/
   filename = Rails.root.join("app/views/content/#{params[:id]}.md")
   @content = Rails.cache.fetch "content/#{params[:id]}/#{File.mtime(filename)}" do
     text = File.read(filename)
     render_markdown text
   end
 end
end
{% endhighlight %}

The corresponding view in _pages/show.html.haml_ is as follows.

{% highlight haml %}
%div
 != @content
{% endhighlight %}

You can route to one of those pages in _routes.rb_.

{% highlight ruby %}
get '/terms', to: 'pages#show', id: 'terms'
{% endhighlight %}

See [https://github.com/artsy/doppler/pull/24](https://github.com/artsy/doppler/pull/24) for a complete pull request with the above.

And here’s a screenshot of a rendered page.

![]({{ site.url }}/images/posts/2014/2014-08-31-syntax-highlighting-in-markdown-content-with-recarpet-coderay-and-rails/screenshot_5.jpg)

