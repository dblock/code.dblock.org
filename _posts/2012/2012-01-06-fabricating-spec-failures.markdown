---
layout: post
title: "Fabricating Spec Failures"
redirect_from: "/fabricating-spec-failures/"
date: 2012-01-06 21:39:10
tags: [rspec, rails, ruby, testing]
comments: true
---
I love fabricators. We use the awesome [fabrication gem](https://github.com/paulelliott/fabrication) that lets you do some pretty neat things in Rails specs.

For example, we have a page that lists users in alphabetical order. The retrieval is implemented in a controller.

```ruby
def index
  @users = User.asc(:name)
end
```

The fabricator for a User generates a global sequence to give each user a unique name.

```ruby
Fabricator(:user) do
  name { Fabricate.sequence(:name) { |i| "Joe #{i}" } }
end
```

To test the above-mentioned controller, we would fabricate a couple users and ensure that they are returned in the correct order.

```ruby
it "returns users in alphabetical order" do
  user1 = Fabricate :user
  user2 = Fabricate :user
  get :index
  assigns(:users).should eq [user1, user2]
end
```

What could possibly go wrong here?

I made a beginner mistake that just looks like someone else’s fault (specs fail depending on which order you run them). To get a failed test we fabricate 8 users before this spec is run. The next two users that are fabricated are _Joe 9_ and _Joe 10_. When sorted alphabetically _Joe 10_ comes before _Joe 9_, duh. It’s a good lesson in not relying on external behavior for tests – in this case we should not rely on knowing how names are generated in a fabricator to test that the users are sorted by name. Instead, we should assign names explicitly.

```ruby
it "returns users in alphabetical order" do
  user1 = Fabricate :user, name: "A"
  user2 = Fabricate :user, name: "B"
  get :index
  assigns(:users).should eq [user1, user2]
end
```
