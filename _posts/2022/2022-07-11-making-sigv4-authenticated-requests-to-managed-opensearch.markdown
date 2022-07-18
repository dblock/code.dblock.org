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

#### [aws-request-signing-apache-interceptor](https://github.com/acm19/aws-request-signing-apache-interceptor)

Use an interceptor and any Apache REST client.

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

You can see a demo by checking out the interceptor demo and running the following.

{% highlight bash %}
mvn \
  test-compile \
  exec:java \
  -Dexec.classpathScope=test \
  -Dexec.mainClass="io.github.acm19.aws.interceptor.test.AmazonOpenSearchServiceSample" \
  -Dexec.args="--endpoint=https://search-...us-west-2.es.amazonaws.com --region=us-west-2"
{% endhighlight %}

#### [opensearch-java](https://github.com/opensearch-project/opensearch-java)

See [opensearch-java#55](https://github.com/opensearch-project/opensearch-java/issues/55) and [opensearch-java#177](https://github.com/opensearch-project/opensearch-java/pull/177) for ongoing work to make SigV4 a first class citizen in opensearch-java.

### Ruby

See [opensearch-ruby#71](https://github.com/opensearch-project/opensearch-ruby/issues/71).

### PHP

See [opensearch-php#59](https://github.com/opensearch-project/opensearch-php/issues/59).

### JavaScript

See [opensearch-js#252](https://github.com/opensearch-project/opensearch-js/issues/252).

### Python

See [opensearch-py#85](https://github.com/opensearch-project/opensearch-py/issues/85).

### Go

See [opensearch-go#117](https://github.com/opensearch-project/opensearch-go/issues/117).

### Rust

See [opensearch-rs#36](https://github.com/opensearch-project/opensearch-rs/issues/36).

