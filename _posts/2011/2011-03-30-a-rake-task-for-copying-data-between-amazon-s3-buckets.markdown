---
layout: post
title: "A Rake Task for Copying Data between Amazon S3 Buckets"
redirect_from: "/a-rake-task-for-copying-data-between-amazon-s3-buckets"
date: 2011-03-30 01:53:39
tags: [s3, rake, ruby]
comments: true
---
![buckets]({{ site.url }}/images/posts/2011/2011-03-30-a-rake-task-for-copying-data-between-amazon-s3-buckets/buckets%5b5%5d.jpg)

Now that we have a Rake task to copy MongoDB databases, we are facing the next problem. We store images on Amazon S3 and each environment has its own S3 bucket. So copying data from production to staging also needs to synchronize the _production_ and the _staging_ S3 buckets, hopefully very quickly for a very large number of files.

We’ll inspire ourselves from [this post](http://www.austinriba.com/2011/02/copy-contents-of-one-s3-bucket-to-another/) and use [right_aws](https://github.com/rightscale/right_aws) to connect to S3 in Ruby. Our S3 keys are stored in the _heroku.yml_ file, your mileage may vary.

```ruby
def s3i
  @@s3 ||= s3i_open
end

def s3i_open
  s3_config = YAML.load_file(Rails.root.join("config/heroku.yml")).symbolize_keys
  s3_key_id = s3_config[:production]['config']['S3_ACCESS_KEY_ID']
  s3_access_key = s3_config[:production]['config']['S3_SECRET_ACCESS_KEY']
  RightAws::S3Interface.new(s3_key_id, s3_access_key, { logger: Rails.logger })
end
```

Once connected we need to fetch all the source keys from the source bucket. You might have heard that Amazon S3 limits a single query to 1000 items, but the right_aws _S3Interface_ has a nice incremental feature. Since we’ll need to compare source and target collections, lets put the items in a hash.

```ruby
logger.info("[#{Time.now}] fetching keys from #{args[:from]}")
source_objects_hash = Hash.new
s3i.incrementally_list_bucket(args[:from]) do |response|
  response[:contents].each do |source_object|
    source_objects_hash[source_object[:key]] = source_object
  end
end
```

My first implementation used the S3 bucket object, which turned out to be very slow. The enumeration with S3Interface takes roughly 30 seconds per 1000 items, cool.  The rest is easy: we’ll walk the source hash, copy any new or changed items and then walk the target hash to delete any old items.

Here’s the full Rake task. Edit your bucket names and run _rake s3:sync:production:to_staging_.

```ruby
require 'logger'

namespace :s3 do
  namespace :sync

    def s3i
      @@s3 ||= s3i_open
    end

    def s3i_open
      s3_config = YAML.load_file(Rails.root.join("config/heroku.yml")).symbolize_keys
      s3_key_id = s3_config[:production]['config']['S3_ACCESS_KEY_ID']
      s3_access_key = s3_config[:production]['config']['S3_SECRET_ACCESS_KEY']
      RightAws::S3Interface.new(s3_key_id, s3_access_key, { logger: Rails.logger })
    end

    desc "Sync production bucket to staging."
    namespace :production do
      desc "Sync production bucket to staging."
      task :to_staging => :environment do
        Rake::Task["s3:sync:syncObjects"].execute({ from: "production", to: "staging" })
      end
    end

    desc "Sync two s3 buckets."
    task :syncObjects, [:from, :to] => :environment do |t, args|
      start_time = Time.now
      logger.info("[#{Time.now}] synchronizing from #{args[:from]} to #{args[:to]}")

      logger.info("[#{Time.now}] fetching keys from #{args[:from]}")
      source_objects_hash = Hash.new
      s3i.incrementally_list_bucket(args[:from]) do |response|
        response[:contents].each do |source_object|
          source_objects_hash[source_object[:key]] = source_object
        end
      end

      logger.info("[#{Time.now}] fetching keys from #{args[:to]}")
      target_objects_hash = Hash.new
      s3i.incrementally_list_bucket(args[:to]) do |response|
        response[:contents].each do |target_object|
          target_objects_hash[target_object[:key]] = target_object
        end
      end

      logger.info("[#{Time.now}] synchronizing #{source_objects_hash.size} => #{target_objects_hash.size} object(s)")

      source_objects_hash.each do |key, source_object|
        target_object = target_objects_hash[key]
        if (target_object.nil?)
          logger.info(" #{key}: copy")
          s3i.copy(args[:from], key, args[:to], key)
        elsif (DateTime.parse(target_object[:last_modified]) < DateTime.parse(source_object[:last_modified]))
          logger.info(" #{key}: update")
          s3i.copy(args[:from], key, args[:to], key)
        else
          logger.info(" #{key}: skip")
        end
      end

      target_objects_hash.each_key do |key|
        if (! source_objects_hash.has_key?(key))
          logger.info(" #{key}: delete")
          s3i.delete(args[:to], key)
        end
      end

      logger.info("[#{Time.now}] done (#{Time.now - start_time})")
    end
  end
end
```

The last issue is object permissions. Files copied via S3Interface don’t have their ACLs copied. In our case we want the newly created files to be public. I started by writing a task to copy permissions from the bucket itself.

```ruby
desc "Apply bucket's ACLs on all keys in it."
task :applyAcl, [:bucket] => :environment do |t, args|
  acl = s3i.get_acl(args[:bucket])
  s3i.incrementally_list_bucket(args[:bucket]) do |response|
    response[:contents].each do |source_object|
      s3i.put_acl(args[:bucket], source_object[:key], acl[:object])
    end
  end
end
```

Unfortunately, this forces me to have a public bucket, meaning the list of files can be enumerated. That’s not what I want. Digging deeper, the S3 interface takes an [x-amz-acl header](http://docs.amazonwebservices.com/AmazonS3/latest/API/) that allows us to specify a canned target ACL during copy.

```ruby
s3i.copy(args[:from], key, args[:to], key, :copy, { 'x-amz-acl' => 'public-read' } )
```

Please suggest any improvements!

