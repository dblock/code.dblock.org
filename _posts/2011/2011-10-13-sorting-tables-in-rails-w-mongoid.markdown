---
layout: post
title: "Sorting Tables in Rails w/ Mongoid"
redirect_from: "/sorting-tables-in-rails-w-mongoid"
date: 2011-10-13 14:29:16
tags: [mongoid, rails, ruby]
comments: true
---
Sorting tables in Rails is a common problem. It must have been done before, right? In fact it has been done so many times that it’s really hard to find anything that "just works".  Turned out to waste a lot of time of at least two people with creative libraries that fall short in many rather trivial ways. Of the good ones, a colleague tried [sortable_table](https://github.com/thoughtbot/sortable_table), but it’s not maintained and we finally settled on the much better [handles_sortable_columns](https://github.com/dadooda/handles_sortable_columns), which needed a tiny bit of integration work for Mongoid.

Let's make all our controllers support sorting with the _sort_by_ parameter. Add the following to your _ApplicationController_.

```ruby
handles_sortable_columns do |conf|
  conf.sort_param = "sort_by"
end
```

This lets us add column sorting with sortable_column to a view (_views/tags/index.html.haml_).

```haml
#tags
  %table
    %tr
      %th= sortable_column "Name"
      %th= sortable_column "Count"

    - @tags.each do |tag|
      %tr
        %td.name= link_to h(tag.name), edit_tag_path(tag)
        %td= tag.count
```

We can use sorting on a Mongoid model directly. For a Tag model, this means invoking `Tag.desc(:field)` or `Tag.asc(:field)` by name.

```ruby
sortable_column_order do |column, direction|
  tags = Tag.send(direction, column)
end
```

There’re several issues with this.

We’ve just enabled parameter injection where one can send all kinds of wonderful queries into the Mongoid model by editing the URL.
There’s no clear default sorting, for tags we’d like to sort by count in descending order.

The first issue can be solved by checking whether the direction is one of _:asc_ or _:desc_ and whether a column is a field in the model (added to _config/initializers/mongoid_document.rb_).

```ruby
module Mongoid
  module Document
    module ClassMethods
      def sort_by(sort_column, sort_direction)
        return nil unless ! sort_direction.blank? and [:asc, :desc].include?(sort_direction)
        return nil unless ! sort_column.blank? and self.fields.has_key?(sort_column.to_s)
        return self.send(sort_direction, sort_column)
      end
    end
  end
end
```

Since `sort_by_column` returns `nil` if no sorting has been done, we can use it to introduce a default sort in the _Tags_ controller.

```ruby
class TagsController < ApplicationController
  def index
    sortable_column_order do |column, direction|
        @tags = Tag.sort_by(column, direction)
    end
    @tags ||= Tag.desc(:count)
    ...
  end
  ...
end
```

#### Screenshots

![]({{ site.url }}/images/posts/2011/2011-10-13-sorting-tables-in-rails-w-mongoid/image%5b32%5d.jpg)

I love the attention to detail with the little arrow next to the sorted column as well as the fact that this gem uses the _–column_ syntax for sorting in descending order. It also properly supports pagination. Well done.

![]({{ site.url }}/images/posts/2011/2011-10-13-sorting-tables-in-rails-w-mongoid/image%5b31%5d.jpg)

#### Gem

- [https://github.com/dadooda/handles_sortable_columns](https://github.com/dadooda/handles_sortable_columns)
