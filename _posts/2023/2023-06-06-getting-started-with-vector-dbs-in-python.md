---
layout: post
title: Getting started with Vector DBs in Python
date: 2023-06-16
tags: [knn, vectordb]
comments: true
redirect_from: /2023/05/16/getting-started-with-vector-dbs-in-python.html
---
Vector databases are all the rage today. 

I've built a few iterations of vector search, beginning in 2011 at Artsy, powered by the [Art Genome Project](https://en.wikipedia.org/wiki/The_Art_Genome_Project). The first attempt was a brute-force k-nn with data stored in MongoDB, written in Ruby, which was improved used [LSH](https://en.wikipedia.org/wiki/Locality-sensitive_hashing), then [NN-Descent](https://www.cs.princeton.edu/cass/papers/www11.pdf). Around 2017 we migrated to Elasticsearch that had some specialized k-nn support. 

Things have evolved rapidly with generative AI, so let's try to index and search some vectors in 2023, in Python, and without using any specialized client libraries. Working code for this blog post is [here](https://github.com/dblock/vectordb-hello-world).

### Pinecone

The [Pinecone vector database](https://www.pinecone.io/) is easy to build high-performance vector search applications, developer-friendly, fully managed, and easily scalable without infrastructure hassles.

Conceptually it has indexes (which are really databases, and were probably originally called as such as the API has `/databases` in it). After signing up to Pinecone you get a regional endpoint and a project ID. These form a controller URI (e.g. `https://controller.us-west4-gcp-free.pinecone.io/`) for database operations. After you create an index, that gets its own URI that combines the index name (e.g. "my-index") and a project ID (e.g. `https://my-index-c7556fa.svc.us-west4-gcp-free.pinecone.io`).

{% highlight python %}
{% raw %}
from urllib.parse import urljoin, urlparse

# endpoint
endpoint = urlparse("https://us-west4-gcp-free.pinecone.io")
project_id = ...

# controller endpoint
endpoint._replace(netloc=f"controller.{endpoint.netloc}").geturl() 

# service endpoint
endpoint._replace(netloc=f'my-index-{project_id}.svc.{endpoint.netloc}').geturl() 
{% endraw %}
{% endhighlight %}

Authentication is done with an API key.

{% highlight python %}
from httpx import Client

api_key = ...

client = Client()

headers = {
    "Accept": "application/json; charset=utf-8",
    "Content-Type": "application/json; charset=utf-8",
    "Api-Key": api_key,
}
{% endhighlight %}

We can get a list of existing indexes. This is just a list of names, useful to check whether an index exists.

{% highlight python %}
indices = client.get(urljoin(controller_endpoint, "/databases"), headers=headers).json()
{% endhighlight %}

If an index doesn't exist, we can create one. It will need to have a fixed number of dimensions for our vectors.

{% highlight python %}
client.post(
    urljoin(controller_endpoint, "/databases"),
    headers=headers,
    json={"name": index_name, "dimension": 3},
)
{% endhighlight %}

Index data.

{% highlight python %}
vectors = [
    {
        "id": "vec1",
        "values": [0.1, 0.2, 0.3],
        "metadata": {"genre": "drama"},
    },
    {
        "id": "vec2",
        "values": [0.2, 0.3, 0.4],
        "metadata": {"genre": "action"},
    },
]

client.post(
    urljoin(service_endpoint, "/vectors/upsert"),
    headers=headers,
    json={"vectors": vectors, "namespace": "namespace"},
)
{% endhighlight %}

Searching this data is straightforward.

{% highlight python %}
results = client.post(
    urljoin(service_endpoint, "/query"),
    headers=headers,
    json={
        "vector": [0.1, 0.2, 0.3],
        "top_k": 1,
        "namespace": "namespace",
        "includeMetadata": True,
    },
).json()
{% endhighlight %}

You can see and run a [working sample from here](https://github.com/dblock/vectordb-hello-world/blob/main/src/pinecone/hello.py).

{% highlight bash %}
API_KEY=... PROJECT_ID=... ENDPOINT=https://us-west4-gcp-free.pinecone.io poetry run src/pinecone/hello.py

> GET https://controller.us-west4-gcp-free.pinecone.io/databases
< GET https://controller.us-west4-gcp-free.pinecone.io/databases - 200
> POST https://my-index-c7556fa.svc.us-west4-gcp-free.pinecone.io/vectors/upsert
< POST https://my-index-c7556fa.svc.us-west4-gcp-free.pinecone.io/vectors/upsert - 200
> POST https://my-index-c7556fa.svc.us-west4-gcp-free.pinecone.io/query
< POST https://my-index-c7556fa.svc.us-west4-gcp-free.pinecone.io/query - 200
{'results': [], 'matches': [{'id': 'vec1', 'score': 0.999999881, 'values': [], 'metadata': {'genre': 'drama'}}], 'namespace': 'namespace'}
{% endhighlight %}

### OpenSearch

[OpenSearch](https://opensearch.org/) is a scalable, flexible, and extensible open-source software suite for search, analytics, and observability applications licensed under Apache 2.0. You can use a managed service, such as [Amazon OpenSearch](https://aws.amazon.com/opensearch-service/), or download and install it locally. I usually do the latter, mostly because it's trivial, and I can work offline.

{% highlight bash %}
docker pull opensearchproject/opensearch:latest
docker run -d -p 9200:9200 -p 9600:9600 -e "discovery.type=single-node" opensearchproject/opensearch:latest
{% endhighlight %}

Whichever option you choose you get a single endpoint (e.g. "https://localhost:9200"). Locally it uses basic auth and has self-signed SSL certificates, therefore needs `verify=False`.

{% highlight python %}
endpoint = "https://localhost:9200"
username = "admin"
password = "admin"
auth = BasicAuth(username=username, password=password)
client = Client(verify=False, auth=auth)
headers = {
    "Accept": "application/json; charset=utf-8",
    "Content-Type": "application/json; charset=utf-8",
}
{% endhighlight %}

We can get a list of existing indexes. This is a data structure with a ton of useful information, but we'll make a dictionary out of it, and use it to check whether an index exists.

{% highlight python %}
indices = { x["index"]: x for x in client.get(urljoin(endpoint, "/_cat/indices"), headers=headers).json() }
{% endhighlight %}

If an index doesn't exist, we can create one. The syntax enables k-nn vector search, and include so-called property mappings. It will also need to have a fixed number of dimensions for our vectors.

{% highlight python %}
client.put(
    urljoin(endpoint, f"/{index_name}"),
    headers=headers,
    json={
        "settings": {"index.knn": True},
        "mappings": {
            "properties": {
                "vector": {"type": "knn_vector", "dimension": 3},
            }
        },
    },

{% endhighlight %}

Indexing data can be done via the bulk API, which requires newline-delimited JSON. It asks to separate document IDs from document data, so I purposely wrote it in a way that starts with combined vector documents that include IDs, and generates JSON that the bulk API accepts as a transform.

{% highlight python %}
vectors = [
    {
        "id": "vec1",
        "values": [0.1, 0.2, 0.3],
        "metadata": {"genre": "drama"},
    },
    {
        "id": "vec2",
        "values": [0.2, 0.3, 0.4],
        "metadata": {"genre": "action"},
    },
]

data = ""
for vector in vectors:
    data += (
        json.dumps(
            {
                "index": {"_index": index_name, "_id": vector["id"]},
                "vector": vector["values"],
            } | {i: vector[i] for i in vector if i != "id" and i != "values"}
        )
        + "\n"
    )

client.post(urljoin(endpoint, "/_bulk"), headers=headers, data=data)
{% endhighlight %}

Searching an index is straightforward.

{% highlight python %}
query = {"query": {"knn": {"vector": {"vector": [0.1, 0.2, 0.3], "k": 1}}}}

results = client.post(
    urljoin(endpoint, f"/{index_name}/_search"), headers=headers, json=query
).json()
{% endhighlight %}

You can see and run a [working sample from here](https://github.com/dblock/vectordb-hello-world/blob/main/src/open_search/hello.py).

{% highlight bash %}
USERNAME=admin PASSWORD=admin ENDPOINT=https://localhost:9200 poetry run src/open_search/hello.py

> GET https://localhost:9200/_cat/indices
< GET https://localhost:9200/_cat/indices - 200
> PUT https://localhost:9200/my-index
< PUT https://localhost:9200/my-index - 200
> POST https://localhost:9200/_bulk
< POST https://localhost:9200/_bulk - 200
> POST https://localhost:9200/my-index/_search
< POST https://localhost:9200/my-index/_search - 200
{'total': {'value': 1, 'relation': 'eq'}, 'max_score': 0.97087383, 'hits': [{'_index': 'my-index', '_id': 'vec1', '_score': 0.97087383, '_source': {'index': {'_index': 'my-index', '_id': 'vec2'}, 'vector': [0.2, 0.3, 0.4], 'metadata': {'genre': 'action'}}}]}
{% endhighlight %}

### Vespa

[Vespa](https://vespa.ai/) is a fully featured search engine and vector database. It supports vector search (ANN), lexical search, and search in structured data, all in the same query. Vespa is Apache 2.0 licensed, and can be run in a variety of ways, including Docker and as a managed [cloud service](https://cloud.vespa.ai/).

Let's use their Docker container for this example.

{% highlight bash %}
docker info | grep "Total Memory" # make sure it's at least 4Gb
docker run --detach --name vespa --hostname vespa-container \
  --publish 8080:8080 --publish 19071:19071 \
  vespaengine/vespa
{% endhighlight %}

This container listsens on port `8080` for search and and ingestion APIs and on `19071` for configuration APIs.

Vespa encapsulates the concept of a schema/index in an application that needs to be defined and deployed, so it is not as straightforward as the previous example.

To create a new application with a sample vector schema we need to create a `settings.xml` file with the overall application properties and a `schema.md` file with the definition of our schema. For this example, let's create the following directory structure

```
vector-app/
├── schemas/
│   └── vector.sd
└── services.xml
```

`services.xml`:
{% highlight xml %}
<?xml version="1.0" encoding="utf-8" ?>
<services version="1.0" xmlns:deploy="vespa" xmlns:preprocess="properties">
    <container id="default" version="1.0">
        <document-api/>
        <search/>
        <nodes>
            <node hostalias="node1" />
        </nodes>
    </container>
    <content id="vector" version="1.0">
        <redundancy>2</redundancy>
        <documents>
            <document type="vector" mode="index" />
        </documents>
        <nodes>
            <node hostalias="node1" distribution-key="0" />
        </nodes>
    </content>
</services>
{% endhighlight %}

`vector.sd`:
{% highlight xml %}
schema vector {
    document vector {
        field id type string {
            indexing: summary | attribute
        }
        field values type tensor<float>(x[3]) {
            indexing: summary | attribute
            attribute {
                distance-metric: angular
            }
        }
        struct metadatatype {
            field genre type string {}
        }
        field metadata type metadatatype {
            indexing: summary
        }
    }
    rank-profile vector_similarity {
        inputs {
            query(vector_query_embedding) tensor<float>(x[3])
        }
        first-phase {
            expression: closeness(field, values)
        }
    }

{% endhighlight %}

We can then deploy using the configuration API:

{% highlight bash %}
(cd vector-app && zip -r - .) | \
  curl --header Content-Type:application/zip --data-binary @- \
  localhost:19071/application/v2/tenant/default/prepareandactivate

curl --header Content-Type:application/zip -XPOST localhost:19071/application/v2/tenant/default/session
{% endhighlight %}

In our Python code, we can then set up the HTTP client:

{% highlight python %}
endpoint = "http://localhost:8080"
client = Client(verify=False)
headers = {
    "Accept": "application/json; charset=utf-8",
    "Content-Type": "application/json; charset=utf-8",
}
{% endhighlight %}

And ingest some sample documents:

{% highlight python %}
vectors = [
    {
        "id": "vec1",
        "values": [0.1, 0.2, 0.3],
        "metadata": {"genre": "drama"},
    },
    {
        "id": "vec2",
        "values": [0.2, 0.3, 0.4],
        "metadata": {"genre": "comedy"},
    },
]

for vector in vectors:
    data = json.dumps({"fields": vector})
    client.post(urljoin(endpoint, "/document/v1/vector/vector/docid/" + vector["id"]), headers=headers, data=data)
{% endhighlight %}

Finally, to search we can run the following query:

{% highlight python %}
query = "yql=select * from sources * where {targetHits: 1}nearestNeighbor(values,vector_query_embedding)" \
    "&ranking.profile=vector_similarity" \
    "&hits=1" \
    "&input.query(vector_query_embedding)=[0.1,0.2,0.3]"

results = client.get(
    urljoin(endpoint, "/search/"), headers=headers, params=query
).json()
print(results["root"]["children"][0]["fields"])
{% endhighlight %}

You can see and run a [working sample from here](https://github.com/dblock/vectordb-hello-world/blob/main/src/vespa/hello.py).

{% highlight bash %}
ENDPOINT=http://localhost:8080 poetry run src/vespa/hello.py

> POST http://localhost:8080/document/v1/vector/vector/docid/vec1
< POST http://localhost:8080/document/v1/vector/vector/docid/vec1 - 200
> POST http://localhost:8080/document/v1/vector/vector/docid/vec2
< POST http://localhost:8080/document/v1/vector/vector/docid/vec2 - 200
> GET http://localhost:8080/search/?yql=select%20%2A%20from%20sources%20%2A%20where%20%7BtargetHits%3A%201%7DnearestNeighbor%28values%2Cvector_query_embedding%29&ranking.profile=vector_similarity&hits=1&input.query%28vector_query_embedding%29=%5B0.1%2C0.2%2C0.3%5D
< GET http://localhost:8080/search/?yql=select%20%2A%20from%20sources%20%2A%20where%20%7BtargetHits%3A%201%7DnearestNeighbor%28values%2Cvector_query_embedding%29&ranking.profile=vector_similarity&hits=1&input.query%28vector_query_embedding%29=%5B0.1%2C0.2%2C0.3%5D - 200
{'sddocname': 'vector', 'documentid': 'id:vector:vector::vec1', 'id': 'vec1', 'values': {'type': 'tensor<float>(x[3])', 'values': [0.10000000149011612, 0.20000000298023224, 0.30000001192092896]}, 'metadata': {'genre': 'drama'}}
> DELETE http://localhost:8080/document/v1/vector/vector/docid/vec1
< DELETE http://localhost:8080/document/v1/vector/vector/docid/vec1 - 200
> DELETE http://localhost:8080/document/v1/vector/vector/docid/vec2
< DELETE http://localhost:8080/document/v1/vector/vector/docid/vec2 - 200
{% endhighlight %}


### Others

This blog post and [its code](https://github.com/dblock/vectordb-hello-world/) could use your help for more examples for [Milvus](https://github.com/milvus-io/milvus), [Vector.ai](https://github.com/vector-ai/vectorai), [Qdrant](https://qdrant.tech/), [Weaviate](https://github.com/weaviate/weaviate), [NucliaDB](https://github.com/nuclia/nucliadb), [Vald](https://vald.vdaas.org/), [Postgres pgvector](https://github.com/pgvector/pgvector), etc.

I also wonder whether we need a generic client that's agnostic to which vector DB is being used to help make code portable? I [took a stab at a very simple prototype](https://github.com/dblock/vectordb-client).
