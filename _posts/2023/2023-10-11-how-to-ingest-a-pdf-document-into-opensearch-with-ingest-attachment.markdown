---
layout: post
title: "How to ingest a PDF document into OpenSearch with the ingest-attachment plugin"
date: 2023-09-29
tags: [opensearch]
comments: true
---
This is a neat feature available in OpenSearch via an optional `ingest-attachment` plugin. It's installed on AWS domains by default.

Download OpenSearch, install the `ingest-attachment` plugin, and start it.

```bash
wget https://artifacts.opensearch.org/releases/bundle/opensearch/2.10.0/opensearch-2.10.0-linux-x64.tar.gz
tar vfxz opensearch-2.10.0-linux-x64.tar.gz
cd opensearch-2.10.0/
./bin/opensearch-plugin install ingest-attachment
./opensearch-tar-install.sh
```

I'm using OpenSearch 2.10.

```bash
curl -u admin:admin -k https://localhost:9200 | jq
```

```json
{
  "name": "ip-172-31-42-1",
  "cluster_name": "opensearch",
  "cluster_uuid": "gm4le40_R1eKzSDukDFWkA",
  "version": {
    "distribution": "opensearch",
    "number": "2.10.0",
    "build_type": "tar",
    "build_hash": "eee49cb340edc6c4d489bcd9324dda571fc8dc03",
    "build_date": "2023-09-20T23:54:29.889267151Z",
    "build_snapshot": false,
    "lucene_version": "9.7.0",
    "minimum_wire_compatibility_version": "7.10.0",
    "minimum_index_compatibility_version": "7.0.0"
  },
  "tagline": "The OpenSearch Project: https://opensearch.org/"
}
```

Create an ingest pipeline.

```bash
$ curl -k -u admin:admin -X PUT -H "Content-type:application/json" --data '{"description":"Extract","processors":[{"attachment":{"field":"data","indexed_chars":-1}}]}' https://localhost:9200/_ingest/pipeline/attachment | jq
```

```json
{
    "acknowledged": true
}
```

Download a dummy PDF.

```bash
$ wget https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf
```

Ingest the PDF.

```bash
$ curl -k -u admin:admin -X PUT -H "Content-type:application/json" --data '{"filename":"dummy.pdf","title":"Dummy PDF","data":"'"$(base64 -w 0 dummy.pdf)"'"}' https://localhost:9200/my_index/_doc/1?pipeline=attachment | jq
```

```json
{
    "_index": "my_index",
    "_id": "1",
    "_version": 1,
    "result": "created",
    "_shards": {
        "total": 2,
        "successful": 1,
        "failed": 0
    },
    "_seq_no": 0,
    "_primary_term": 1
}
```

Search.

```bash
$ curl -k -u admin:admin -X POST -H "Content-type:application/json" --data '{"query":{"match":{"attachment.content":{"query":"dummy"}}}}' https://localhost:9200/my_index/_search | jq
```

```json
{
  "took": 2,
  "timed_out": false,
  "_shards": {
    "total": 1,
    "successful": 1,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": {
      "value": 1,
      "relation": "eq"
    },
    "max_score": 0.39556286,
    "hits": [
      {
        "_index": "my_index",
        "_id": "1",
        "_score": 0.39556286,
        "_source": {
          "filename": "dummy.pdf",
          "data": "...",
          "attachment": {
            "date": "2007-02-23T15:56:37Z",
            "content_type": "application/pdf",
            "author": "Evangelos Vlachogiannis",
            "language": "mt",
            "content": "Dummy PDF file\n\n\n\tDummy PDF file",
            "content_length": 35
          },
          "title": "Dummy PDF"
        }
      }
    ]
  }
}
```
