---
layout: post
title: Getting started with Vector DBs in Python
date: 2023-06-16
tags: [knn, vectordb]
comments: true
redirect_from: /2023/05/16/getting-started-with-vector-dbs-in-python.html
---
Vector databases are all the rage today.

I've built a few iterations of vector search, beginning in 2011 at Artsy, powered by the [Art Genome Project](https://en.wikipedia.org/wiki/The_Art_Genome_Project). Compared to LLM use-cases today, Artsy is a small, 1200-dimensional sparse vector and semantic search engine. The first attempt at vector search resulted in a brute-force exact k-nearest-neighbor search with data stored in MongoDB, written in Ruby. The second attempt was an approximate nearest-neighbor implementation using [LSH](https://en.wikipedia.org/wiki/Locality-sensitive_hashing), and finally [NN-Descent](https://www.cs.princeton.edu/cass/papers/www11.pdf). Around 2017 we migrated to Elasticsearch, and I am speculating the team has moved to OpenSearch by now because it's open-source.

Things have evolved rapidly with generative AI, so let's try to index and search some vectors in 2023 in Python, using the simplest of the libraries, usually pure HTTP when available. You can draw your own conclusions of which engines are better and/or easier to use. Working code for this blog post is [here](https://github.com/dblock/vectordb-hello-world).

In alphabetical order.

