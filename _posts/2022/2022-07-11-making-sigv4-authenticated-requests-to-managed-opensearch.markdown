---
layout: post
title: Making AWS SigV4 Authenticated Requests to Amazon OpenSearch
date: 2022-07-11
tags: [opensearch, aws]
comments: true
---
[Amazon OpenSearch](https://aws.amazon.com/opensearch-service/) and [Amazon OpenSearch Serverless](https://aws.amazon.com/opensearch-service/features/serverless/) use AWS SigV4 for authentication. We've made it dead easy to make authenticated requests across all OpenSearch clients in [opensearch-clients#22](https://github.com/opensearch-project/opensearch-clients/issues/22).

### Command Line

#### [curl](https://curl.se/)

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

If you want to `PUT` a document with `curl` you need some data, and the `x-amz-content-sha256` header for Amazon OpenSearch Serverless. See [this gist](https://gist.github.com/dblock/8dca2faba28a26e229676932763bd6c8#file-opensearch-curl-knn-sh) for a full example that inserts some vectors and perform an approximate nearest neighbor search.

#### [awscurl](https://github.com/okigan/awscurl)

{% highlight bash %}
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...

awscurl \
  "https://search...us-west-2.es.amazonaws.com" \
  --region us-west-2 \
  --service es
{% endhighlight %}

See [this gist](https://gist.github.com/dblock/8dca2faba28a26e229676932763bd6c8#file-opensearch-awscurl-sh) for a full example that inserts some vectors and perform an approximate nearest neighbor search.

#### [aws-es-curl](https://github.com/joona/aws-es-curl)

{% highlight bash %}
aws-es-curl \
  "https://search...us-west-2.es.amazonaws.com" \
  --region us-west-2
{% endhighlight %}

### Java

#### [opensearch-java](https://github.com/opensearch-project/opensearch-java)

Use `AwsSdk2Transport` introduced in opensearch-java 2.1.0. This is the latest recommended approach.

{% highlight java %}
SdkHttpClient httpClient = ApacheHttpClient.builder().build();

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

httpClient.close();
{% endhighlight %}

Working demo in Java in [opensearch-java-client-demo](https://github.com/dblock/opensearch-java-client-demo), and another one written in Kotlin in [opensearch-kotlin-client-demo](https://github.com/dblock/opensearch-kotlin-client-demo).

#### [aws-request-signing-apache-interceptor](https://github.com/acm19/aws-request-signing-apache-interceptor)

Use an interceptor and any Apache REST client, including `RestHighLevelClient`.

{% highlight java %}
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
{% endhighlight %}

You can see a working demo in the [interceptor code](https://github.com/acm19/aws-request-signing-apache-interceptor). For an example that uses OpenSearch `RestHighLevelClient` see [1.x](https://github.com/dblock/opensearch-java-client-demo/tree/opensearch-1.x) or [2.x](https://github.com/dblock/opensearch-java-client-demo/tree/opensearch-2.x) depending on your version.

### Ruby

#### [opensearch-ruby](https://github.com/opensearch-project/opensearch-ruby)

Use [opensearch-aws-sigv4](https://rubygems.org/gems/opensearch-aws-sigv4) 1.0 or newer.

{% highlight ruby %}
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

Working demo in [opensearch-ruby-client-demo](https://github.com/dblock/opensearch-ruby-client-demo).

### Node.js

#### [opensearch-js](https://github.com/opensearch-project/opensearch-js)

Use [@opensearch-project/opensearch](https://www.npmjs.com/package/@opensearch-project/opensearch) 2.x.

{% highlight typescript %}
const client = new Client({
  ...AwsSigv4Signer({
    region: process.env.AWS_REGION || 'us-east-1',
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
{% endhighlight %}

Working demo in [opensearch-node-client-demo](https://github.com/dblock/opensearch-node-client-demo).

### Python

#### [opensearch-py](https://github.com/opensearch-project/opensearch-py)

{% highlight python %}
url = urlparse(environ['OPENSEARCH_ENDPOINT'])
region = environ.get('AWS_REGION', 'us-east-1')

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

Working demo in [opensearch-python-client-demo](https://github.com/dblock/opensearch-python-client-demo).

### DotNet

#### [opensearch-net](https://github.com/opensearch-project/opensearch-net)

Use [OpenSearch.Client](https://www.nuget.org/packages/OpenSearch.Client) 1.2.0 or newer.

{% highlight csharp %}
var endpoint = new Uri(Environment.GetEnvironmentVariable("OPENSEARCH_ENDPOINT") ?? throw new ArgumentNullException("Missing OPENSEARCH_ENDPOINT."));
var region = Amazon.RegionEndpoint.GetBySystemName(Environment.GetEnvironmentVariable("AWS_REGION") ?? "us-east-1");
var connection = new AwsSigV4HttpConnection(region);
var config = new ConnectionSettings(endpoint, connection);
var client = new OpenSearchClient(config);

Console.WriteLine($"{client.RootNodeInfo().Version.Distribution}: {client.RootNodeInfo().Version.Number}");
{% endhighlight %}

Working demo in [opensearch-dotnet-client-demo](https://github.com/dblock/opensearch-dotnet-client-demo).

### Rust

#### [opensearch-rs](https://docs.rs/opensearch/latest/opensearch/)

{% highlight rust %}
let url = Url::parse(&env::var("OPENSEARCH_ENDPOINT").expect("Missing OPENSEARCH_ENDPOINT"));
let conn_pool = SingleNodeConnectionPool::new(url?);
let aws_config = aws_config::load_from_env().await.clone();
let transport = TransportBuilder::new(conn_pool).auth(aws_config.clone().try_into()?).build()?;
let client = OpenSearch::new(transport);

let info: Value = client.info().send().await?.json().await?;
println!("{}: {}", info["version"]["distribution"].as_str().unwrap(), info["version"]["number"].as_str().unwrap());
{% endhighlight %}

Working demo in [opensearch-rust-client-demo](https://github.com/dblock/opensearch-rust-client-demo).

### PHP

#### [opensearch-php](https://github.com/opensearch-project/opensearch-php)

{% highlight php %}
$client = (new \OpenSearch\ClientBuilder())
  ->setHosts([getenv("OPENSEARCH_ENDPOINT")])
  ->setSigV4Region(getenv("AWS_REGION"))    
  ->setSigV4CredentialProvider(true)
  ->build();

$info = $client->info();

echo "{$info['version']['distribution']}: {$info['version']['number']}\n";
{% endhighlight %}

Working demo in [opensearch-php-client-demo](https://github.com/dblock/opensearch-php-client-demo).

### Go

#### [opensearch-go](https://github.com/opensearch-project/opensearch-go)

{% highlight go %}
ctx := context.Background()
cfg, _ := config.LoadDefaultConfig(ctx)
signer, _ := requestsigner.NewSigner(cfg)

endpoint, _ := os.LookupEnv("OPENSEARCH_ENDPOINT")

client, _ := opensearch.NewClient(opensearch.Config{
  Addresses: []string{endpoint},
  Signer:    signer,
})

if info, err := client.Info(); err != nil {
  log.Fatal("info", err)
} else {
  var r map[string]interface{}
  json.NewDecoder(info.Body).Decode(&r)
  version := r["version"].(map[string]interface{})
  fmt.Printf("%s: %s\n", version["distribution"], version["number"])
}
{% endhighlight %}

Working demo in [opensearch-go-client-demo](https://github.com/dblock/opensearch-go-client-demo).
