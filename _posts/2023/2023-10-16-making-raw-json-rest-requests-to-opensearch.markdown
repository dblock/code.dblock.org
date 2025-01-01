---
layout: post
title: Making Raw JSON REST Requests to OpenSearch
date: 2023-10-16
tags: [opensearch]
comments: true
---
OpenSearch clients implement various high-level REST DSLs to invoke OpenSearch APIs. Efforts such as [opensearch-clients#19](https://github.com/opensearch-project/opensearch-clients/issues/19) aim at generating these from spec in order to always be up-to-date with the default distribution, including plugins. However this is a game that cannot be won. Clients will always lag behind, and users often find themselves in a situation that requires them to invoke an API that is not supported by the client. Thus, in [opensearch-clients#62](https://github.com/opensearch-project/opensearch-clients/issues/62) I proposed we level up all OpenSearch language clients in their capability to make raw JSON REST requests. I am happy to report that six months later we have support for sending raw JSON to OpenSearch in all language clients!

In this post I'll keep current state with links to working samples, similar to [Making AWS SigV4 Authenticated Requests to Amazon OpenSearch](/2022/07/11/making-sigv4-authenticated-requests-to-managed-opensearch.html). For many of these I am running a local copy of OpenSearch 2.9 in docker.

```bash
docker run \
  -p 9200:9200 \
  -p 9600:9600 \
  -e "discovery.type=single-node" \
  opensearchproject/opensearch:latest
```

### Command Line

We'll be looking for the equivalent of the four `GET`, `POST`, `PUT` and `DELETE` operations.

#### [curl](https://curl.se/)

```bash
curl -k -u admin:admin https://localhost:9200
```

```json
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
```

```bash
curl -k -u admin:admin \
  -X POST \
  -H "Content-type:application/json" \
  --data '{"director":"Bennett Miller","title":"Moneyball","year":2011}' \
  https://localhost:9200/movies/_doc/1 | jq
```

```json
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
```

```bash
curl -k -u admin:admin \
  -X GET \
  https://localhost:9200/movies/_doc/1 | jq
```

```json
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
```

```bash
curl -k -u admin:admin \
  -X PUT \
  -H "Content-type:application/json" \
  --data '{"director":"Bennett Miller","title":"Moneyball","year":2011}' \
  https://localhost:9200/movies/_doc/1 | jq
```

```json
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
```

```bash
curl -k -u admin:admin \
  -X DELETE \
  https://localhost:9200/movies/_doc/1 | jq
```

```json
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
```

### Java

#### [opensearch-java](https://github.com/opensearch-project/opensearch-java)

The Java client added `.generic()` that returns a `OpenSearchGenericClient` in [2.10.0](https://github.com/opensearch-project/opensearch-java/pull/910) and fixed the implementation for AWS transport options in [2.10.3](https://github.com/opensearch-project/opensearch-java/pull/978).

```java
OpenSearchClient client = new OpenSearchClient(...)

OpenSearchGenericClient genericClient = client
  .generic()
  .withClientOptions(ClientOptions.throwOnHttpErrors());
```

The client can be used to `execute` a simple `GET` request/response.

```java
Response response = genericClient.execute(
  Requests.builder()
    .endpoint("/")
    .method("GET")
    .build());

System.out.println(response.getBody().get().bodyAsString());
```

Sending JSON data is similar.

```java
Requests.builder()
  .endpoint(index + "/_doc/1")
  .method("POST")
  .json("{\"director\":\"Bennett Miller\",\"title\":\"Moneyball\",\"year\":2011}")
  .build();
```

You can parse responses as generic JSON as well. Here's a search example.

```java
Response searchResponse = genericClient.execute(
  Requests.builder().endpoint(index + "/_search").method("POST")
    .json("{"
    + " \"query\": {"
    + "  \"match\": {"
    + "    \"title\": {"
    + "      \"query\": \"Moneyball 2\""
    + "    }"
    + "  }"
    + " }"
    + "}")
    .build());

  JsonNode json = searchResponse.getBody()
    .map(b -> Bodies.json(b, JsonNode.class, client._transport().jsonpMapper()))
    .orElse(null);

  JsonNode hits = json.get("hits").get("hits");
  for (int i = 0; i < hits.size(); i++) {
    System.out.println(hits.get(i).get("_source").toString());
  }
```

See the [updated documentation](https://github.com/opensearch-project/opensearch-java/blob/main/guides/generic.md) and [working demo](https://github.com/dblock/opensearch-java-client-demo) for more information.

### Ruby

#### [opensearch-ruby](https://github.com/opensearch-project/opensearch-ruby)

The Ruby client added `.http` in 3.1.0.

A simple `GET`.

```ruby
client = OpenSearch::Client.new(...)

info = client.http.get('/')
puts info
```

Create a document.

```ruby
document = { title: 'Moneyball', director: 'Bennett Miller', year: 2011 }
client.http.post("/movies/_doc/1", body: document)
```

Search for a document.

```ruby
results = client.http.post(
  "/movies/_search", 
  body: { query: { match: { director: 'miller' } } }
)

results['hits']['hits'].each do |hit|
  puts hit
end
```

Raw JSON also works with `bulk` by automatically transforming arrays into nd-json.

```ruby
body = [
  { index: { _index: 'books', _id: 1 } },
  { title: 'The Lion King', year: 1994 },
  { index: { _index: 'books', _id: 2 } },
  { title: 'Beauty and the Beast', year: 1991 }
]

client.http.post('_bulk', body: body)
```

See the [updated documentation](https://github.com/opensearch-project/opensearch-ruby/blob/main/guides/json.md) and [working demo](https://github.com/dblock/opensearch-ruby-client-demo) for more information.

### Node.js

#### [opensearch-js](https://github.com/opensearch-project/opensearch-js)

The Node.js client has long supported `client.transport.perform_request` and wrapped it up in the `http` namespace in [2.5.0](https://github.com/opensearch-project/opensearch-js/pull/649).

```typescript
info = client.http.get("/")
print(f"Welcome to {info["version"]["distribution"]} {info["version"]["number"]}!")
```

Use `body` to send JSON data.

```typescript
q = "miller"

query = {
  "size": 5,
  "query": {
    "multi_match": {
      "query": q,
      "fields": ["title^2", "director"]
    }
  }
}

client.http.post("/movies/_search", body = query)
```

See the [updated documentation](https://github.com/opensearch-project/opensearch-py/blob/main/guides/json.md) and [working demo](https://github.com/opensearch-project/opensearch-py/tree/main/samples/json) for more information.

### Python

#### [opensearch-py](https://github.com/opensearch-project/opensearch-py)

The Python client has long exposed `client.transport.perform_request` and wrapped it up in an `http` namespace in [2.4.0](https://github.com/opensearch-project/opensearch-py/pull/544).

```python
info = client.http.get('/')
print(f"Welcome to {info['version']['distribution']} {info['version']['number']}!")
```

Create a document.

```python
document = {
  'title': 'Moneyball',
  'director': 'Bennett Miller',
  'year': '2011'
}

client.http.put("/movies/_doc/1?refresh=true", body = document)
```

Search for a document.

```python
query = {
  'size': 5,
  'query': {
    'multi_match': {
      'query': 'miller',
      'fields': ['title^2', 'director']
    }
  }
}

client.http.post("/movies/_search", body = query)
```

Delete an index.

```python
client.http.delete("/movies")
```

See the [updated documentation](https://github.com/opensearch-project/opensearch-py/blob/main/guides/json.md) and [working demo](https://github.com/opensearch-project/opensearch-py/tree/main/samples/json) for more information.

### DotNet

#### [opensearch-net](https://github.com/opensearch-project/opensearch-net)

The .NET client added a high level DSL in [1.6.0](https://github.com/opensearch-project/opensearch-net/pull/447).

```csharp
var info = await client.Http.GetAsync<DynamicResponse>("/");
Console.WriteLine($"Welcome to {info.Body.version.distribution} {info.Body.version.number}!");
```

Search for a document.

```csharp
const string q = "miller";

var query = new
{
  size = 5,
  query = new { 
    multi_match = new { 
      query = q, 
      fields = new[] { 
        "title^2", "director" 
      } 
    } 
  }
};

var search = await client.Http.PostAsync<DynamicResponse>(
  "/movies/_search", 
  d => d.SerializableBody(query)
);

foreach (var hit in search.Body.hits.hits) {
  Console.WriteLine($"Search Hit: {hit["_source"]["title"]}");
}
```

See the [updated documentation](https://github.com/opensearch-project/opensearch-net/blob/main/guides/json.md) and [working demo](https://github.com/opensearch-project/opensearch-net/tree/main/samples/Samples/RawJson) for more information.

### Rust

#### [opensearch-rs](https://docs.rs/opensearch/latest/opensearch/)

The rust client directly supports `JsonBody<_>` on request, and `.json()` on response.

```rust
let info: Value = client
    .send::<(), ()>(Method::Get, "/", HeaderMap::new(), None, None, None)
    .await?
    .json()
    .await?;
    
println!(
    "{}: {}",
    info["version"]["distribution"].as_str().unwrap(),
    info["version"]["number"].as_str().unwrap()
);
```

```rust
let document: JsonBody<_> = json!({
    "title": "Moneyball",
    "director": "Bennett Miller",
    "year": "2011"
}).into();

client.send(
    Method::Put,
    "movies/_doc/1",
    HeaderMap::new(),
    Some(&[("refresh", "true")]),
    Some(document),
    None,
).await?;
```

```rust
let query: JsonBody<_> = json!({
  "size": 5,
  "query": {
      "multi_match": {
          "query": "miller",
          "fields": ["title^2", "director"]
      }
  }
}).into();

let search_response = client.send(
    Method::Post,
    &"/movies/_search",
    HeaderMap::new(),
    Option::<&()>::None,
    Some(query),
    None,
)
.await?;

let search_result = search_response.json::<Value>().await?;

println!("Hits: {:#?}", search_result["hits"]["hits"].as_array().unwrap());
```

```rust
client.send::<(), ()>(
  Method::Delete,
  "/movies",
  HeaderMap::new(),
  None,
  None,
  None,
)
.await?;

```

See the [updated user guide](https://github.com/opensearch-project/opensearch-rs/blob/main/USER_GUIDE.md#make-raw-json-requests), [a working demo](https://github.com/opensearch-project/opensearch-rs/blob/main/opensearch/examples/json.rs) and a [API vs. raw JSON diff](https://github.com/dblock/opensearch-rust-client-demo/compare/raw-json?expand=1) for more information.

### PHP

#### [opensearch-php](https://github.com/opensearch-project/opensearch-php)

The PHP client has added a `request()` wrapper in [2.3.0](https://github.com/opensearch-project/opensearch-php/pull/177).

```php
$info = $client->request('GET', '/');

echo "{$info['version']['distribution']}: {$info['version']['number']}\n";

$indexName = "movies";

$client->request('POST', "/$indexName/_doc/1", [
    'body' => [
        'title' => 'Moneyball',
        'director' => 'Bennett Miller',
        'year' => 2011
    ]
]);

$result = $client->request('POST', "/$indexName/_search", [
    'body' => [
        'query' => [
            'multi_match' => [
                'query' => 'miller',
                'fields' => ['title^2', 'director']
            ]
        ]
    ]
]);

print_r($result['hits']['hits'][0], false);

$client->request('DELETE', "/$indexName/_doc/1");

$client->request('DELETE', "/$indexName");
```

See the [updated documentation](https://github.com/opensearch-project/opensearch-php/blob/main/guides/raw-request.md) and a [working demo](https://github.com/dblock/opensearch-php-client-demo) for more information. A higher level DSL is a feature request, [opensearch-php#192](https://github.com/opensearch-project/opensearch-php/issues/192).

### Go

#### [opensearch-go](https://github.com/opensearch-project/opensearch-go)

The go client has long supported `Client.NewRequest` and `Perform`.

```go
infoRequest, _ := http.NewRequest("GET", "/", nil)
infoResponse, _ := client.Client.Perform(infoRequest)
resBody, _ := io.ReadAll(infoResponse.Body)
fmt.Printf("client info: %s\n", resBody)
```

Sending data is similar.

```go
query := strings.NewReader(`{
  "size": 5,
  "query": {
    "multi_match": {
      "query": "miller",
        "fields": ["title^2", "director"]
      }
    }
   }`)

searchRequest, _ := http.NewRequest("POST", "/movies/_search", query)
searchRequest.Header["Content-Type"] = []string{"application/json"}
searchResp, _ := client.Client.Perform(searchRequest)
searchRespBody, _ := io.ReadAll(searchResp.Body)
fmt.Println("search: ", string(searchRespBody))
```

See the [updated documentation](https://github.com/opensearch-project/opensearch-go/blob/main/guides/json.md) for more information, and please contribute a working demo to the project or [opensearch-go-client-demo](https://github.com/dblock/opensearch-go-client-demo) as I am too lazy to write [all the error handlers](https://code.dblock.org/2022/12/27/programming-languages.html).
