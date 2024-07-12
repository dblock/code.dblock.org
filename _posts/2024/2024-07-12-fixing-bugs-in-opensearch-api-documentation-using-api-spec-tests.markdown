---
layout: post
title: "Fixing Bugs in the OpenSearch API Documentation using API Spec Tests"
date: 2024-07-12
tags: [opensearch]
comments: true
---
I've previously [written](/2024/07/02/using-opensearch-cat-api-response-formats.html) about the [OpenSearch OpenAPI Specification](https://github.com/opensearch-project/opensearch-api-specification). 

One of the neat features of the API spec repo is [a set of declarative YAML integration tests](https://github.com/opensearch-project/opensearch-api-specification/tree/main/tests). This turned out to be really useful in fixing bugs in the [OpenSearch API reference documentation](https://github.com/opensearch-project/documentation-website) that is [published to opensearch.org](https://opensearch.org/docs/latest/api-reference).

Here's how I went about it.

To author tests, I started with reading the API documentation. For example, I [read the docs](https://opensearch.org/docs/latest/api-reference/index-apis/refresh/) for `/_refresh`, and added tests for that API in [opensearch-api-specification#374](https://github.com/opensearch-project/opensearch-api-specification/pull/374).

The basic example that refreshes all indices was easy.

{% highlight yaml %}
$schema: ../../json_schemas/test_story.schema.yaml

description: Test _refresh.

chapters:
  - synopsis: Refresh.
    path: /_refresh
    method: POST
    response:
      status: 200
{% endhighlight %}

{% highlight bash %}
$ npm run test:spec--insecure -- --tests tests/indices/refresh.yaml 

> opensearch_api_tools@1.0.0 test:spec--insecure
> ts-node tools/src/tester/test.ts --opensearch-insecure --tests tests/indices/refresh.yaml

OpenSearch 2.15.0

PASSED  refresh.yaml (.../tests/indices/refresh.yaml)
{% endhighlight %}

Then, I tried using the query parameters.

{% highlight yaml %}
- synopsis: Refresh an index.
    path: /{index}/_refresh
    method: POST
    parameters:
      index: movies
      ignore_unavailable: true
      allow_no_indices: false
      expand_wildcard: all
    response:
      status: 200
{% endhighlight %}

This failed.

{% highlight bash %}
$ npm run test:spec--insecure -- --tests tests/indices/refresh.yaml 

> opensearch_api_tools@1.0.0 test:spec--insecure
> ts-node tools/src/tester/test.ts --opensearch-insecure --tests tests/indices/refresh.yaml

OpenSearch 2.15.0

ERROR   refresh.yaml (.../tests/indices/refresh.yaml)
    ERROR   CHAPTERS
        PASSED  Refresh.
            PASSED  REQUEST BODY
            PASSED  RESPONSE STATUS
            PASSED  RESPONSE PAYLOAD BODY
            PASSED  RESPONSE PAYLOAD SCHEMA
        ERROR   Refresh an index.
            FAILED  PARAMETERS
                PASSED  ignore_unavailable
                PASSED  allow_no_indices
                FAILED  expand_wildcard (Schema for "expand_wildcard" parameter not found.)
            PASSED  REQUEST BODY
            ERROR   RESPONSE STATUS (Expected status 200, ...)
            SKIPPED RESPONSE PAYLOAD BODY
            SKIPPED RESPONSE PAYLOAD SCHEMA
{% endhighlight %}

The failure is with the `expand_wildcard` parameter, which is misspelled and should be `expand_wildcards`.

The corrected test passes.

{% highlight bash %}
$ npm run test:spec--insecure -- --tests tests/indices/refresh.yaml --verbose

> opensearch_api_tools@1.0.0 test:spec--insecure
> ts-node tools/src/tester/test.ts --opensearch-insecure --tests tests/indices/refresh.yaml

OpenSearch 2.15.0

PASSED  refresh.yaml (.../tests/indices/refresh.yaml)
    PASSED  CHAPTERS
        PASSED  Refresh.
            PASSED  REQUEST BODY
            PASSED  RESPONSE STATUS
            PASSED  RESPONSE PAYLOAD BODY
            PASSED  RESPONSE PAYLOAD SCHEMA
        PASSED  Refresh an index.
            PASSED  PARAMETERS
                PASSED  ignore_unavailable
                PASSED  allow_no_indices
                PASSED  expand_wildcards
            PASSED  REQUEST BODY
            PASSED  RESPONSE STATUS
            PASSED  RESPONSE PAYLOAD BODY
            PASSED  RESPONSE PAYLOAD SCHEMA
{% endhighlight %}

All we have left is to fix the documentation in [documentation-website#7620](https://github.com/opensearch-project/documentation-website/pull/7620). I also fixed a bug in `PUT mapping` in [documentation-website#7652](https://github.com/opensearch-project/documentation-website/pull/7652) and corrected the type of `include_defaults` in `GET /_settings` in [documentation-website#7657](https://github.com/opensearch-project/documentation-website/pull/7657).

Finally, we'd like to generate a lot of the documentation from spec in [documentation-website#7700](https://github.com/opensearch-project/documentation-website/issues/7700).
