---
layout: post
title: "A Rake Task for Backing Up a MongoDB Database"
redirect_from: "/a-rake-task-for-backing-up-a-mongodb-database/"
date: 2011-03-31 14:11:54
tags: [s3, rake, mongodb]
comments: true
dblog_post_id: 192
---
It’s time to connect MongoDB with S3 and write a task that backs up a MongoDB database to Amazon S3. This follows a series of articles, so before you read this you might want to check these out.

- [Exporting and Importing MongoDB Data with Rake](/seeding-exporting-and-importing-mongodb-data-with-rake)
- [A Rake Task for Copying MongoDB Databases](/a-rake-task-for-copying-mongodb-databases)
- [A Rake Task for Copying Data Between Amazon S3 Buckets](/a-rake-task-for-copying-data-between-amazon-s3-buckets)

We’re now reusing two pieces of code in all these tasks (I put them into _s3.rake_ and _mongohq.rake _with some bug fixes).

#### mongohq.rake

Given an environment, retrieve its MongoHQ url of a database and parse it from _config/heroku.yml_. This returns an URL and a database name.

{% highlight ruby %}
namespace :mongohq do
  def get_mongohq_url(env = Rails.env)
    @@config ||= YAML.load_file(Rails.root.join("config/heroku.yml")).symbolize_keys
    config_env = @@config[env.to_sym]
    raise "missing '#{env}' section in config/heroku.yml" if config_env.nil?
    config_env["config"]["MONGOHQ_URL"]
  end
  def parse_mongohq_url(url)
    uri = URI.parse(url)
    [uri, uri.path.gsub("/", "")]
  end
end
{% endhighlight %}

#### s3.rake

We only have one set of S3 keys (we call this a production set). Retrieve those keys from _config/heroku.yml_ and open an _S3Interface_ connection to Amazon S3.

{% highlight ruby %}
namespace :s3 do
  def s3i
    @@s3i ||= s3i_open
  end
  def s3i_config
    @@s3i_config ||= YAML.load_file(Rails.root.join("config/heroku.yml")).symbolize_keys
    s3i_config_env = @@s3i_config[:production]
    raise "missing 'production' section in config/heroku.yml" if s3i_config_env.nil?
    s3i_config_env['config']
  end
  def s3i_open
    s3_key_id = s3i_config['S3_ACCESS_KEY_ID']
    s3_access_key = s3i_config['S3_SECRET_ACCESS_KEY']
    RightAws::S3Interface.new(s3_key_id, s3_access_key, { logger: Rails.logger })
  end
end
{% endhighlight %}

#### Backup a MongoDB Database

We’re familiar with MongoDB _mongodump_ and _mongorestore_. The strategy is to create a local backup, compress it and ship it to Amazon S3 into a _daily_ folder that rotates backups. This way we’re going to have a backup every day – the _Monday_ backup, the _Tuesday_ backup, etc. We’ll then copy the latest backup on Amazon itself into a monthly folder to keep forever. This helps us avoid worrying about an ever-growing storage problem as it seems silly to keep years of daily backups.

The complete **db_backup.rake** code below. It’s an iteration over some code that [@sarcilav](https://web.archive.org/web/20120629110557/http://blog.sarcilav.com//) wrote, so I can’t take all the credit. The bonus feature is to be able to backup any current environment to S3 as well as another environment (eg. backup _production_ from the _staging_ server) remotely.

{% highlight ruby %}
namespace :db do

  namespace :production do
    desc "Back the production MongoDB database to Amazon S3."
    task :backup => :environment do
      Rake::Task["db:backupDatabase"].execute({env: :production})
    end
  end

  desc "Backup the current MongoDB database to Amazon S3."
  task :backup => :environment do
    Rake::Task["db:backupDatabase"].execute({env: Rails.env.to_sym})
  end

  desc "Backup a MongoDB database to Amazon S3."
  task :backupDatabase, [:env] => :environment do |t, args|
    env = args[:env] || Rails.env
    logger.info("[#{Time.now}] db:backup started (#{env})")
    db, db_name = parse_mongohq_url(get_mongohq_url(env))
    tmp_db_dir = File.join(Dir.tmpdir, 'db/' + db.host + "_" + db.port.to_s)
    logger.info("[#{Time.now}] clearing (#{tmp_db_dir})")
    FileUtils.rm_rf tmp_db_dir if File.directory? tmp_db_dir
    logger.info("[#{Time.now}] mongodump to (#{tmp_db_dir})")
    if (db.user.nil? || db.user.blank?)
      system("mongodump -h #{db.host}:#{db.port} -d #{db_name} -o #{tmp_db_dir}")
    else
      system("mongodump -h #{db.host}:#{db.port} -d #{db_name} -u #{db.user} -p#{db.password} -o #{tmp_db_dir}")
    end
    backup_name = "#{env}-#{db_name}-#{Time.now.strftime('%Y-%m-%d-%H%M%S')}"
    tmp_db_filename = File.join(tmp_db_dir, backup_name)
    logger.info("[#{Time.now}] compressing (#{tmp_db_filename}.tar.gz)")
    system "tar -cvf #{tmp_db_filename}.tar #{tmp_db_dir}/#{db_name}"
    system "gzip #{tmp_db_filename}.tar"
    bucket_name = "#{s3i_config['S3_BUCKET']}"
    tmp_db_filename_tar_gz = tmp_db_filename + ".tar.gz"
    # daily backup
    daily_backup_key = "db/backup/daily/" + Time.now.strftime("%A") + "/" + db_name + ".tar.gz"
    logger.info("[#{Time.now}] uploading (#{tmp_db_filename}) to s3 #{bucket_name}/#{daily_backup_key}")
    s3i.put(bucket_name, daily_backup_key, File.open(tmp_db_filename_tar_gz))
    # monthly backup
    monthly_backup_key = "db/backup/monthly/" + Time.now.strftime("%Y/%B") + "/" + db_name + ".tar.gz"
    logger.info("[#{Time.now}] copying to #{monthly_backup_key}")
    s3i.copy(bucket_name, daily_backup_key, bucket_name, monthly_backup_key)
    logger.info("[#{Time.now}] uploaded #{File.stat(tmp_db_filename_tar_gz).size} byte(s)")
    logger.info("[#{Time.now}] done.")
  end

end
{% endhighlight %}

Improvements welcome!
