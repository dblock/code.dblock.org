---
layout: post
title: "Auto-Publishing Strava Runs to Github Pages"
date: 2018-02-17
tags: [running, ruby, blog]
comments: true
---
I always hated running. And now I have a [open-source running blog](http://run.dblock.org). Most entries are automatically generated from runs recorded in [Strava](https://www.strava.com/athletes/dblockdotorg) - I'm just too lazy to do it by hand :)

<b>Update</b>: if you're going to want to copy code from here, you might want to check out [slack-strava](https://github.com/dblock/slack-strava), which was inspired by this post and has a much cleaner implementation of activities and maps.

These are the implementation details.

### Jekyll and Github Pages

I started with a basic Jekyll + Github Pages blog like the one you're looking at now. You can read about the basic setup in [this post](/2015/01/07/the-new-code-dblock-dot-org.html). I copied everything from this blog to the new one, deleted all content and customized some logos and colors, mostly in `_config.yml`.

That is [run.dblock.org@6e33b125](https://github.com/dblock/run.dblock.org/commit/6e33b12576b12de6aea85c0e762eb390526bb0f7).

### Getting Data from Strava

I used the [strava-api-v3](https://github.com/jaredholdcroft/strava-api-v3) gem that talks to [Strava's Open API](https://developers.strava.com). To make this work I had to create an app on Strava and copy-paste the "public access" token from [strava.com/settings/api](https://www.strava.com/settings/api).

{% highlight ruby %}
client = Strava::Api::V3::Client.new(access_token: ENV['STRAVA_API_TOKEN'])

page = 1
loop do
  activities = client.list_athlete_activities(page: page, per_page: 10)
  break unless activites.any?
  activities.each do |activity|
    start_date_local = DateTime.parse(activity['start_date_local'])
    distance_in_miles = '%.2fmi' % (activity['distance'] * 0.00062137)
    time_in_hours = '%dh%02dm%02ds' % [
      activity['moving_time']/3600%24,
      activity['moving_time']/60%60,
      activity['moving_time']%60
    ]
    average_speed = '%.2fmph' % (activity['average_speed'] * 2.23694)
    pace_per_mile = Time.at((60*60)/(activity['average_speed'] * 2.23694)).utc.strftime("%M:%S")

    # etc.

  end
  page += 1
end
{% endhighlight %}

A lot of this "math" belongs in strava-api-v3 - maybe a good opportunity to contribute, so I opened [strava-api-v3#36](https://github.com/jaredholdcroft/strava-api-v3/issues/36).

The above code is [run.dblock.org@1927f128](https://github.com/dblock/run.dblock.org/commit/1927f128559b74035ba80d52c465d70d371a9cf1) with pagination fixed in [run.dblock.org@f3eac93b](https://github.com/dblock/run.dblock.org/commit/f3eac93b36bff08f0163c349006d905bbee2cf68?w=1).

### Plotting Runs with Google Maps

Each activity comes with an encoded summary polyline in `activity['map']['summary_polyline']`, which can be passed directly to Google Static Maps API with the `enc:` prefix to render a nice image.

{% highlight html %}
<img src='https://maps.googleapis.com/maps/api/staticmap?maptype=roadmap&path=enc:#{activity['map']['summary_polyline']}&key=...&size=800x800'>
{% endhighlight %}

Google Static Maps API requires a key that you can get from the [console](https://developers.google.com/maps/documentation/static-maps/get-api-key).

### Adding Start and Finish Markers

Strava API does not [unfortunately return precise-enough coordinates to plot start and finish of the runs](https://groups.google.com/forum/#!searchin/strava-api/start_latlng$20maps%7Csort:date/strava-api/ZUAZX8idGaE/MVzOJFH-wjwJ), but we can pluck these out from the decoded polyline using the [polylines gem](https://github.com/joshuaclayton/polylines).

{% highlight ruby %}
require 'polylines'

summary_polyline = activity['map']['summary_polyline']
decoded_polyline = Polylines::Decoder.decode_polyline(summary_polyline)
start_latlng = decoded_polyline[0]
end_latlng = decoded_polyline[-1]
{% endhighlight %}

These markers are added to the map with `&markers=color:yellow|label:S|#{start_latlng[0]},#{start_latlng[1]}` and `&markers=color:green|label:F|#{end_latlng[0]},#{end_latlng[1]}` in [run.dblock.org@7b25c263](https://github.com/dblock/run.dblock.org/commit/7b25c26343d024c177d0613044f5bd6d23312bee).

### Getting Photos

By default Strava API only returns the primary photo. Call `list_activity_photos` to get all of them and specify `size` for anything other than thumbnails.

{% highlight ruby %}
client.list_activity_photos(activity['id'], size: '600').each do |photo|
  url = photo['urls']['600']
  # ...
end
{% endhighlight %}

This is [run.dblock.org@84d67788](https://github.com/dblock/run.dblock.org/commit/84d67788dd0ee16cf1d4ad9fe8d382517c71292d).

### Generating Jekyll Pages

I wrote a Rake task that iterates over Strava activities and outputs a `.md` file for each run.

{% highlight ruby %}
filename = [
  "_posts/#{start_date_local.year}/#{start_date_local.strftime('%Y-%m-%d')}",
  activity['type'].downcase,
  distance_in_miles,
  time_in_hours
].join('-') + '.md'

FileUtils::mkdir_p "_posts/#{start_date_local.year}"

File.open filename, "w" do |file|
  file.write <<-EOS
---
layout: post
title: "#{activity['name']}"
date: "#{start_date_local.strftime('%F %T')}"
---
<ul>
 <li>Distance: #{distance_in_miles}</li>
 <li>Time: #{time_in_hours}</li>
 <li>Pace: #{pace_per_mile}</li>
</ul>
EOS
{% endhighlight %}

For example, [2018/2018-01-21-run-13.34mi-1h47m18s.md](https://github.com/dblock/run.dblock.org/blob/gh-pages/_posts/2018/2018-01-21-run-13.34mi-1h47m18s.md) is generated for a post titled [#FLMH](http://run.dblock.org/2018/01/21/run-13.34mi-1h47m18s.html).

You can see the complete Rake task [here](https://github.com/dblock/run.dblock.org/blob/gh-pages/Rakefile).

### Update Script

I wrote a bash script that runs `rake strava:update` and commits changes, if any, to Github.

To commit to Github you need a `public_repo` permission token. Create one in [github.com/settings/tokens](https://github.com/settings/tokens). Set it as `GH_TOKEN`.

{% highlight yaml %}
#!/bin/bash

set -e
set -o pipefail

bundle exec rake strava:update

gh_token="${GH_TOKEN-}"

if [ -z "$gh_token" ]
then
  echo "GH_TOKEN is not set. Cannot proceed." >&2
  exit 1
fi

git config --global user.name "Run Buildbot"
git config --global user.email "dblock+run@dblock.org"
git add .
if ! git diff --quiet --staged
  then
    git commit -m "Updated from Strava, `date +%Y/%m/%d`."
    git push "https://${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git" HEAD:gh-pages
 else
   echo "Nothing has changed! I hope that's what you expected." >&2
fi
{% endhighlight %}

And configured Travis-CI to run the script in `.travis.yml`.

{% highlight yaml %}
language: ruby

rvm:
  - 2.4.1

script:
  - bash ./_scripts/update.sh

branches:
  only:
    - gh-pages
{% endhighlight %}

This is [run.dblock.org@2a08d5ec](https://github.com/dblock/run.dblock.org/commit/2a08d5ec0b97a49003ccf8f69c467d7a693ad2a2).

### Travis-CI Cron

I added `STRAVA_API_TOKEN` and `GH_TOKEN` values to Travis-CI UI, then added a daily Cron job. This is because we want Travis to run an update both when code (eg. stylesheet) changes are pushed to Github and when new runs are posted to Strava.

### Finally

Find my running blog at [run.dblock.org](http://run.dblock.org), the latest code for this post at [github.com/dblock/run.dblock.org](https://github.com/dblock/run.dblock.org) and read about why I run [here](http://run.dblock.org/2017/10/01/why-do-i-run.html).
