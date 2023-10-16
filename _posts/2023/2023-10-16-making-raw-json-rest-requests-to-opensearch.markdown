---
layout: post
title: Making Raw JSON REST Requests to OpenSearch
date: 2023-10-16
tags: [opensearch]
comments: true
---
OpenSearch clients implement various high-level REST DSLs to invoke OpenSearch APIs. Efforts such as [opensearch-clients#19](https://github.com/opensearch-project/opensearch-clients/issues/19) aim at generating these from spec in order to always be up-to-date with the default distribution, including plugins. However this is a game that cannot be won. Clients will always lag behind, and users often find themselves in a situation that requires them to invoke an API that is not supported by the client. Thus, in [opensearch-clients#62](https://github.com/opensearch-project/opensearch-clients/issues/62) I proposed we level up all OpenSearch language clients in their capability to make raw JSON REST requests. You help on these issues would be very much appreciated.

In this post I'll keep current state with links to working samples, similar to [Making AWS SigV4 Authenticated Requests to Amazon OpenSearch](/2022/07/11/making-sigv4-authenticated-requests-to-managed-opensearch.html). For all these I am running a local copy of OpenSearch 2.9 in docker.

{% highlight bash %}
docker run \
  -p 9200:9200 \
  -p 9600:9600 \
  -e "discovery.type=single-node" \
  opensearchproject/opensearch:latest
{% endhighlight %}

### Command Line

We'll be looking for the equivalent of the four `GET`, `POST`, `PUT` and `DELETE` operations.

#### [curl](https://curl.se/)

{% highlight bash %}
curl -k -u admin:admin https://localhost:9200
{% endhighlight %}

{% highlight json %}
{
  "name" : "5d98546c8098",
  "cluster_name" : "docker-cluster",
  "cluster_uuid" : "Hu0dA0iYREiBVPqEuHqYaA",
  "version" : {
    "distribution" : "opensearch",
    "number" : "2.9.0",
    "build_type" : "tar",
    "build_hash" : "1164221ee2b8ba3560f0ff492309867beea28433",
    "build_date" : "2023-07-18T21:22:48.164885046Z",
    "build_snapshot" : false,
    "lucene_version" : "9.7.0",
    "minimum_wire_compatibility_version" : "7.10.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "The OpenSearch Project: https://opensearch.org/"
}
{% endhighlight %}

{% highlight bash %}
curl -k -u admin:admin \
  -X POST \
  -H "Content-type:application/json" \
  --data '{"director":"Bennett Miller","title":"Moneyball","year":2011}' \
  https://localhost:9200/movies/_doc/1 | jq
{% endhighlight %}

{% highlight json %}
{
  "_index": "movies",
  "_id": "1",
  "_version": 1,
  "result": "created",
  "_shards": {
    "total": 2,
    "successful": 1,
    "failed": 0
  },
  "_seq_no": 1,
  "_primary_term": 1
}
{% endhighlight %}

{% highlight bash %}
curl -k -u admin:admin \
  -X GET \
  https://localhost:9200/movies/_doc/1 | jq
{% endhighlight %}

{% highlight json %}
{
  "_index": "movies",
  "_id": "1",
  "_version": 1,
  "_seq_no": 2,
  "_primary_term": 1,
  "found": true,
  "_source": {
    "director": "Bennett Miller",
    "title": "Moneyball",
    "year": 2011
  }
}
{% endhighlight %}

{% highlight bash %}
curl -k -u admin:admin \
  -X PUT \
  -H "Content-type:application/json" \
  --data '{"director":"Bennett Miller","title":"Moneyball","year":2011}' \
  https://localhost:9200/movies/_doc/1 | jq
{% endhighlight %}

{% highlight json %}
{
  "_index": "movies",
  "_id": "1",
  "_version": 3,
  "result": "updated",
  "_shards": {
    "total": 2,
    "successful": 1,
    "failed": 0
  },
  "_seq_no": 2,
  "_primary_term": 1
}
{% endhighlight %}

{% highlight bash %}
curl -k -u admin:admin \
  -X DELETE \
  https://localhost:9200/movies/_doc/1 | jq
{% endhighlight %}

{% highlight json %}
{
  "_index": "movies",
  "_id": "1",
  "_version": 4,
  "result": "deleted",
  "_shards": {
    "total": 2,
    "successful": 1,
    "failed": 0
  },
  "_seq_no": 3,
  "_primary_term": 1
}
{% endhighlight %}

### Java

#### [opensearch-java](https://github.com/opensearch-project/opensearch-java)

{% highlight java %}
{% endhighlight %}

Feature request, [opensearch-java#257](https://github.com/opensearch-project/opensearch-java/issues/257).

### Ruby

#### [opensearch-ruby](https://github.com/opensearch-project/opensearch-ruby)

{% highlight ruby %}
{% endhighlight %}

Feature request, [opensearch-ruby#209](https://github.com/opensearch-project/opensearch-ruby/issues/209). Should also be possible via `client.perform_request`.

### Node.js

#### [opensearch-js](https://github.com/opensearch-project/opensearch-js)

{% highlight typescript %}
{% endhighlight %}

Feature request, [opensearch-js#631](https://github.com/opensearch-project/opensearch-js/issues/631). Should also be possible via `transport.request`.

### Python

#### [opensearch-py](https://github.com/opensearch-project/opensearch-py)

The Python client exposes `client.transport.perform_request`.

{% highlight python %}
info = client.transport.perform_request('GET', '/')
print(f"Welcome to {info['version']['distribution']} {info['version']['number']}!")
{% endhighlight %}

{% highlight python %}
document = {
  'title': 'Moneyball',
  'director': 'Bennett Miller',
  'year': '2011'
}

client.transport.perform_request("PUT", "/movies/_doc/1?refresh=true", body = document)
{% endhighlight %}

{% highlight python %}
query = {
  'size': 5,
  'query': {
    'multi_match': {
      'query': 'miller',
      'fields': ['title^2', 'director']
    }
  }
}

client.transport.perform_request("POST", "/movies/_search", body = query)
{% endhighlight %}

{% highlight python %}
client.transport.perform_request("DELETE", "/movies")
{% endhighlight %}

[Documentation](https://github.com/dblock/opensearch-py/blob/doc-making-raw-json-requests/guides/json.md) and [working demo](https://github.com/dblock/opensearch-py/tree/doc-making-raw-json-requests/samples/json) in opensearch-py.

### DotNet

#### [opensearch-net](https://github.com/opensearch-project/opensearch-net)

{% highlight csharp %}
{% endhighlight %}

Feature request, [opensearch-net#403](https://github.com/opensearch-project/opensearch-net/issues/403).

### Rust

#### [opensearch-rs](https://docs.rs/opensearch/latest/opensearch/)

{% highlight rust %}
{% endhighlight %}

Feature request, [opensearch-rs#193](https://github.com/opensearch-project/opensearch-rs/issues/193).

### PHP

#### [opensearch-php](https://github.com/opensearch-project/opensearch-php)

{% highlight php %}
{% endhighlight %}

Feature request, [opensearch-php#166](https://github.com/opensearch-project/opensearch-php/issues/166).

### Go

#### [opensearch-go](https://github.com/opensearch-project/opensearch-go)

{% highlight go %}
{% endhighlight %}

Feature request, [opensearch-go#395](https://github.com/opensearch-project/opensearch-go/issues/395).