- [OpenSearch](#opensearch)
- [pgVector](#pgvector)
- [Pinecone](#pinecone)
- [Qdrant](#qdrant)
- [Redis](#redis)
- [Vespa](#vespa)
- [Weaviate](#weaviate)
- [Others](#others)

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
indices = { x["index"]: x for x in
    client.get(
        urljoin(endpoint, "/_cat/indices"), 
        headers=headers
    ).json()
}
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
                "values": {
                    "type": "knn_vector",
                    "dimension": 3
                }
            }
        }
    }
)
{% endhighlight %}

Indexing data can be done document-by-document or via the bulk API, which requires newline-delimited JSON. We start with some data.

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
{% endhighlight %}

You can insert document-by-document.

{% highlight python %}
for vector in vectors:
    client.post(
        urljoin(endpoint, f"/{index_name}/_doc/{vector['id']}"),
                headers=headers,
                json=vector
    )
{% endhighlight %}

Or bulk insert, which asks to separate document IDs from document data, so I purposely wrote it in a way that starts with combined vector documents that include IDs, and generates JSON that the bulk API accepts as a transform.

{% highlight python %}
data = ""
for vector in vectors:
    data += json.dumps({ "index": {"_index": index_name, "_id": vector["id"]} }) + "\n"
    data += json.dumps({i: vector[i] for i in vector if i != "id"}) + "\n"

client.post(urljoin(endpoint, "/_bulk"), headers=headers, data=data)
{% endhighlight %}

Search for data.

{% highlight python %}
query = {
    "query": {
        "knn": {
            "values": {
                "vector": [0.1, 0.2, 0.3],
                "k": 1
            }
        }
    }
}

results = client.post(
    urljoin(endpoint, f"/{index_name}/_search"),
        headers=headers,
        json=query
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
{'total': {'value': 1, 'relation': 'eq'}, 'max_score': 0.97087383, 'hits': [{'_index': 'my-index', '_id': 'vec1', '_score': 0.97087383, '_source': {'index': {'_index': 'my-index', '_id': 'vec2'}, 'values': [0.2, 0.3, 0.4], 'metadata': {'genre': 'action'}}}]}
{% endhighlight %}

### pgVector

[pgVector](https://github.com/pgvector/pgvector) adds vector similarity search to open-source Postgres. You can use a local docker installation from [ankane/pgvector](https://hub.docker.com/r/ankane/pgvector), or a [managed service](https://github.com/pgvector/pgvector#hosted-postgres).

{% highlight bash %}
docker pull ankane/pgvector or https://github.com/pgvector/pgvector/issues/54 for cloud providers
docker run -e POSTGRES_PASSWORD=password -p 5433:5432 ankane/pgvector
{% endhighlight %}

PostgreSQL speaks its own message-based protocol, and queries are made in SQL, which is not HTTP, hence we're going to use [asyncpg](https://github.com/MagicStack/asyncpg).

{% highlight python %}
database = "vectors"
conn = await asyncpg.connect(database="template1")
onn.execute(f"CREATE DATABASE \"{database}\"")
{% endhighlight %}

Enable vector extensions on the index.

{% highlight python %}
await conn.execute(f"CREATE EXTENSION vector")
await pgvector.asyncpg.register_vector(conn)
{% endhighlight %}

Create a schema with a custom primary key, a 3-dimensional vector, and some JSON metadata.

{% highlight python %}
await conn.execute(
    f"CREATE TABLE vectors (id text PRIMARY KEY, values vector(3), metadata JSONB)"
)
{% endhighlight %}

Insert vectors.

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

for vector in vectors:
    q = f"INSERT INTO vectors (id, values, metadata) VALUES($1, $2, $3)"
    await conn.execute(q,
        vector['id'],
        vector['values'],
        json.dumps(vector['metadata'])
    )
{% endhighlight %}

Search. In the example below we filter by `genre`.

{% highlight python %}
q = "SELECT * FROM vectors WHERE metadata->>'genre'='action' ORDER BY values <-> '[0.2,0.1,0.5]'"
results = await conn.fetch(q)
for result in results:
    print(f"{result} ({json.loads(result['metadata'])['genre']})")
{% endhighlight %}

Finally, drop this database.

{% highlight python %}
await conn.execute(f"DROP DATABASE \"{database}\"")
{% endhighlight %}

You can see and run a [working sample from here](https://github.com/dblock/vectordb-hello-world/blob/main/src/pgvector/hello.py).

{% highlight bash %}
cd src/pgvector
poetry install
PGPORT=5433 PGUSER=postgres PGPASSWORD=password poetry run ./hello.py

<Record id='vec2' values=array([0.2, 0.3, 0.4], dtype=float32) metadata='{"genre": "action"}'> (action)
{% endhighlight %}

### Pinecone

The [Pinecone vector database](https://www.pinecone.io/) is easy to build high-performance vector search applications with, developer-friendly, fully managed, and scalable without infrastructure hassles.

Conceptually it has indexes (which are really databases, and were probably originally called as such as the API has `/databases` in it). After signing up to Pinecone you get a regional endpoint and a project ID. These form a controller URI (e.g. `https://controller.us-west4-gcp-free.pinecone.io/`) for database operations. After you create an index, that gets its own URI that combines the index name (e.g. "my-index") and a project ID (e.g. `https://my-index-c7556fa.svc.us-west4-gcp-free.pinecone.io`). It's not quite serverless, as you do have to reason about [pods](https://docs.pinecone.io/docs/indexes).

{% highlight python %}
from urllib.parse import urljoin, urlparse

endpoint = urlparse("https://us-west4-gcp-free.pinecone.io")
project_id = os.environ["PROJECT_ID"]

controller_endpoint = endpoint._replace(netloc=f"controller.{endpoint.netloc}").geturl()

service_endpoint = endpoint._replace(netloc=f'my-index-{project_id}.svc.{endpoint.netloc}').geturl()
{% endhighlight %}

Authentication is performed using a required API key.

{% highlight python %}
from httpx import Client

api_key = os.environ["API_KEY"]

client = Client()

headers = {
    "Accept": "application/json; charset=utf-8",
    "Content-Type": "application/json; charset=utf-8",
    "Api-Key": api_key,
}
{% endhighlight %}

We can get a list of existing indexes. This is just a list of names, useful to check whether an index exists.

{% highlight python %}
indices = client.get(
    urljoin(controller_endpoint, "/databases"),
        headers=headers
).json()
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

Search for this vector data.

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

### Qdrant

[Qdrant](https://qdrant.tech/) is a similarity vector search engine designed for a wide range of applications, including recommendation systems, image search, and natural language processing. It is scalable and allows dynamic updates to the index. It is particularly suitable for scenarios where the vector data is constantly evolving and vectors may be modified without interrupting the search functionality. Qdrant is licensed under Apache 2.0.

Qdrant is built upon a concept of indexes, where vectors are organized and stored in "collections" for quick retrieval. Currently, it only supports HNSW (Hierarchical Navigable Small World) as vector index.

After you sign up at Qdrant Cloud Services, create a new free tier Qdrant Cluster with authentication. Note your cluster URL and API key. The endpoint will have the following format `https://my-cluster.cloud.qdrant.io:6333/`.

{% highlight python %}
client = Client()

endpoint = os.environ["ENDPOINT"]
api_key = os.environ["API_KEY"]

headers = {
    "Accept": "application/json; charset=utf-8",
    "Content-Type": "application/json; charset=utf-8",
    "api-key": api_key
}
{% endhighlight %}

We can create an index in collections.

{% highlight python %}
index_name = "my-index"

index = {
    "vectors": {
        "size": 3,
        "distance": "Cosine"
    }
}

vectors = [
    {
        "id": 1,
        "vector": [0.1, 0.2, 0.3],
        "payload": {
            "genre": "drama"
        }
    },
    {
        "id": 2,
        "vector": [0.2, 0.3, 0.4],
        "payload": {
            "genre": "action"
        }
    }
]

payload = {"points": vectors}

client.get(urljoin(endpoint, "collections"), headers=headers),

client.put(
    urljoin(endpoint, f"/collections/{index_name}"),
        json=index,
        headers=headers
)
{% endhighlight %}

Upload some vectors.

{% highlight python %}
client.put(
    urljoin(endpoint, f"/collections/{index_name}/points?wait=true"),
    data=dumps(payload), headers=headers)
{% endhighlight %}

Search.

{% highlight python %}
query = '{"vector": [0.1,0.2,0.3], "limit": 1}'
response = client.post(
    urljoin(endpoint, f"/collections/{index_name}/points/search"),
    data=query, headers=headers)
print(response.json())
{% endhighlight %}

It is easy to delete all vectors in an index.

{% highlight python %}
client.delete(
    urljoin(endpoint, f"/collections/{index_name}"),
        headers=headers
)
{% endhighlight %}

You can see and run a [working sample from here](https://github.com/dblock/vectordb-hello-world/blob/main/src/qdrant/hello.py).

{% highlight bash %}
API_KEY=... ENDPOINT=https://my-cluster.cloud.qdrant.io:6333 poetry run src/qdrant/hello.py

> GET https://my-cluster.cloud.qdrant.io:6333/collections
< GET https://my-cluster.cloud.qdrant.io:6333/collections - 200
> PUT https://my-cluster.cloud.qdrant.io:6333/collections/my-index
< PUT https://my-cluster.cloud.qdrant.io:6333/collections/my-index - 200
> PUT https://my-cluster.cloud.qdrant.io:6333/collections/my-index/points?wait=true
< PUT https://my-cluster.cloud.qdrant.io:6333/collections/my-index/points?wait=true - 200
> POST https://my-cluster.cloud.qdrant.io:6333/collections/my-index/points/search
< POST https://my-cluster.cloud.qdrant.io:6333/collections/my-index/points/search - 200
{'result': [{'id': 1, 'version': 0, 'score': 0.9999998, 'payload': None, 'vector': None}], 'status': 'ok', 'time': 0.000117235}
> DELETE https://my-cluster.cloud.qdrant.io:6333/collections/my-index
< DELETE https://my-cluster.cloud.qdrant.io:6333/collections/my-index - 200
{% endhighlight %}

### Redis

[Redis](https://redis.io/) is a fast, opinionated, open-source database. Its [similarity vector search](https://redis.io/docs/interact/search-and-query/search/vectors/) comes with `FLAT` and `HNSW` indexing methods (field types). Redis is licensed under BSD.

I prefer to run Redis locally in Docker with `docker run -p 6379:6379 redislabs/redisearch:latest`, but managed service options with free tiers also [exist](https://redis.com/).

Redis speaks [RESP](https://redis.io/docs/reference/protocol-spec/), which is not HTTP, hence we're going to use [redis-py](https://github.com/redis/redis-py).

{% highlight python %}
r = Redis(host='localhost', port=6379, decode_responses=True)
{% endhighlight %}

We create an `HNSW` index called `vectors` of documents with a given `doc:` prefix. This is unlike other databases where you write docs into an index.

{% highlight python %}
index_name = "vectors"
doc_prefix = "doc:"

schema = (
    TagField("genre"),
    VectorField("values",
        "HNSW", {
            "TYPE": "FLOAT32",
            "DIM": 3,
            "DISTANCE_METRIC": "COSINE"
        }
    )
)

definition = IndexDefinition(
    prefix=[doc_prefix],
    index_type=IndexType.HASH
)

r.ft(index_name).create_index(fields=schema, definition=definition)
{% endhighlight %}

Insert some vectors. Note that redis doesn't support a deep dictionary for metadata, so we will index and filter by `genre` in search.

{% highlight python %}
pipe = r.ft(index_name).pipeline()

vectors = [
    {
        "id": 1,
        "values": [0.1, 0.2, 0.3],
        "metadata": {"genre": "drama"},
    },
    {
        "id": 2,
        "values": [0.2, 0.3, 0.4],
        "metadata": {"genre": "action"},
    },
]

for vector in vectors:
    key = f"{doc_prefix}{vector['id']}"
    value = {
        "genre": vector["metadata"]["genre"],
        "values": np.array(vector["values"]).astype(np.float32).tobytes()
    }
    pipe.hset(key, mapping=value)

pipe.execute()
{% endhighlight %}

Search. We filter by `genre` with `@genre:{ action })`. Use `**` instead if you don't want filtering.

{% highlight python %}
query = (
    Query("(@genre:{ action })=>[KNN 2 @values $vector as score]")
    .sort_by("score")
    .return_fields("id", "score", "genre")
    .dialect(2)
)

query_params = {
    "vector": np.array([0.1, 0.2, 0.3]).astype(np.float32).tobytes()
}

results = r.ft(index_name).search(query, query_params).docs
for result in results:
    print(result)
{% endhighlight %}

Finally, delete the index with its vectors.

{% highlight python %}
r.ft(index_name).dropindex(True)
{% endhighlight %}

You can see and run a [working sample from here](https://github.com/dblock/vectordb-hello-world/blob/main/src/redis/hello.py).

{% highlight bash %}
cd src/redis
poetry install
poetry run ./hello.py

Document {'id': 'doc:2', 'payload': None, 'score': '0.00741678476334', 'genre': 'action'}
{% endhighlight %}

### Vespa

[Vespa](https://vespa.ai/) is a fully featured search engine and vector database. It supports approximate nearest neighbor search, lexical search, and search in structured data, all in the same query. Vespa is Apache 2.0 licensed, and can be run in a variety of ways, including Docker and as a managed [cloud service](https://cloud.vespa.ai/).

Let's use their Docker container for this example. Make sure you [configure Docker with at least 4GB RAM](https://docs.docker.com/desktop/settings/mac/#resources) (check with `docker info | grep "Total Memory"`).

{% highlight bash %}
docker pull vespaengine/vespa
docker run --detach --name vespa --hostname vespa-container \
  --publish 8080:8080 --publish 19071:19071 \
  vespaengine/vespa
{% endhighlight %}

This container listens on port `8080` for search and ingestion APIs, and on `19071` for configuration APIs.

Vespa encapsulates the concept of a schema/index in an application that needs to be defined and deployed, so it is not as straightforward as the previous example.

To create a new application with a sample vector schema we need to create a `settings.xml` file with the overall application properties, and a `schema.md` file with the definition of our schema. For this example, let's create the following directory structure.

{% highlight shell %}
vector-app/
├── schemas/
│   └── vector.sd
└── services.xml
{% endhighlight %}

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

Deploy using the configuration API.

{% highlight bash %}
(cd vector-app && zip -r - .) | \
  curl --header Content-Type:application/zip --data-binary @- \
  localhost:19071/application/v2/tenant/default/prepareandactivate

curl \
    --header Content-Type:application/zip \
    -XPOST localhost:19071/application/v2/tenant/default/session
{% endhighlight %}

In Python code, setup the client.

{% highlight python %}
endpoint = "https://localhost:8080"
client = Client(verify=False)
headers = {
    "Accept": "application/json; charset=utf-8",
    "Content-Type": "application/json; charset=utf-8",
}
{% endhighlight %}

Ingest some sample documents.

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
    client.post(
        urljoin(endpoint, "/document/v1/vector/vector/docid/" + vector["id"]),
        headers=headers,
        data=data
    )
{% endhighlight %}

Finally, to search we can run the following query.

{% highlight python %}
query = "yql=select * from sources * where {targetHits: 1} nearestNeighbor(values,vector_query_embedding)" \
    "&ranking.profile=vector_similarity" \
    "&hits=1" \
    "&input.query(vector_query_embedding)=[0.1,0.2,0.3]"

results = client.get(
    urljoin(endpoint, "/search/"),
        headers=headers,
        params=query
).json()

print(results["root"]["children"][0]["fields"])
{% endhighlight %}

You can see and run a [working sample from here](https://github.com/dblock/vectordb-hello-world/blob/main/src/vespa/hello.py).

{% highlight bash %}
ENDPOINT=https://localhost:8080 CONFIG_ENDPOINT=https://localhost:19071 poetry run src/vespa/hello.py

> POST https://localhost:8080/document/v1/vector/vector/docid/vec1
< POST https://localhost:8080/document/v1/vector/vector/docid/vec1 - 200
> POST https://localhost:8080/document/v1/vector/vector/docid/vec2
< POST https://localhost:8080/document/v1/vector/vector/docid/vec2 - 200
> GET https://localhost:8080/search/?yql=select%20%2A%20from%20sources%20%2A%20where%20%7BtargetHits%3A%201%7DnearestNeighbor%28values%2Cvector_query_embedding%29&ranking.profile=vector_similarity&hits=1&input.query%28vector_query_embedding%29=%5B0.1%2C0.2%2C0.3%5D
< GET https://localhost:8080/search/?yql=select%20%2A%20from%20sources%20%2A%20where%20%7BtargetHits%3A%201%7DnearestNeighbor%28values%2Cvector_query_embedding%29&ranking.profile=vector_similarity&hits=1&input.query%28vector_query_embedding%29=%5B0.1%2C0.2%2C0.3%5D - 200
{'sddocname': 'vector', 'documentid': 'id:vector:vector::vec1', 'id': 'vec1', 'values': {'type': 'tensor<float>(x[3])', 'values': [0.10000000149011612, 0.20000000298023224, 0.30000001192092896]}, 'metadata': {'genre': 'drama'}}
> DELETE https://localhost:19071/application/v2/tenant/default/application/default
< DELETE https://localhost:19071/application/v2/tenant/default/application/default - 200
{% endhighlight %}

### Weaviate

[Weaviate](https://weaviate.io) is a vector search engine specifically designed for natural language numerical data. It uses contextualized embeddings in data objects to understand semantic similarity. Currently, it supports only Hierarchical Navigable Small World (HNSW) indexing, and is more costly on building data to indexes. However, it has a fast query time and high scalability. Weaviate is open-source, easy to use, flexible, extensible, and has a Contributor License Agreement.

After you sign up at Weaviate Cloud Services WCS, create a new free tier Weaviate Cluster with authentication. Note your cluster URL and API key (optional). The endpoint will have the following format https://myindex.weaviate.network.

{% highlight python %}
client = Client()

endpoint = os.environ["ENDPOINT"]
api_key = os.getenv("API_KEY") # optional

headers = {
    "Accept": "application/json; charset=utf-8",
    "Content-Type": "application/json; charset=utf-8"
}

if not api_key is None:
    headers["Authorization"] = f"Bearer {api_key}"
{% endhighlight %}

It is easy to create some objects with vectors.

{% highlight python %}
vectors = [
    {
        "id": "vec1",
        "values": [0.1, 0.2, 0.3],
        "properties": {
            "genre": "drama"
        }
    },
    {
        "id": "vec2",
        "values": [0.2, 0.3, 0.4],
        "properties": {
            "genre": "action"
        }
    }
]

objects = []
for vector in vectors:
    obj = {
        "class": "Vectors",
        "properties": {
            "vector": vector["values"]
        }
    }
    objects.append(obj)

client.post(
    urljoin(endpoint, "/v1/batch/objects"),
        json={"objects": objects},
        headers=headers
)
{% endhighlight %}

The search is pretty straightforward. Weaviate also has a GraphQL interface.

{% highlight python %}
query = {
    "fields": "vector",
    "nearVector": {
        "vector": [0.1],
        "certainty": 0.9
    }
}

response = client.get(
    urljoin(endpoint, "/v1/objects"),
        params=query,
        headers=headers
).json()

for obj in response["objects"]:
    print(obj)
{% endhighlight %}

Deleting objects of the same class is straightforward.

{% highlight python %}
client.delete(
    urljoin(endpoint, f"/v1/schema/Vectors"),
        headers=headers
)
{% endhighlight %}

You can see and run a [working sample from here](https://github.com/dblock/vectordb-hello-world/blob/main/src/weaviate/hello.py).

{% highlight bash %}
API_KEY=... ENDPOINT=https://my-cluster.weaviate.network poetry run src/weaviate/hello.py

> POST https://myindex.weaviate.network/v1/batch/objects
< POST https://myindex.weaviate.network/v1/batch/objects - 200
> GET https://myindex.weaviate.network/v1/objects?fields=vector&nearVector=%7B%27vector%27%3A%20%5B0.1%5D%2C%20%27certainty%27%3A%200.9%7D
< GET https://myindex.weaviate.network/v1/objects?fields=vector&nearVector=%7B%27vector%27%3A%20%5B0.1%5D%2C%20%27certainty%27%3A%200.9%7D - 200
{'class': 'Vectors', 'creationTimeUnix': 1688914857307, 'id': '46e40d05-d550-4415-aa2c-7c004fcdd037', 'lastUpdateTimeUnix': 1688914857307, 'properties': {'vector': [0.1, 0.2, 0.3]}, 'vectorWeights': None}
{'class': 'Vectors', 'creationTimeUnix': 1688914857307, 'id': 'c14bd5b1-8b81-44a4-8051-3b9b8c52cde4', 'lastUpdateTimeUnix': 1688914857307, 'properties': {'vector': [0.2, 0.3, 0.4]}, 'vectorWeights': None}
> DELETE https://myindex.weaviate.network/v1/schema/Vectors
< DELETE https://myindex.weaviate.network/v1/schema/Vectors - 200
{% endhighlight %}



### Others

This blog post and [its code](https://github.com/dblock/vectordb-hello-world/) could use your help for more examples for [Milvus](https://github.com/milvus-io/milvus), [Vector.ai](https://github.com/vector-ai/vectorai),  [NucliaDB](https://github.com/nuclia/nucliadb), [Vald](https://vald.vdaas.org/), etc.

I also wonder whether we need a generic client that's agnostic to which vector DB is being used to help make code portable? I [took a stab at a very simple prototype](https://github.com/dblock/vectordb-client).
