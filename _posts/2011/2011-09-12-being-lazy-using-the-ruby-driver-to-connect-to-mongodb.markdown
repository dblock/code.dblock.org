---
layout: post
title: "Being Lazy: Using the Ruby driver to connect to MongoDB"
redirect_from: "/being-lazy-using-the-ruby-driver-to-connect-to-mongodb/"
date: 2011-09-12 17:57:45
tags: [rake, mongodb, ruby]
comments: true
dblog_post_id: 265
---
One of my rake tasks failed with an interesting error this morning.

```
uncaught exception: error: { "$err" : "not master and slaveok=false", "code" : 13435 }
```

Qu’est-ce que c’est?

The problem is that I am connecting to a slave in a replica set and trying to execute a write operation that must happen on a master node. That’s because I was lazy and was executing command-line update queries, such as this one. I was being lazy. Shame on me.

{% highlight ruby %}
system "mongo #{db_host}:#{db_port}/#{db_name} -u #{db_user} -p#{db_password} --eval 'db.widgets.drop()'"
{% endhighlight %}

This is run in a Rake task. Let's replace this with some Ruby code, the way it’s ought to be.

{% highlight ruby %}
db = Mongo::Connection.new(db_host, db_port).db(db_name)
db.authenticate(db_user, db_password) unless (db.user.nil? || db.user.blank?)
db.collection("widgets").drop()
{% endhighlight %}

It’s actually a lot cleaner, I am not sure why I was hung up on the command line thing. Unfortunately it doesn’t fix our problem. In a replica set we need to use a [ReplSetConnection](http://api.mongodb.org/ruby/current/Mongo/ReplSetConnection.html) that will automatically load-balance requests and send writes to the master. It takes a list of hosts, something like

{% highlight ruby %}
db_connection = Mongo::ReplSetConnection.new(db_host_list).db(db_name)
db_connection.authenticate(db_user, db_password)
db_connection("widgets").drop()
{% endhighlight %}

Let's try to write something usable in all of our rake tasks. What I have is a YML file with the Heroku MongoHQ configuration. The first environment is a replica set, while the second is a single MongoDB.

{% highlight yaml %}
production:
  config:
    MONGOHQ_URL:      "mongodb://heroku:password@replica.mongohq.com:12345/production-name"
    MONGOHQ_DATABASE:   "db-name"
    MONGOHQ_HOST_LIST:  "[['node0.replica.mongohq.com', 12345], ['node1.replica.mongohq.com', 12345]]"
    MONGOHQ_PASSWD:     "password"
    MONGOHQ_USER:     "heroku"

staging:
  config: &default
    MONGOHQ_URL:      "mongodb://heroku:password@small.mongohq.com:12345/staging-name"
{% endhighlight %}

We can write a basic _connect_  method that picks up the right configuration, as a Rake task.

{% highlight ruby %}
namespace :mongohq do

  def heroku_config(env = Rails.env)
    @@config ||= YAML.load_file(Rails.root.join("config/heroku.yml")).symbolize_keys
    config_env = @@config[env.to_sym]
    raise "missing '#{env}' section in config/heroku.yml" if config_env.nil?
    config_env["config"]
  end

  def parse_mongohq_url(url)
    uri = URI.parse(url)
    [uri, uri.path.gsub("/", "")]
  end

  # connect to a MongoDB
  def mongohq_connect(env = Rails.env)
    config = heroku_config(env)
    if ! config["MONGOHQ_HOST_LIST"].blank?
    mongohq_host_list = eval(config["MONGOHQ_HOST_LIST"])
    puts "[#{Time.now}] connecting to #{config["MONGOHQ_DATABASE"]} on #{eval(config["MONGOHQ_HOST_LIST"])}"
    db_connection = Mongo::ReplSetConnection.new(\* mongohq_host_list).db(config["MONGOHQ_DATABASE"])
    db_connection.authenticate(config["MONGOHQ_USER"], config["MONGOHQ_PASSWD"])
    db_connection
    elsif ! config["MONGOHQ_URL"].blank?
    puts "[#{Time.now}] connecting to #{config["MONGOHQ_URL"]}"
    db, db_name = parse_mongohq_url(config["MONGOHQ_URL"])
    db_connection = Mongo::Connection.new(db.host, db.port).db(db_name)
    db_connection.authenticate(db.user, db.password) unless (db.user.nil? || db.user.blank?)
    db_connection
    else
    raise "missing MONGOHQ_URL or MONGOHQ_HOST_LIST for #{env} environment"
    end
  end

end
{% endhighlight %}

Now, our rake tasks can call `mongohq_connect(:production)` or `mongohq_connect(:staging)` without having to worry about the kind of setup we have.
