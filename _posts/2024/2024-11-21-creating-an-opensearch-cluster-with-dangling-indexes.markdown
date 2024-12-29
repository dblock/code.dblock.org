---
layout: post
title: Creating an OpenSearch Cluster with Dangling Indexes
date: 2024-11-21 01:00:00
tags: [opensearch]
comments: true
---
I've previously [written](/2024/07/02/using-opensearch-cat-api-response-formats.html) about the [OpenSearch OpenAPI Specification](https://github.com/opensearch-project/opensearch-api-specification) and how [it can be used to fix bugs in the OpenSearch documentation](/2024/07/12/fixing-bugs-in-opensearch-api-documentation-using-api-spec-tests.html).

Most of the tests in the API spec work with a [generic Docker container](https://github.com/opensearch-project/opensearch-api-specification/blob/main/tests/default/docker-compose.yml) and some basic network setup to expose a local 9200 port.

{% highlight yaml %}
version: '3'

services:
  opensearch-cluster:
    image: opensearchproject/opensearch:latest
    ports:
      - 9200:9200
      - 9600:9600
    environment:
      - OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m
      - discovery.type=single-node
{% endhighlight %}

When testing an optional plugin we install it in Dockerfile, such as [in the following analysis test suite](https://github.com/opensearch-project/opensearch-api-specification/tree/main/tests/plugins/analysis).

{% highlight bash %}
ARG OPENSEARCH_DOCKER_HUB_PROJECT
ARG OPENSEARCH_VERSION
ARG OPENSEARCH_DOCKER_REF

FROM opensearchproject/opensearch:latest
RUN ./bin/opensearch-plugin install -b analysis-icu
RUN ./bin/opensearch-plugin install -b analysis-phonenumber
{% endhighlight %}

The [docker-compose.yml](https://github.com/opensearch-project/opensearch-api-specification/blob/main/tests/plugins/analysis/docker-compose.yml) references this Dockerfile in `build`.

{% highlight yaml %}
  opensearch-cluster:
    build:
      context: .
{% endhighlight %}

Testing more advanced APIs in OpenSearch requires a setup that also imports data. For example, OpenSearch has a concept of so-called [dangling indexes](https://opensearch.org/docs/latest/api-reference/index-apis/dangling-index/). After a node joins a cluster, dangling indexes occur if any shards exist in the node's local directory that do not already exist in the cluster. To fabricate a dangling index one must create a cluster that loses quorum. Fortunately, we have available to us [an excellent talk by Amitai Stern](https://www.youtube.com/watch?v=SWjCq0xTN7w) that goes into great depth into data migrations between clusters and talks about a method called "node toss" at around 17:50 that puts node indexes into a dangling state. Amitai has also authored [a cookbook](https://github.com/opensearch-project/opensearch-api-specification/blob/20b3b04dd6a998929e01e6494d4ac897ac36eaff/tests/dangling/.data/README.md) for re-creating a dangling index in a Docker container. 

Here's how it works.

We begin by creating a single-node cluster without security that uses a local directory (`opensearch-data1`) to store data. Note the `--entrypoint /bin/bash` which opens a shell instead of starting the cluster.

{% highlight bash %}
docker run --name opensearch-single-node-cluster\
  -it --entrypoint /bin/bash \
  -p 9200:9200 -p 9600:9600 \
  -e "discovery.type=single-node" \
  --ulimit memlock=-1:-1 \
  --ulimit nofile=65536:65536 \
  -e DISABLE_INSTALL_DEMO_CONFIG=true \
  -e DISABLE_SECURITY_PLUGIN=true \
  -v $(pwd)/opensearch-data1:/usr/share/opensearch/data \
  opensearchproject/opensearch:latest
{% endhighlight %}

We manually start it with `./opensearch-docker-entrypoint.sh`, then insert some data from another shell.

{% highlight bash %}
curl -X POST http://localhost:9200/movies/_doc --json '{"director":"Bennett Miller","title":"The Cruise","year":1998}'
{% endhighlight %}

{% highlight json %}
{
  "_index": "movies",
  "_id": "B0VvT5MBVIiutAAib7dO",
  "_version": 1,
  "result": "created",
  "_shards": {
    "total": 1,
    "successful": 1,
    "failed": 0
  },
  "_seq_no": 2,
  "_primary_term": 2
}
{% endhighlight %}

Remove the index replicas.

{% highlight bash %}
curl -X PUT  http://localhost:9200/movies/_settings --json '{"index.number_of_replicas":0}'
{% endhighlight %}

{% highlight json %}
{"acknowledged":true}
{% endhighlight %}

Detach the cluster from the Docker shell.

{% highlight bash %}
./bin/opensearch-node detach-cluster

Confirm [y/N] y
Node was successfully detached from the cluster
{% endhighlight %}

Exit the container with `exit` and start a new 2-node cluster on top of this data with [this docker-compose.yml](https://github.com/opensearch-project/opensearch-api-specification/blob/20b3b04dd6a998929e01e6494d4ac897ac36eaff/tests/dangling/.data/docker-compose.yml) that mounts our previously detached data.

{% highlight yaml %}
services:
  opensearch-node1:
    ...
    volumes:
      - ./opensearch-data1:/usr/share/opensearch/data
    ports:
      - 9200:9200
      - 9600:9600
  opensearch-node2:
    ...
{% endhighlight %}

After about 30 seconds the cluster figures out what to do, and creates the desired dangling indexes out of the existing data in `node1`.

{% highlight bash %}
curl -X GET http://localhost:9200/_dangling
{% endhighlight %}

{% highlight json %}
{
  "_nodes": {
    "total": 1,
    "successful": 1,
    "failed": 0
  },
  "cluster_name": "docker-cluster",
  "dangling_indices": [
    {
      "index_name": "movies",
      "index_uuid": "p6tliBznQO-FzTdslShrwA",
      "creation_date_millis": 1732195242038,
      "node_ids": [
        "66ikk5pNQn-W9H0UN08OgA"
      ]
    }
  ]
}
{% endhighlight %}

Trying to recover this data will not work because the cluster is in a quorum loss and there's no elected cluster manager.

{% highlight bash %}
curl -X POST http://localhost:9200/_dangling/NAXLxxvEQfKHwRzxA7nxRw?accept_data_loss=true
{% endhighlight %}

{% highlight json %}
{
  "error": {
    "root_cause": [
      {
        "type": "cluster_manager_not_discovered_exception",
        "reason": "no cluster-manager to send allocate dangled request"
      }
    ],
    "type": "cluster_manager_not_discovered_exception",
    "reason": "no cluster-manager to send allocate dangled request"
  },
  "status": 503
}
{% endhighlight %}

Deleting the dangling index will also hang waiting for a cluster manager. 

We can turn our 2-node quorum loss cluster into a healthy single-node cluster with these dangling indexes. Attempting to switch the cluster `discovery.type=single-node` will not work because the node is part of a 2-node cluster that lost quorum. 

{% highlight txt %}
opensearch-node1-1  | [2024-11-21T16:22:38,376][ERROR][o.o.b.OpenSearchUncaughtExceptionHandler] [opensearch-node1] uncaught exception in thread [main]
opensearch-node1-1  | org.opensearch.bootstrap.StartupException: java.lang.IllegalStateException: cannot start with [discovery.type] set to [single-node] when local node {opensearch-node1}{UvfTjEerS76oc3RM5meQug}{8-SaRbGfSP64wLDkSwubNA}{172.19.0.2}{172.19.0.2:9300}{dimr}{shard_indexing_pressure_enabled=true} does not have quorum in voting configuration VotingConfiguration{_must_join_elected_cluster_manager_}
{% endhighlight %}

We need to properly detach one of the nodes. This is done by setting the number of replicas to zero, and removing node2 from voting.

{% highlight bash %}
curl -X PUT  http://localhost:9200/_settings --json '{"index.number_of_replicas":0}'
curl -X POST http://localhost:9200/_cluster/voting_config_exclusions?node_names=opensearch-node2
{% endhighlight %}

A single node cluster can now start on top of this data.

However, while we can mount it directly via docker-compose, we don't want to update the local copy of our data files, and instead copy them into the Docker container every time in order to have a stable initial state. Copying files causes OpenSearch to think that they were tampered with externally.

{% highlight txt %}
opensearch-cluster-1  | [2024-11-21T15:02:27,832][ERROR][o.o.b.OpenSearchUncaughtExceptionHandler] [0e69ab6a4227] uncaught exception in thread [main]
opensearch-cluster-1  | org.opensearch.bootstrap.StartupException: org.apache.lucene.store.AlreadyClosedException: Underlying file changed by an external force at 2024-11-21T15:02:27.801461006Z, (lock=NativeFSLock(path=/usr/share/opensearch/data/nodes/0/_state/write.lock,impl=sun.nio.ch.FileLockImpl[0:9223372036854775807 exclusive valid],creationTime=2024-11-21T15:02:21.011461002Z))
{% endhighlight %}

The solution is to get rid of lock files with `find . -name *.lock | xargs rm`. Now our local data is usable in a single-node cluster and this is what we add to git. Finally, copied files also have to be writable. We add `COPY --chown=1000:1000 .data/opensearch-data1 /usr/share/opensearch/data` to `Dockerfile` and end up with a single-node cluster with dangling indexes that can be deleted or recovered.

{% highlight bash %}
curl -X DELETE http://localhost:9200/_dangling/p6tliBznQO-FzTdslShrwA?accept_data_loss=true
{% endhighlight %}

{% highlight json %}
{"acknowledged":true}
{% endhighlight %}

Note that `DELETE` and `POST _dangling` return `202 Accepted` and not `200` or `201`.

See [opensearch-api-specification#686](https://github.com/opensearch-project/opensearch-api-specification/pull/686) for details.
