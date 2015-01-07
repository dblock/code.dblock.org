---
layout: post
title: "Grape: Describing and Documenting an API"
redirect_from: "/grape-describing-and-documenting-an-api/"
date: 2011-12-11 15:03:39
tags: [grape, art.sy, rails, ruby]
comments: true
dblog_post_id: 301
---
Building a software platform is not just an investment in the future, it’s a software architecture philosophy. A proper API is a manifestation of some of the core principles of domain driven design – spend a lot of time figuring out what your domain is, then build software that represents the immutable concepts behind an API and, finally, implement different businesses that can quickly thrive, die or pivot, on top of that. We’ve spent considerable amounts of time iterating on our own API and are constantly improving the artifacts around it as we learning from good examples of Twilio, Stripe, etc.

There’re several ways to build an API reference: entirely by hand, generated from code comments or by adding metadata at runtime. The first one is inanity and the second one is not leveraging the magic of Ruby. Hence I am a huge fan of the latter, as it offers the best chance of creating something that actually reflects code.

You can now do this in [Grape](https://github.com/intridea/grape) with _desc_ blocks.

{% highlight ruby %}
# DELETE /api/v1/thing/:id
desc "Delete an existing thing.", {
  :params => {
    "id" => { :description => "Thing id.", :required => true }
  }
}
delete ":id" do
  thing = Thing.find(params[:id])
  error!('Thing Not Found', 404) unless thing
  thing.destroy
  thing.as_json
end
{% endhighlight %}

Aside from the description passed to _desc_, you can specify a hash with anything in it. There’re a few conventions, such as _:params_, which will merge with any values specified in the URL of the API call.

We can introspect the API at runtime, adding a Rake task, for example, that lists all API calls with their parameters.

{% highlight ruby %}
namespace :api do
  desc "Displays all API methods."
  task 'routes' => :environment do
    Api.routes.each do |route|
      route_path = route.route_path.gsub('(.:format)', '').gsub(':version', route.route_version)
      puts "#{route.route_method} #{route_path}"
      puts " #{route.route_description}" if route.route_description
      if route.route_params.is_a?(Hash)
        params = route.route_params.map do |name, desc|
          required = desc.is_a?(Hash) ? desc[:required] : false
          description = desc.is_a?(Hash) ? desc[:description] : desc.to_s
          [name, required, "   * #{name}: #{description} #{required ? '(required)' : ''}"]
        end
        puts "  parameters:"
        params.each { |p| puts p[2] }
      end
    end
  end
end
{% endhighlight %}

Notice how we’ve used the required option for parameters – it’s, once again, a convention. Grape doesn’t care – it’s pure metadata attached to a route. You can create similar conventions in your own API – we have some "partner" and "admin" APIs that we’ve marked in a similar manner.

