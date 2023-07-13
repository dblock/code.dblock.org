---
layout: post
title: "Grape 0.4.0 Released w/ Stricter JSON Format Support & More"
redirect_from: "/grape-040-released-w-stricter-json-format-support-more/"
date: 2013-03-17 18:30:43
tags: [rack, grape, ruby]
comments: true
dblog_post_id: 378
---
I’m very excited to Release Grape 0.4.0 today. Again, thanks to the 10 (!) contributors to this release.

Is this a solid release? You bet. I’ve upgraded our largest API project at [artsy.net](https://artsy.net) to Grape 0.4.0 and all of the 1870 API specs have passed.

The complete [CHANGELOG is here](https://github.com/ruby-grape/grape/blob/master/CHANGELOG.md). There’re a few backwards incompatible changes that you might want to check out while you’re upgrading.

#### JSON and XML Formatter Changes

Until the 0.4.0 release Grape took a pragmatic approach to JSON response and request data. It was also incorrect.

If your API returned a an _Object_, it was translated to JSON via _to_json_ or a _MultiJson.dump_ call. This worked well for both _Hash_ and _Array_, meanwhile Grape left objects of type _String_ alone. This friendly method ensured that you could translate an object into a _String_, skipping all the hard work Grape’s formatter would otherwise have to do. Similarly, Grape tried to be helpful by ignoring any data that couldn’t be parsed into a hash and therefore retrieved via a call to params from a PUT or POST.

I have fixed this in [@6fa8f59](https://github.com/ruby-grape/grape/commit/6fa8f59e0475f926682168ad4f0bbb2f72df96a3), released with Grape 0.4.0, and it’s now possible to return proper JSON representations of _NilClass_ or _String_, as well as to parse any valid JSON, such as _Array_. This means that if your API implementation returned a _String_ or a _nil_, the output will be different.

{% highlight ruby %}
get "/" do
 "example"
end
{% endhighlight %}

```
# Grape 0.3.x
"example"

# Grape 0.4.0
"\"example\""
```

{% highlight ruby %}
get "/" do
 nil
end
{% endhighlight %}

```
# Grape 0.3.x
""

# Grape 0.4.0
"null"
```

You can monkey-patch back the old behavior as follows.

{% highlight ruby %}
module Grape
 module Formatter
   module Json
     class << self
       def call(object, env)
         return object if ! object || object.is_a?(String)
         return object.to_json if object.respond_to?(:to_json)
         raise Grape::Exceptions::InvalidFormatter.new(object.class, 'json')
       end
     end
   end
 end
end
{% endhighlight %}

Similar changes apply to the XML formatter.

#### Reading Input

With the above changes its now possible to read JSON input that’s not a hash. This was reported as a bug in [#347](https://github.com/ruby-grape/grape/issues/347). Hash parameters continue to be merged into _params_, while everything else is now available in _env[‘api.request.body’]_, you don’t have to parse _env[‘rack.input’]_ again, a notable performance optimization.

#### Default Log Format

Somewhere in version 0.3.2 the default logger format was inadvertently changed to be something like this.

```
I, [2013-02-27T18:39:20.352350 #85986]  INFO -- : one line
I, [2013-02-27T18:39:20.363543 #85986]  INFO -- : two lines
```

This was a side-effect of requiring all of ActiveSupport, reported and fixed in [#353](https://github.com/ruby-grape/grape/issues/353). The logger is now back to be its undecorated version without all those timestamps, levels or process IDs.

If you want the above behavior, _require active_support/all_.
