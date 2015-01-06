---
layout: post
title: "Models look nice, but sometimes you just want to change they way they feel"
redirect_from: "/models-look-nice-but-sometimes-you-just-want-to-change-they-way-they-feel/"
date: 2011-03-16 14:15:30
tags: [mongodb, rails, ruby]
comments: true
dblog_post_id: 183
---
MongoId models provide an excellent level of abstraction. Consider a _User_ model.

```ruby
class User
  include Mongoid::Document

  devise :invitable, :database_authenticatable, ...

  field :name, :type => String
  field :email, :type => String
end
```

We have derived an _Admin _type from it.

```ruby
class Admin < User

end
```

This avoids having to have an explicit user type. In the database the distinction will be the `_type` field and correct objects are instantiated by querying auto-magically.

But how do we promote a _User_ into an _Admin_?

We have to change the internal `_type` field. So far I found only one way, reach down to MongoDB and update the field explicitly.

```ruby
def self.promote!(user)
    users = Mongoid.master.collection('users')
    users.update( { :"_id" => user.id }, { :"$set" => { :"_type" => "Admin" }})
end
```

I feel dirty. Is there a better way?

