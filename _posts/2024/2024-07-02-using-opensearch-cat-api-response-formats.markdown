---
layout: post
title: "Using OpenSearch Cat API Response Formats"
date: 2024-07-02
tags: [opensearch]
comments: true
---
I've been working on the new [OpenSearch OpenAPI Specification](https://github.com/opensearch-project/opensearch-api-specification) that aims to properly document OpenSearch RESTful APIs. The spec is to be used to [auto-generate OpenSearch clients](https://github.com/opensearch-project/opensearch-clients/issues/19) in Python, Java, .NET, etc. One of the neat features of the API specification repo is [a set of declarative YAML integration tests](https://github.com/opensearch-project/opensearch-api-specification/tree/main/tests) that ensure that the spec has the correct request parameters, and that it matches the actual responses from the server. This is particularly useful when documenting a large existing API such as OpenSearch with its 1021 known APIs.

Thus, I recently added support for [`text/plain`](https://github.com/opensearch-project/opensearch-api-specification/pull/360), [`application/yaml`](https://github.com/opensearch-project/opensearch-api-specification/pull/363), [`application/cbor`](https://github.com/opensearch-project/opensearch-api-specification/pull/371), and [`application/smile`](https://github.com/opensearch-project/opensearch-api-specification/pull/386) response types to the test tooling.

I've heard of YAML, but what is SMILE or CBOR?!

OpenSearch `_cat` API stands for "Compact and Aligned Text". 

{% highlight bash %}
$ curl -k -u admin:$OPENSEARCH_PASSWORD https://localhost:9200/_cat
=^.^=
/_cat/allocation
...
{% endhighlight %}

Do you see the `=^.^=` cat? Neat! This was a `content-type: text/plain; charset=UTF-8` response.

Other CAT APIs respond with text the same way.

{% highlight bash %}
$ curl -k -u admin:$OPENSEARCH_PASSWORD https://localhost:9200/_cat/indices

green  open .plugins-ml-model-group      LDXIur-YTqim9fiEHLJZ1w 1 0    0 0  10.3kb  10.3kb
yellow open security-auditlog-2024.05.30 7yBZpI7HS22-6mZtPrVg2g 1 1   62 0  78.8kb  78.8kb
{% endhighlight %}

You can ask for JSON, `application/json`. Pipe it with [jq](https://jqlang.github.io/jq/).

{% highlight bash %}
$ curl -k -u admin:$OPENSEARCH_PASSWORD https://localhost:9200/_cat/indices?format=json | jq
{% endhighlight %}

{% highlight json %}
[
  {
    "health": "green",
    "status": "open",
    "index": ".plugins-ml-model-group",
    "uuid": "LDXIur-YTqim9fiEHLJZ1w",
    "pri": "1",
    "rep": "0",
    "docs.count": "0",
    "docs.deleted": "0",
    "store.size": "10.3kb",
    "pri.store.size": "10.3kb"
  },
  {
    "health": "yellow",
    "status": "open",
    "index": "security-auditlog-2024.05.30",
    "uuid": "7yBZpI7HS22-6mZtPrVg2g",
    "pri": "1",
    "rep": "1",
    "docs.count": "62",
    "docs.deleted": "0",
    "store.size": "78.8kb",
    "pri.store.size": "78.8kb"
  }
]
{% endhighlight %}

You can ask for YAML, `application/yaml`.

{% highlight bash %}
$ curl -k -u admin:$OPENSEARCH_PASSWORD https://localhost:9200/_cat/indices?format=yaml
{% endhighlight %}

{% highlight yaml %}
yaml
---
- health: "green"
  status: "open"
  index: ".plugins-ml-model-group"
  uuid: "LDXIur-YTqim9fiEHLJZ1w"
  pri: "1"
  rep: "0"
  docs.count: "0"
  docs.deleted: "0"
  store.size: "10.3kb"
  pri.store.size: "10.3kb"
- health: "yellow"
  status: "open"
  index: "security-auditlog-2024.05.30"
  uuid: "7yBZpI7HS22-6mZtPrVg2g"
  pri: "1"
  rep: "1"
  docs.count: "62"
  docs.deleted: "0"
  store.size: "78.8kb"
  pri.store.size: "78.8kb"
{% endhighlight %}

Or for [CBOR](https://cbor.io/), which stands for "Concise Binary Object Representation". Pipe it using [cbor2](https://pypi.org/project/cbor2/).

{% highlight bash %}
$ curl -k -u admin:$OPENSEARCH_PASSWORD https://localhost:9200/_cat/indices?format=cbor
{% endhighlight %}

{% highlight json %}
[{"health": "green", "status": "open", "index": ".plugins-ml-model-group", "uuid": "LDXIur-YTqim9fiEHLJZ1w", "pri": "1", "rep": "0", "docs.count": "0", "docs.deleted": "0", "store.size": "10.3kb", "pri.store.size": "10.3kb"}, {"health": "yellow", "status": "open", "index": "security-auditlog-2024.05.30", "uuid": "7yBZpI7HS22-6mZtPrVg2g", "pri": "1", "rep": "1", "docs.count": "62", "docs.deleted": "0", "store.size": "78.8kb", "pri.store.size": "78.8kb"}]
{% endhighlight %}

Finally, [SMILE](https://github.com/FasterXML/smile-format-specification) is another binary data format that defines a binary equivalent of standard JSON data format.

{% highlight bash %}
$ curl -k -u admin:$OPENSEARCH_PASSWORD https://localhost:9200/_cat/indices?format=smile
{% endhighlight %}

{% highlight text %}
:)
???healthDgreen?statusCopen?indexV.plugins
...
{% endhighlight %}

Yes, the data is prefixed with `:)`. Use [smile-tool](https://www.npmjs.com/package/smile-tool) to decode the data.

{% highlight bash %}
$ curl -k -u admin:$OPENSEARCH_PASSWORD https://localhost:9200/_cat/indices?format=smile | smile-tool -d
{% endhighlight %}

{% highlight json %}
[{"health": "green", "status": "open", "index": ".plugins-ml-model-group", "uuid": "LDXIur-YTqim9fiEHLJZ1w", "pri": "1", "rep": "0", "docs.count": "0", "docs.deleted": "0", "store.size": "10.3kb", "pri.store.size": "10.3kb"}, {"health": "yellow", "status": "open", "index": "security-auditlog-2024.05.30", "uuid": "7yBZpI7HS22-6mZtPrVg2g", "pri": "1", "rep": "1", "docs.count": "62", "docs.deleted": "0", "store.size": "78.8kb", "pri.store.size": "78.8kb"}]
{% endhighlight %}

