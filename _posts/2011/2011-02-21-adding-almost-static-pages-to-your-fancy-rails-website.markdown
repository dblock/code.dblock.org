---
layout: post
title: "Adding (almost) static pages to your fancy Rails website"
redirect_from: "/adding-almost-static-pages-to-your-fancy-rails-website/"
date: 2011-02-21 18:34:37
tags: [rails, ruby]
comments: true
---
So you’ve built the super amazing complicated Rails website. You are serving data from millions of documents from [MongoDB](http://www.mongodb.org/), rendering complex objects using [HAML](http://haml-lang.com/) and generally doing a bunch of hardcore stuff. Then someone asks you a pretty simple question: _how do I change the "Contact Us" page that’s linked at the bottom? _

A terrified look takes over your face. You realize that you must now explain to a non-technical person the process of committing to [Github](https://github.com/), merging and branching. Moreover, you are going to have to give that person committer rights. That’s pretty scary stuff right there. That marketing person is never, ever getting write access to my jewels!

Let’s turn our Rails site into a wiki in a few simple steps.

#### Create a Page Model

A simple page has a name and some content.

```ruby
class Page
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :content, type: String
end
```

Create basic controllers and UI to edit and view the pages – boring Rails stuff.

#### Enable Markdown

Assume _:content_ is in a wiki (markdown) format. No need to stand on your head if you’re using HAML. The HAML _:markdown_ filter will just render your content field in HTML. You have to use the Ruby #{} syntax to evaluate the actual expression. Here’s the entire _views/pages/show.html.haml_.

```haml
%div
  :markdown
    #{@page.content}
```

#### Embed

You can now create pages and link them together by using markdown by their relative URLs. Embed a page from the wiki into another page in a similar fashion: add a utility method to return a blank string when a page is not available and render the embedded page in another HAML page.

```ruby
class Page
  def self.content_by_name(name)
    p = Page.find(:first, conditions: { name: name })
    p ? p.content : ''
  end
end
```

```haml
:markdown
  #{Page.content_by_name('footer')}
```

In my example we introduced a convention that a footer page should be called _footer_. In the footer page I’ll place a `[Contact](/pages/Contact)` line to link the _Contact_ page. Someone from marketing can create and edit that.

#### Profit

As usual I wrote more lines of test code for this than actual lines of code. Teach your content people some [markdown basics](http://daringfireball.net/projects/markdown/basics). Not bad for half an hour of work.
