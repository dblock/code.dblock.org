---
layout: post
title: Making AWS SigV4 Authenticated Requests to Amazon OpenSearch
date: 2022-07-11
tags: [opensearch, aws]
comments: true
---
[Amazon OpenSearch](https://aws.amazon.com/opensearch-service/) uses AWS SigV4 for authentication. We're trying to make it dead easy to make authenticated requests across all OpenSearch clients in [opensearch-clients#22](https://github.com/opensearch-project/opensearch-clients/issues/22). Please help contribute end-to-end cookbook examples to this post below for various clients.

### [curl](https://curl.se/)

{% highlight bash %}
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...

curl \
  --verbose \
  --request GET "https://...us-west-2.es.amazonaws.com" \
  --aws-sigv4 "aws:amz:us-west-2:es" \
  --user "$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY" \
  -H "x-amz-security-token:$AWS_SESSION_TOKEN"
{% endhighlight %}

### [awscurl](https://github.com/okigan/awscurl)

{% highlight bash %}
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...

awscurl \
  "https://search...us-west-2.es.amazonaws.com" \
  --region us-west-2 \
  --service es
{% endhighlight %}

### [aws-es-curl](https://github.com/joona/aws-es-curl)

{% highlight bash %}
aws-es-curl \
  "https://search...us-west-2.es.amazonaws.com" \
  --region us-west-2
{% endhighlight %}

### Java

#### [opensearch-java](https://github.com/opensearch-project/opensearch-java)

Use `AwsSdk2Transport` introduced in opensearch-java 2.1.0. This is the latest recommended approach.

{% highlight java %}
import java.io.IOException;

import org.opensearch.client.opensearch.OpenSearchClient;
import org.opensearch.client.opensearch.core.InfoResponse;
import org.opensearch.client.transport.aws.AwsSdk2Transport;
import org.opensearch.client.transport.aws.AwsSdk2TransportOptions;

import software.amazon.awssdk.http.SdkHttpClient;
import software.amazon.awssdk.http.apache.ApacheHttpClient;
import software.amazon.awssdk.regions.Region;

public static void main(final String[] args) throws IOException {
    SdkHttpClient httpClient = ApacheHttpClient.builder().build();
    try {

        OpenSearchClient client = new OpenSearchClient(
            new AwsSdk2Transport(
                httpClient,
                "search-...us-west-2.es.amazonaws.com",
                Region.US_WEST_2,
                AwsSdk2TransportOptions.builder().build()
            )
        );

        InfoResponse info = client.info();
        System.out.println(info.version().distribution() + ": " + info.version().number());
    } finally {
      httpClient.close();
    }
}
{% endhighlight %}

You can see a working demo in [opensearch-java-client-demo](https://github.com/dblock/opensearch-java-client-demo).

See [opensearch-java#55](https://github.com/opensearch-project/opensearch-java/issues/55) and [opensearch-java#177](https://github.com/opensearch-project/opensearch-java/pull/177) for implementation details.

#### [aws-request-signing-apache-interceptor](https://github.com/acm19/aws-request-signing-apache-interceptor)

Use an interceptor and any Apache REST client, including `RestHighLevelClient`.

{% highlight java %}
import java.io.IOException;

import org.apache.http.HttpRequestInterceptor;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;

import io.github.acm19.aws.interceptor.http.AwsRequestSigningApacheInterceptor;
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.auth.signer.Aws4Signer;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.utils.IoUtils;

public static void main(String[] args) throws 
    ClientProtocolException, IOException {
    
    HttpRequestInterceptor interceptor = new AwsRequestSigningApacheInterceptor(
        "es",
        Aws4Signer.create(), 
        DefaultCredentialsProvider.create(), 
        Region.US_WEST_2
    );

    CloseableHttpClient client = HttpClients.custom()
        .addInterceptorLast(interceptor)
        .build();

    HttpGet httpGet = new HttpGet("https://...");
    CloseableHttpResponse httpResponse = httpClient.execute(httpGet);
    System.out.println(httpResponse.getStatusLine());
    System.out.println(IoUtils.toUtf8String(response.getEntity().getContent()));
}
{% endhighlight %}

You can see a working demo in the [interceptor code](https://github.com/acm19/aws-request-signing-apache-interceptor). For an example that uses OpenSearch `RestHighLevelClient` see [1.x](https://github.com/dblock/opensearch-java-client-demo/tree/opensearch-1.x) or [2.x](https://github.com/dblock/opensearch-java-client-demo/tree/opensearch-2.x) depending on your version.

### Ruby

#### [opensearch-ruby](https://github.com/opensearch-project/opensearch-ruby)

Use [opensearch-aws-sigv4](https://rubygems.org/gems/opensearch-aws-sigv4) 1.0 or newer.

{% highlight ruby %}
require 'opensearch-aws-sigv4'
require 'aws-sigv4'

signer = Aws::Sigv4::Signer.new(
  service: 'es',
  region: 'us-west-2',
  access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
  session_token: ENV['AWS_SESSION_TOKEN']
)

client = OpenSearch::Aws::Sigv4Client.new({
  host: 'https://...'
}, signer)

info = client.info
puts info['version']['distribution'] + ': ' + info['version']['number']
{% endhighlight %}

You can see a working demo in [opensearch-ruby-client-demo](https://github.com/dblock/opensearch-ruby-client-demo).

See [opensearch-ruby#71](https://github.com/opensearch-project/opensearch-ruby/issues/71) for implementation details.

### PHP

See [opensearch-php#59](https://github.com/opensearch-project/opensearch-php/issues/59).

### Node.js

Use [@opensearch-project/opensearch](https://www.npmjs.com/package/@opensearch-project/opensearch) 2.x.

{% highlight typescript %}
const { defaultProvider } = require("@aws-sdk/credential-provider-node"); // V3 SDK.
const { Client } = require('@opensearch-project/opensearch');
const { AwsSigv4Signer } = require('@opensearch-project/opensearch/aws');

async function main() {
    const client = new Client({
      ...AwsSigv4Signer({
        region: process.env.OPENSEARCH_REGION || 'us-east-1',
        getCredentials: () => {
        const credentialsProvider = defaultProvider();
        return credentialsProvider();
        },
      }),
      node: process.env.OPENSEARCH_ENDPOINT
    });

    var info = await client.info();
    var version = info.body.version
    console.log(version.distribution + ": " + version.number);
}

main();
{% endhighlight %}

You can see a working demo in [opensearch-node-client-demo](https://github.com/dblock/opensearch-node-client-demo).

See [opensearch-js#252](https://github.com/opensearch-project/opensearch-js/issues/252) for implementation details.

### Python

#### [opensearch-py](https://github.com/opensearch-project/opensearch-py)

Use [opensearch-py](https://pypi.org/project/opensearch-py/) 1.1.0 or newer.

{% highlight python %}
from os import environ
from time import sleep
from urllib.parse import urlparse

from boto3 import Session
from opensearchpy import AWSV4SignerAuth, OpenSearch, RequestsHttpConnection

url = urlparse(environ['OPENSEARCH_ENDPOINT'])
region = environ.get('OPENSEARCH_REGION', 'us-west-2')

credentials = Session().get_credentials()

auth = AWSV4SignerAuth(credentials, region)

client = OpenSearch(
  hosts=[{
    'host': url.netloc,
    'port': url.port or 443
  }],
  http_auth=auth,
  use_ssl=True,
  verify_certs=True,
  connection_class=RequestsHttpConnection
)

info = client.info()
print(f"{info['version']['distribution']}: {info['version']['number']}")
{% endhighlight %}

You can see a working demo in [opensearch-python-client-demo](https://github.com/dblock/opensearch-python-client-demo).

See [opensearch-py#85](https://github.com/opensearch-project/opensearch-py/issues/85) for implementation details.

### Go

See [opensearch-go#117](https://github.com/opensearch-project/opensearch-go/issues/117).

### Rust

See [opensearch-rs#36](https://github.com/opensearch-project/opensearch-rs/issues/36).

