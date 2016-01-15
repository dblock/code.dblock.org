---
layout: post
title: "Downgrading a Yum Package with Chef"
date: 2016-01-15
tags: [chef, devops]
comments: true
---
I was upgrading a system to MongoDB 3.2.0 and found a bug, [TOOLS-1039: mongoexport chokes on data with quotes](https://jira.mongodb.org/browse/TOOLS-1039). Yikes.

We ended up downgrading `mongodb-org-tools` instead of rolling back the entire database upgrade, here's the recipe.

{% highlight ruby %}
# install and configure mongodb, https://supermarket.chef.io/cookbooks/mongodb3
include_recipe 'mongodb3::default'

# downgrade mongoexport, see https://jira.mongodb.org/browse/TOOLS-1039
yum_repository 'mongodb-org-2.6' do
  description 'MongoDB 2.6 Repository'
  baseurl 'http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/'
  gpgcheck false
  action :create
end

yum_package 'mongodb-org-tools' do
  allow_downgrade true
  action :install
  version '2.6.11-1'
end
{% endhighlight %}

Which gives.

{% highlight bash %}
[db@rails-app1 ~]$ mongo --version
MongoDB shell version: 3.2.0
[db@rails-app1 ~]$ mongoexport --version
version 2.6.11
{% endhighlight %}
