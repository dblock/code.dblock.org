---
layout: post
title: "Rendering Markdown Documents in Rails"
redirect_from: "/rendering-markdown-documents-in-rails/"
date: 2011-11-07 15:01:55
tags: [grape, rails, ruby]
comments: true
dblog_post_id: 289
---
There’s got to be a prettier way of implementing this.

![]({{ site.url }}/images/posts/2011/2011-11-07-rendering-markdown-documents-in-rails/image_19.jpg)

We use the following code to render API documentation, which is written in [Markdown](https://daringfireball.net/projects/markdown/).

Add a route that will capture the document filename in _config/routes.rb_. Bonus features: a namespaced controller and a redirect to _/api/v1/docs_ for _/api/v1_.

{% highlight ruby %}
scope 'api', :module => 'api' do
  match '/:version' => redirect('/api/%{version}/docs')
  match '/:version/docs/(/:page)' => "docs#show"
end
{% endhighlight %}

Create a _controllers/api/docs_controller.rb_.

{% highlight ruby %}
class Api::DocsController < ApplicationController

  # GET /api/docs/:version/:page
  def show
    @version = params[:version]
    @page = (params[:page] || "index").downcase.gsub(/[^a-z0-9]/, '') # strip any non-alpha-numeric characters
    filename = File.join(Rails.root, 'public/api/' + @version + "/docs/" + @page + '.md')
    begin
      file = File.open(filename, "rb")
      @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
      render :text => @markdown.render(file.read), :layout => true
    rescue Errno::ENOENT
      render :file => "public/404.html", :status => 404
    end
  end

end
{% endhighlight %}

You can now create _public/api/v1/docs/something.md_ and it will render under _api/v1/docs/something_.

What I’d like to do is take the Markdown renderer out of this controller, define it as a generic handler, and swap the template being rendered to the _filename_ instead. How do I do that?
