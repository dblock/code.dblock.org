---
layout: post
title: "Installing, Starting and Waiting for ElasticSearch in Travis-CI"
date: 2017-02-10
tags: [elasticsearch, travis-ci]
comments: true
---
If you're like me, a `sleep` inside a script for anything longer than a second is a crime. So lets install and start ElasticSearch on Travis-CI and curl it until it's up and running.

{% highlight bash %}
before_install:
  - curl -O https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.5.2.deb
  - sudo dpkg -i --force-confnew elasticsearch-1.5.2.deb
  - sudo /etc/init.d/elasticsearch start
  - until curl --silent -XGET --fail https://localhost:9200; do printf '.'; sleep 1; done
{% endhighlight %}

Which gives ...

{% highlight bash %}
$ until curl --silent -XGET --fail https://localhost:9200; do printf '.'; sleep 1; done
.......{
  "status" : 200,
  "name" : "Silver Scorpion",
  "cluster_name" : "elasticsearch",
  "version" : {
    "number" : "1.5.2",
    "build_hash" : "62ff9868b4c8a0c45860bebb259e21980778ab1c",
    "build_timestamp" : "2015-04-27T09:21:06Z",
    "build_snapshot" : false,
    "lucene_version" : "4.10.4"
  },
  "tagline" : "You Know, for Search"
}
{% endhighlight %}

Beautiful.

This is from [estella#25](https://github.com/artsy/estella/pull/25), a Ruby DSL for ElasticSearch.
