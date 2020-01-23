---
layout: post
title: "Restoring Data into a MongoDB Dokku Container"
date: "2020-01-20"
tags: [dokku, mongodb]
---
I've been running a pet project using Dokku on DigitalOcean for a number of years with MongoDB, backing up data into Dropbox. See [Running Slack Bots on DigitalOcean with Dokku](/2016/02/08/running-slack-bots-on-digital-ocean-with-dokku.html) and [Backing up MongoDB Databases in Dokku Containers to Dropbox](/2016/02/15/backing-up-mongodb-databases-in-dokku-containers-to-dropbox.html).

Today I had to selectively export data from a backup, and restore this data into a MongoDB running inside a Dokku container. This was a bit tedious.

### Exporting a Subset of Data

I am dealing with [slack-gamebot](https://github.com/dblock/slack-gamebot) data, which contains a `teams` collection with a row per team and related data in other collections, including `users` and `matches`. I wrote a [bash script](https://github.com/dblock/slack-gamebot/blob/de126127f65fb5d8a2f3f5fc9a510f4460e67517/script/export-team) to export this data.

Construct a query string, eg. `{"team_id":"ID"}` and fetch the `_id` value for querying relationships.

{% highlight bash %}
TEAM_QUERY='{"team_id":"'"$TEAM_ID"'"}'
ID=`mongo $DB --quiet --eval "db.teams.findOne($TEAM_QUERY)._id.valueOf()"`
{% endhighlight %}

Export team data.

{% highlight bash %}
mongoexport --db $DB -c teams --out $OUT/teams.dump --query=$TEAM_QUERY
{% endhighlight %}

Construct a query string with the MongoDB Object ID, an `$oid`.

{% highlight bash %}
ID_QUERY='{"team_id":{"$oid":"'"$ID"'"}}'
{% endhighlight %}

Export all related collections.

{% highlight bash %}
for coll in challenges matches seasons users
do
  mongoexport --db $DB -c $coll --out $OUT/$coll.dump --query=$ID_QUERY
done
{% endhighlight %}

We now have files such as `teams.dump`, `users.dump`, etc.

### Expose Containerized MongoDB

Expose the MongoDB in a container on the Dokku host so we can connect to it.

{% highlight bash %}
dokku mongo:expose app
{% endhighlight %}

This will randomly assign ports. You can run `dokku mongo:info app` to see the exposed ports.

{% highlight bash %}
# dokku mongo:info app
=====> Container Information
       ...
       Exposed ports:       27017->13450 27018->25362 27019->18545 28017->29405
       Dsn:                 mongodb://username:password@dokku-mongo-app:27017/app
       Status:              running
       Version:             mongo:3.2.1
{% endhighlight %}

Note the mapping for `27017`, mine is `13450` and the username and password.

Try connecting to the database directly with `mongo`. Make sure the client version matches the version of MongoDB inside the container - I was getting confusing errors until I ran `apt-get mongodb-org-shell` and `apt-get mongodb-org-tools` to get a MongoDB 3.x client.

### Restore Data

{% highlight bash %}
mongoimport --host=... --port=13450 --username=username --password=password --db app -c teams teams.dump
{% endhighlight %}

### Unexpose MongoDB

{% highlight bash %}
dokku mongo:unexpose app
{% endhighlight %}



