---
layout: post
title: "A Rake Task for Copying MongoDB Databases"
redirect_from: "/a-rake-task-for-copying-mongodb-databases"
date: 2011-03-27 15:21:19
tags: [rake, mongodb, rails, ruby]
comments: true
---
Now that we have a staging and a production environment, we want to copy all production data to staging at the same time as we push new code to staging via continuous integration. While our code has to generally be resilient to data schema changes – we use NoSQL MongoDB – we don’t want to be in the business of carrying backward compatibility code for too long. Instead, we create data migrations that can run after the new code has been deployed and kill the backward compatibility parts with a future commit after we’ve made sure the data has been properly converted.

The entire continuous integration and continuous deployment process looks like this.

![image]({{ site.url }}/images/posts/2011/2011-03-27-a-rake-task-for-copying-mongodb-databases/image%5b16%5d.jpg)

The interesting part is that we copy the production database to staging before code is deployed so that we can see the results of automated migrations in staging. If things go south, we can make code changes and try again with a clean copy of production data.

#### Push and Pull

One existing solution is data push and pull implemented [here](http://www.theirishpenguin.com/2011/01/20/push-and-pull-data-between-your-local-mongodb-and-heroku-or-mongohq/). But looking at the source code, it’s a row-by-row copy! Ouch.

Let's write a task that will copy one MongoDB database to another using something more efficient.

#### Reading Heroku-San Configuration

We’re using [Heroku-san](http://jqr.github.com/2010/08/27/easy-heroku-deploys-with-heroku-san.html), so we’ve got a _heroku.yml_ sitting in the config folder with two values for MONGOHQ_URL under _staging_ and _production_. We’ll load the file with YAML, fetch _MONGOHQ_URL_ and parse it into parts. For those using regular expressions to parse MongoHQ urls, pay attention: everything except the database name is just a regular piece of a URL.

```ruby
def db_copy_load_config
  YAML.load_file(Rails.root.join("config/heroku.yml")).symbolize_keys
end

def db_copy_config
  @@config_heroku ||= db_copy_load_config
end

def get_mongohq_url(env)
  db_copy_config[env]["config"]["MONGOHQ_URL"]
end

def parse_mongodb_url(url)
  uri = URI.parse(url)
  [uri, uri.path.gsub("/", "")]
end
```

I \*heart\* functions that return two values!

#### Copying Databases

MongoDB has a nifty copyDatabase (or clone) feature described [here](http://www.mongodb.org/display/DOCS/Clone+Database). It’s incremental, so we must drop tables before calling it. We also have to ensure that we don’t drop system tables, otherwise our database may be rendered inaccessible.

```ruby
desc "MongoDB database to database copy"
task :copyDatabase, [:from, :to] => :environment do |t, args|
  from, from_db_name = parse_mongodb_url(args[:from])
  to, to_db_name = parse_mongodb_url(args[:to])
  to_conn = Mongo::Connection.new(to.host, to.port)
  to_db = to_conn.db(to_db_name)
  to_db.authenticate(to.user, to.password)
  to_db.collections.select { |c| c.name !~ /system/ }.each do |c|
    c.drop
  end
  to_conn.copy_database(from_db_name, to_db_name, from.host + ":" + from.port.to_s, from.user, from.password)
end
```

Easy enough. We can call this to copy a production database to staging or to a local instance (for debugging).

```ruby
namespace :production do
  desc "Copy production data to staging"
  task :to_staging => :environment do
    Rake::Task["db:copy:copyDatabase"].execute({ from: get_mongohq_url(:production), to: get_mongohq_url(:staging) })
  end
  desc "Copy production data to local"
  task :to_local => :environment do
    Rake::Task["db:copy:copyDatabase"].execute({ from: get_mongohq_url(:production), to: "mongodb://localhost/development" })
  end
end
```

#### No Admin for you on MongoHQ

If your destination database is on [MongoHQ](http://mongohq.com) you will get the following error.

```
Database command 'copydbgetnonce' failed: {"assertion"=>"unauthorized db:admin lock type:1 client:ip",
  "assertionCode"=>10057, "errmsg"=>"db assertion failure", "ok"=>0.0}
```

This is because copyDatabase requires admin privileges, which MongoHQ doesn’t give co-located users (answer from support in [this thread](http://support.mongohq.com/discussions/questions/199-copy_database-yields-unauthorized-dbadmin-lock-type1)). Too bad - we have to fallback to the silly _mongodump_ and _mongorestore_. This has two major disadvantages: it requires a local mongo installation and copies a ton of data over the network from MongoHQ, then back to MongoHQ. I hope that either MongoHQ exposes this API one day or there’s a non-admin way to do this with MongoDB [[SERVER-2846](http://jira.mongodb.org/browse/SERVER-2846)].

#### Using Mongo Dump and Restore

Falling back to mongodump and mongorestore is trivial. It hurts to do it, but it does work. Here’s the complete _lib/tasks/db_copy.rake_.

```ruby
namespace :db do
 namespace :copy do

  def db_copy_load_config
   YAML.load_file(Rails.root.join("config/heroku.yml")).symbolize_keys
  end

  def db_copy_config
   @@config_heroku ||= db_copy_load_config
  end

  def get_mongohq_url(env)
   db_copy_config[env]["config"]["MONGOHQ_URL"]
  end

  def parse_mongodb_url(url)
   uri = URI.parse(url)
   [uri, uri.path.gsub("/", "")]
  end
 
  namespace :production do
   desc "Copy production data to staging"
   task :to_staging => :environment do
    Rake::Task["db:copy:copyDatabase"].execute({ from: get_mongohq_url(:production), to: get_mongohq_url(:staging) })
   end
   desc "Copy production data to local"
   task :to_local => :environment do
    Rake::Task["db:copy:copyDatabase"].execute({ from: get_mongohq_url(:production), to: "mongodb://localhost:27017/development" })
   end
  end
 
  namespace :staging do
   desc "Copy staging data to local"
   task :to_local => :environment do
    Rake::Task["db:copy:copyDatabase"].execute({ from: get_mongohq_url(:staging), to: "mongodb://localhost:27017/development" })
   end
  end

  desc "MongoDB database to database copy"
  task :copyDatabase, [:from, :to] => :environment do |t, args|
   from, from_db_name = parse_mongodb_url(args[:from])
   to, to_db_name = parse_mongodb_url(args[:to])
   # mongodump
   tmp_db_dir = File.join(Dir.tmpdir, 'db/' + from.host + "_" + from.port.to_s)
   tmp_db_name_dir = File.join(tmp_db_dir, from_db_name)
   FileUtils.rm_rf tmp_db_name_dir if File.directory? tmp_db_name_dir
   system "mongodump -h %s:%s -d %s -u %s -p%s -o %s" % [from.host, from.port, from_db_name, from.user, from.password, tmp_db_dir]
   puts "[#{Time.now}] connecting to #{to_db_name} on #{to.host}:#{to.port} as #{to.user}"
   # clear target database
   to_conn = Mongo::Connection.new(to.host, to.port)
   puts "[#{Time.now}] opening #{to_db_name} on #{to.host}:#{to.port}"
   puts "[#{Time.now}] dropping collections in #{to_db_name} on #{to.host}:#{to.port}"
   to_db = to_conn.db(to_db_name)
   to_db.authenticate(to.user, to.password) unless (to.user.nil? || to.user.blank?)
   to_db.collections.select { |c| c.name !~ /system/ }.each do |c|
    puts " [#{Time.now}] dropping #{c.name}"
    c.drop
   end
   # mongorestore
   if to.user.nil?
    system "mongorestore -h %s:%s -d %s %s" % [to.host, to.port, to_db_name, tmp_db_name_dir]
   else
    system "mongorestore -h %s:%s -d %s -u %s -p%s %s" % [to.host, to.port, to_db_name, to.user, to.password, tmp_db_name_dir]
   end
   puts "[#{Time.now}] db:copy complete"
  end

 end
end
```
