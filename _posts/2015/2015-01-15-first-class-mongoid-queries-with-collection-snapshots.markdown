---
layout: post
title: "First Class Mongoid Queries with Collection Snapshots"
date: 2015-01-15
tags: [mongoid, mongodb]
comments: true
---
Consider two domain models, a _Widget_ and a _Gadget_.

{% highlight ruby %}
class Widget
  include Mongoid::Document
end

class Gadget
  include Mongoid::Document
end
{% endhighlight %}

A long running process runs once a day and pairs Widgets and Gadgets based on some complicated algorithm.

{% highlight ruby %}
class WidgetAndGadget
  include Mongoid::Document

  belongs_to :widget, inverse_of: nil
  belongs_to :gadget, inverse_of: nil

  def self.pair!
    WidgetAndGadget.destroy_all
    Widget.all.each do |widget|
      Gadget.all.each do |gadget|
        next unless Random.rand(2) == 1
        WidgetAndGadget.create!(widget: widget, gadget: gadget)
      end
    end
  end
end
{% endhighlight %}

In the example above the collection of _WidgetAndGadget_ has to be destroyed every time before creating new pairs, which leaves it in an incomplete and unusuable state until the operation is finished. Let's attempt to rewrite this implementation in a more incremental manner.

{% highlight ruby %}
class WidgetAndGadget
  def self.pair_incrementally!
    widgets_and_gadgets = []
    Widget.all.each do |widget|
      Gadget.all.each do |gadget|
        next unless Random.rand(2) == 1
        widget = WidgetAndGadget.where(widget: widget, gadget: gadget).first
        widget ||= WidgetAndGadget.create!(widget: widget, gadget: gadget)
        widgets_and_gadgets << widget
      end
    end
    (WidgetAndGadget.all.to_a - widgets_and_gadgets).each do |pair|
      pair.destroy
    end
  end
end
{% endhighlight %}

The code makes a database query per pair and it has to fetch all pairs, then go over the difference to destroy objects. This is terribly inefficient and very problematic for large data sets. Furthermore, during the pairing process new pairs will be inserted before old pairs are destroyed, leaving the entire collection in an inconsistent state, unusable by our application.

We can solve this by creating a new collection every time with the help of [mongoid_collection_snapshot](https://github.com/aaw/mongoid_collection_snapshot). The library takes care of creating a new collection every time, and maintaining a fixed number of _snapshots_ (default is 2).

{% highlight ruby %}
class WidgetsAndGadgets
  include Mongoid::CollectionSnapshot

  def build
    Widget.all.each do |widget|
      Gadget.all.each do |gadget|
        next unless Random.rand(2) == 1
        collection_snapshot.insert(widget_id: widget.id, gadget_id: gadget.id)
      end
    end
  end
end
{% endhighlight %}

Create a new snapshot with `WidgetsAndGadgets.create!` and access the latest snapshot with `WidgetsAndGadgets.latest`. The actual snapshotted data collection is available via `WidgetsAndGadgets.latest.collection_snapshot.find`, which is a _Moped::Collection_.

We can turn this into a first-class Mongoid model, just like the original _WidgetAndGadget_ (currently requires [mongoid_collection_snapshot#10](https://github.com/aaw/mongoid_collection_snapshot/pull/10)).

{% highlight ruby %}
class WidgetsAndGadgets
  include Mongoid::CollectionSnapshot

  document do
    belongs_to :widget, inverse_of: nil
    belongs_to :gadget, inverse_of: nil
  end
end
{% endhighlight %}

Instead of accessing a raw _Moped::Collection_, we get first-class Mongoid documents!

{% highlight ruby %}
WidgetsAndGadgets.latest.documents.each do |pair|
  puts "#{pair.widget} x #{pair.gadget}"
end
{% endhighlight %}

#### Implementation Details

This was a bit tricky to implement. For each collection snapshot we emit a class with a different collection name passed into _store_in_.

{% highlight ruby %}
module CollectionSnapshot
  included do
    def documents
      collection_name = collection_snapshot.name

      klass = Class.new do
        include Mongoid::Document

        # the document block is copied from the document do ... declaration
        instance_eval(&document_block)

        store_in collection: collection_name
      end

      class_name = "#{self.class.name}#{id}".underscore.camelize
      Object.const_set(class_name, klass)

      klass
    end
  end
end
{% endhighlight %}

The actual implementation memoizes emitted classes and supports other advanced features of [mongoid_collection_snapshot](https://github.com/aaw/mongoid_collection_snapshot). See [mongoid_collection_snapshot#10](https://github.com/aaw/mongoid_collection_snapshot/pull/10) for details.

Full code for this article can be found [here](https://gist.github.com/dblock/ded50b61db49baf32a8d).

#### Real World Impact

I spent a day incrementally rewriting snapshot queries inside the Core API project at [Artsy](https://www.artsy.net). We have about two dozen snapshot classes. This resulted in about half the code to accomplish the same thing, virtually no spec changes. A very clear win.

![]({{ site.url }}/images/posts/2015/2015-01-15-first-class-mongoid-queries-with-collection-snapshots/change1.png)

![]({{ site.url }}/images/posts/2015/2015-01-15-first-class-mongoid-queries-with-collection-snapshots/change2.png)

