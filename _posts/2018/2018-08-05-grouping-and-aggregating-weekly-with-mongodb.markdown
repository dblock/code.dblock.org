---
layout: post
title: "Grouping and Aggregating Weekly in MongoDB"
date: "2018-08-05"
tags: [react native, 33 minutes, mongodb, mongoid]
---
Given a collection of events, aggregate their duration weekly. Fill gaps to contain every week since the earliest event.

### Data Model

Users have meetings.

{% highlight ruby %}
class Meeting
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActionView::Helpers::DateHelper

  field :started_at, type: DateTime
  field :finished_at, type: DateTime

  belongs_to :user
end
{% endhighlight %}

### Duration Aggregated Weekly

The following aggregation matches any documents that belong to a user, groups and sorts them by year and week number, then counts and sums their durations.

{% highlight ruby %}
user.meetings.collection.aggregate([
  { '$match' => { user_id: user.id } },
  {
    '$group' => {
      _id: {
        year: { '$year' => '$started_at' },
        week: { '$isoWeek' => '$started_at' }
      },
      count: { '$sum' => 1 },
      duration: { '$sum' => { '$subtract' => ['$finished_at', '$started_at'] } }
    }
  },
  { '$sort' => { _id: -1 } }
])
{% endhighlight %}

### Filling Gaps

The code above will miss any week without data. It's easier to fill those in Ruby by iterating over weeks, starting with the current week and finishing with the week of the oldest available data.

{% highlight ruby %}
# current week start
week_start = Time.now.utc.beginning_of_week.to_date

# use the week_start from the last record or the current week
last_week_start = data.empty? ? week_start : data.values[-1].week_start

while week_start >= last_week_start
  results << ... # either from data or a blank entry
  week_start -= 1.week
end
{% endhighlight %}

### Complete Code

See [weekly_meetings.rb](https://github.com/33-minutes/33-minutes-server/blob/master/app/models/weekly_meetings.rb) for a complete implementation.
