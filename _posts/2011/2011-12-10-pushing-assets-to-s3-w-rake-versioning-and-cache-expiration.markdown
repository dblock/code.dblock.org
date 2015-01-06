---
layout: post
title: "Pushing Assets to S3 w/ Rake: Versioning and Cache Expiration"
redirect_from: "/pushing-assets-to-s3-w-rake-versioning-and-cache-expiration/"
date: 2011-12-10 20:19:07
tags: [javascript, css, git, cloudfront, s3, rails, ruby]
comments: true
---
A while ago I [wrote](/rails-s3-cloudfront-jammit-heroku-100) about how we package and push Rails assets to Amazon S3. We version assets with the GIT hash – varying the assets by URL enables setting indefinite cache expiration and works well with a CDN. In that post you could find a Rake task that would delete any old assets and replace them with newer assets. It’s time for a revision with some new features.

The first problem we have solved is how long it takes to sync contents between a local folder and S3. The old task fetched the entire bucket file list, which grew quite a bit over time. The S3 API supports a _prefix_ option.

```ruby
s3i.incrementally_list_bucket(to, prefix: "assets/") do |response|
  response[:contents].each do |existing_object|
    ...
  end
end
```

The second issue is with asset rollback. We deploy assets to S3 and then code to Heroku. The asset deployment deletes the old assets. There’s a small window in which we have old code and new assets, which is obviously not okay. We’re actually saved by CloudFront which keeps a cache for extended periods of time. A solution is to keep two copies of the assets online: current and previous. The code preserves the most recent copy by looking at the _:last_modified_ field of the S3 object.

Here’s the task with some shortcuts and a [complete task as a gist](https://gist.github.com/1456181).

```ruby
# uploads assets to s3 under assets/githash, deletes stale assets
task :uploadToS3, [:to] => :environment do |t, args|
  from = File.join(Rails.root, 'public/assets')
  to = args[:to]
  hash = (`git rev-parse --short HEAD` || "").chomp

  logger.info("[#{Time.now}] fetching keys from #{to}")
  existing_objects_hash = {}
  existing_assets_hash = {}
  s3i.incrementally_list_bucket(to, prefix: "assets/") do |response|
    response[:contents].each do |existing_object|
      existing_objects_hash[existing_object[:key]] = existing_object
      previous_asset_hash = existing_object[:key].split('/')[1]
      existing_assets_hash[previous_asset_hash] ||= DateTime.parse(existing_object[:last_modified])
    end
  end

  logger.info("[#{Time.now}] #{existing_assets_hash.count} existing asset(s)")
  previous_hash = nil
  existing_assets_hash.each_pair do |asset_hash, last_modified|
    logger.info(" #{asset_hash} => #{last_modified}")
    previous_hash = asset_hash unless (previous_hash and existing_assets_hash[previous_hash] > last_modified)
  end
  logger.info("[#{Time.now}] keeping #{previous_hash}") if previous_hash

  logger.info("[#{Time.now}] copying from #{from} to s3:#{to} @ #{hash}")
  Dir.glob(from + "/\*\*/\*").each do |entry|
    next if File::directory?(entry)
    File.open(entry) do |entry_file|
      content_options = {}
      content_options['x-amz-acl'] = 'public-read'
      content_options['content-type'] = MIME::Types.type_for(entry)[0]
      key = 'assets/'
      key += (hash + '/') if hash
      key += entry.slice(from.length + 1, entry.length - from.length - 1)
      existing_objects_hash.delete(key)
      logger.info("[#{Time.now}]  uploading #{key}")
      s3i.put(to, key, entry_file, content_options)
    end
  end

  existing_objects_hash.keys.each do |key|
    next if previous_hash and key.start_with?("assets/#{previous_hash}/")
    puts "deleting #{key}"
    s3i.delete(to, key)
  end
end
```

Since we’re versioning assets with a GIT hash in the URL, another improvement is to set cache expiration to something longer.

```ruby
content_options['cache-control'] = "public, max-age=#{365\*24\*60\*60}"
```
