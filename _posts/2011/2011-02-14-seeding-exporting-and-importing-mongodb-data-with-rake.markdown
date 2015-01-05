---
layout: post
title: "Seeding, exporting and importing MongoDB data with Rake"
redirect_from: "/seeding-exporting-and-importing-mongodb-data-with-rake"
date: 2011-02-14 16:55:45
tags: [rake, mongodb, rails, ruby]
comments: true
---
![image]({{ site.url }}/images/posts/2011/2011-02-14-seeding-exporting-and-importing-mongodb-data-with-rake/image%5b2%5d.jpg)

You may have noticed some Ruby on Rails posts lately on my blog. That’s because I am working on something. More about it in a few weeks. In the meantime, all you need to know is that it’s an application with a lot of meaningful and interesting data. Without a representative data set the application is useless and with a fake set of data the application would produce confusing results. Imagine that we are building a website for drug manufacturers to search for chemical ingredients of specific drugs – we’d like to be able to find Aspirin in the development environment and see that it’s made of acetylsalicylic acid, carnauba wax, corn starch, hypromellose, powdered cellulose and triacetin. Finding real answers validates our software and enables developers catch bugs early. We want real data, but just not all of it.

I tried _mongodump_ and _mongorestore_. Those are straightforward tools that let you export and import Mongo data (Mongo people did their job very well there, much less hassle than with a traditional RDBMS where you have to backup the database, deal with the transaction log, bla bla bla). All is well when working with local machines. Remotely, you need to go the extra step of figuring out the database address, username and password. This gets messier with Heroku and eventually starts smelling bad.

I want to do this the "Rails Way" by invoking a single _rake_ command that imports and exports Mongo data in any of my environments. The following is based on [this post](http://railsfreak.com/post/481785306/grow-your-app-from-seeds), but we’re doing this with MongoDB and will take it a little further. We’ll put our tasks in _lib/tasks/db_import_export.rake_.

#### Exporting Data

Given a set of objects, we can serialize them to a file using JSON. We’ll give the model name and a file as a parameter, fetch all objects and write them to a file in JSON format.

```ruby
task :export, [:model, :filename] => :environment do |t, args|
  model = args[:model].constantize
  filename = args[:filename]
  objects = model.find(:all)
  File.open(File.join(Rails.root, filename), "w") do |f|
    objects.each do |object|
      f.write(object.to_json)
      f.write("\r\n")
    end
  end
end
```

#### Importing Data

Importing data is the inverse operation. We have to clear the model data – I couldn’t figure out how to instantiate an object that exists and resave it with changes [[thread](http://groups.google.com/group/mongoid/browse_thread/thread/0c28c14d0c1c48cd#)].

```ruby
task :import, [:model, :filename] => :environment do |t, args|
  model = args[:model].constantize
  model.destroy_all
  filename = args[:filename]
  File.foreach(File.join(Rails.root, filename)) do |line|
      next if line.blank?
      object = model.new.from_json line.strip
      object.save!
  end
end
```

#### Putting it Together

We can call our tasks on several well-known collections. Of course, feel free to extend this to iterate through all Mongo collections and post your code as a comment here.

```ruby
namespace :db do
    def collections
    [
      { model: "Drug", table: "drugs" },
      { model: "Ingredient", table: "ingredients" },
      { model: "User", table: "users" }
    ]
    end
    task :export => :environment do
        collections.each do |collection|
          table = collection[:table]
          model = collection[:model]
          dir = "db/seed/" + Rails.env
          filename = dir + "/" + table + ".json"
          Dir.mkdir dir unless (Dir.exists? dir)
          Rake::Task["db:model:export"].execute({model: model, filename: filename})
        end
    end
    task :import => :environment do
        collections.each do |collection|
          table = collection[:table]
          model = collection[:model]
          dir = "db/seed/" + Rails.env
          filename = dir + "/" + table + ".json"
          Rake::Task["db:model:import"].execute({model: model, filename: filename})
        end
    end
end
```

#### Faking Data

There’re two other interesting implementation details worth mentioning.

The first is that we have a _User_ model that has a username and password. Of course we use the awesome [devise](https://github.com/plataformatec/devise) and importing and exporting password data doesn’t do anything (we’re missing the salt value and the system stores an encrypted password hash anyway). Whenever we encounter a "password" field during import, we simply replace it with a fixed value.

```ruby
object = model.new.from_json line.strip
object.password = "password" if (object.respond_to? 'password')
```

The second feature is that we don’t want real user data to be exported, but we’d like to preserve the relationships in the existing database. We use [faker](http://faker.rubyforge.org/) to replace all names, e-mails and websites. This can be further applied to all kinds of properties.

```ruby
object.name = Faker::Name.name
object.email = Faker::Internet.email
object.website = Faker::Internet.domain_name
```

#### Famous Last Thoughts

Finally, all we have to do is to tweak and change the files generated by rake _db:export_ to our liking and commit them with git. New developers can simply run `rake db:import` to get started instead of a `rake db:seed`.

I think this could serve as a good start for a collection of tasks that ship with MongoId. Thoughts? Comments?
