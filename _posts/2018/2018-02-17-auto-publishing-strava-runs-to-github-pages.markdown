---
layout: post
title: "Auto-Publishing Strava Runs to Github Pages"
date: 2018-02-17
tags: [running, ruby, blog, strava]
comments: true
---
I always hated running. And now I have a [open-source running blog](https://run.dblock.org). Most entries are automatically generated from runs recorded in [Strava](https://www.strava.com/athletes/dblockdotorg) - I'm just too lazy to do it by hand :)

These are the implementation details.

### Jekyll and Github Pages

I started with a basic Jekyll + Github Pages blog like the one you're looking at now. You can read about the basic setup in [this post](/2015/01/07/the-new-code-dblock-dot-org.html). I copied everything from this blog to the new one, deleted all content and customized some logos and colors, mostly in `_config.yml`.

That is [run.dblock.org@6e33b125](https://github.com/dblock/run.dblock.org/commit/6e33b12576b12de6aea85c0e762eb390526bb0f7).

### Getting Data from Strava

I created an app on Strava and noted the access token from [strava.com/settings/api](https://www.strava.com/settings/api) and used it with [strava-ruby-client](https://github.com/dblock/strava-ruby-client) to talk to [Strava's Open API](https://developers.strava.com).

Note that this token expires quickly. See [this post](/2018/11/17/dealing-with-strava-api-token-migration.html) for how to refresh it, in general, and below for how to make this process work in Travis-CI.

{% highlight ruby %}
client = Strava::Api::V3::Client.new(access_token: ENV['STRAVA_API_TOKEN'])

client.athlete_activities do |activity|
  activity.start_date_local # => ...
  activity.time_in_hours # => ...
  activity.average_speed # => ...
  activity.pace_per_mile # => ...
end
{% endhighlight %}

### Plotting Runs with Google Maps

Each activity comes with an encoded summary polyline in `activity.map.summary_polyline`, which can be passed directly to Google Static Maps API with the `enc:` prefix to render a nice image.

{% highlight html %}
<img src='https://maps.googleapis.com/maps/api/staticmap?maptype=roadmap&path=enc:#{activity.map.summary_polyline}&key=...&size=800x800'>
{% endhighlight %}

Google Static Maps API requires a key that you can get from the [console](https://developers.google.com/maps/documentation/static-maps/get-api-key).

### Adding Start and Finish Markers

Strava API does not [unfortunately return precise-enough coordinates to plot start and finish of the runs](https://groups.google.com/forum/#!searchin/strava-api/start_latlng$20maps%7Csort:date/strava-api/ZUAZX8idGaE/MVzOJFH-wjwJ), but we can pluck these out from the decoded polyline using the [polylines gem](https://github.com/joshuaclayton/polylines).

{% highlight ruby %}
require 'polylines'

summary_polyline = activity.map.summary_polyline
decoded_polyline = Polylines::Decoder.decode_polyline(summary_polyline)
start_latlng = decoded_polyline[0]
end_latlng = decoded_polyline[-1]
{% endhighlight %}

These markers are added to the map with `&markers=color:yellow|label:S|#{start_latlng[0]},#{start_latlng[1]}` and `&markers=color:green|label:F|#{end_latlng[0]},#{end_latlng[1]}`.

### Getting Photos

By default Strava API only returns the primary photo. Call `activity_photos` to get all of them and specify `size` for anything other than thumbnails. Note that this seems to be an undocumented Strava API.

{% highlight ruby %}
client.activity_photos(activity.id, size: '600').each do |photo|
  url = photo.urls['600']
  # ...
end
{% endhighlight %}

### Generating Jekyll Pages

I wrote a Rake task that iterates over Strava activities and outputs a `.md` file for each run.

{% highlight ruby %}
filename = [
  "_posts/#{activity.start_date_local.year}/#{activity.start_date_local.strftime('%Y-%m-%d')}",
  activity.type.downcase,
  activity.distance_in_miles,
  activity.time_in_hours
].join('-') + '.md'

FileUtils::mkdir_p "_posts/#{activity.start_date_local.year}"

File.open filename, "w" do |file|
  file.write <<-EOS
---
layout: post
title: "#{activity.name}"
date: "#{activity.start_date_local.strftime('%F %T')}"
---
<ul>
 <li>Distance: #{activity.distance_in_miles}</li>
 <li>Time: #{activity.time_in_hours}</li>
 <li>Pace: #{activity.pace_per_mile}</li>
</ul>
EOS
{% endhighlight %}

For example, [2018/2018-01-21-run-13.34mi-1h47m18s.md](https://github.com/dblock/run.dblock.org/blob/gh-pages/_posts/2018/2018-01-21-run-13.34mi-1h47m18s.md) is generated for a post titled [#FLMH](https://run.dblock.org/2018/01/21/run-13.34mi-1h47m18s.html).

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

To make this process work recurrently, I added `STRAVA_CLIENT_ID`, `STRAVA_CLIENT_SECRET` and `GH_TOKEN` values to Travis-CI UI, then added a daily Cron job. This is because we want Travis to run an update both when code (eg. stylesheet) changes are pushed to Github and when new runs are posted to Strava.

The Strava refresh token must be kept secret and therefore I encrypted it with `travis encrypt STRAVA_API_REFRESH_TOKEN=... --add env`, which adds it to `.travis.yml`. This uses the Travis-CI public key and can only be decrypted in Travis-CI. The Rake task also updates the refresh token if it has changed as a result of the OAuth workflow.

### Finally

Find my running blog at [run.dblock.org](https://run.dblock.org), the latest code for this post at [github.com/dblock/run.dblock.org](https://github.com/dblock/run.dblock.org) and read about why I run [here](https://run.dblock.org/2017/10/01/why-do-i-run.html).
