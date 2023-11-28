---
layout: post
title: "Changing the default admin password in OpenSearch"
date: 2023-08-08
tags: [opensearch]
comments: true
---
OpenSearch ships with a [pretty comprehensive doc](https://opensearch.org/docs/latest/) on getting started, along with a comprehensive reference to its vast [security configuration](https://opensearch.org/docs/latest/security/configuration/index/). This can be a bit overwhelming. Here's how one can change the default "admin" password. In my case I'll do it inside my demo docker instance, but you can skip the Docker parts if you're just downloading and installing OpenSearch directly.

{% highlight bash %}
docker pull opensearchproject/opensearch:latest
docker run -d -p 9200:9200 -p 9600:9600 -e "discovery.type=single-node" opensearchproject/opensearch:latest
{% endhighlight %}

Ensure that the default username and password works.

{% highlight bash %}
{% raw %}
$ curl --insecure -u admin:invalid https://localhost:9200
Unauthorized

curl --insecure -u admin:admin https://localhost:9200

{
  "name" : "b09419b98216",
  "cluster_name" : "docker-cluster",
  "cluster_uuid" : "SYUzvRvqT06ld8IdvE5okQ",
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
{% endraw %}
{% endhighlight %}

### The Easy Way

Users can change passwords using the [security plugin REST API](https://opensearch.org/docs/latest/security/access-control/api/). We can examine the `admin` user.

{% highlight bash %}
curl --insecure -u admin:password -X GET "https://localhost:9200/_plugins/_security/api/account"

{
  "user_name": "admin",
  "is_reserved": true,
  "is_hidden": false,
  "is_internal_user": true,
  "user_requested_tenant": null,
  "backend_roles": [
    "admin"
  ],
  "custom_attribute_names": [],
  "tenants": {
    "global_tenant": true,
    "admin_tenant": true,
    "admin": true
  },
  "roles": [
    "own_index",
    "all_access"
  ]
}
{% endhighlight %}

However, updating the admin password doesn't work because the default security policy locks it down.

{% highlight bash %}
curl --insecure -u admin:password -XPUT "https://localhost:9200/_plugins/_security/api/account" -H 'Content-Type: application/json' -d' 
{
    "current_password": "password",
    "password": "6P2fTnMRTnDRiEEm"
}'

{"status":"FORBIDDEN","message":"Resource 'admin' is read-only."}
{% endhighlight %}

I found [security#1576](https://github.com/opensearch-project/security/issues/1576) that aims to fix this, but in the meantime, we'll have to do it the hard way.

### The Hard Way

The source for the docker-compose file used for the distribution is [here](https://github.com/opensearch-project/opensearch-build/blob/main/docker/release/dockercomposefiles/docker-compose-2.x.yml). The first time this is run it [executes](https://github.com/opensearch-project/opensearch-build/blob/main/docker/release/config/opensearch/opensearch-docker-entrypoint.sh#L38) the [install_demo_configuration.sh](https://github.com/opensearch-project/security/blob/main/tools/install_demo_configuration.sh) script from the security plugin, which itself runs [securityadmin_demo.sh](https://github.com/opensearch-project/security/blob/main/tools/securityadmin.sh), which itself runs [`org.opensearch.security.tools.SecurityAdmin`](https://github.com/opensearch-project/security/blob/main/src/main/java/org/opensearch/security/tools/SecurityAdmin.java) that's written in Java. This installs a default security configuration. Let's see what it looks like.

Find the docker container ID. In my case it's `b09419b98216`.

{% highlight bash %}
$ docker ps
CONTAINER ID   IMAGE                                 
b09419b98216   opensearchproject/opensearch:latest   ...
{% endhighlight %}

Run a shell in the instance.

{% highlight bash %}
$ docker exec -it b09419b98216 sh

sh-4.2$
{% endhighlight %}

Run the security plugin configuration tool to output the current configuration.

{% highlight bash %}
$ mkdir current-config

$ /usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh \
  -icl \
  -cacert /usr/share/opensearch/config/root-ca.pem \
  -cert /usr/share/opensearch/config/kirk.pem \
  -key /usr/share/opensearch/config/kirk-key.pem \
  -r  \
  -cd current-config
{% endhighlight %}

Examine the `internal_users.yml` file that was written to `current-config` with `cat current-config/internal_users_*.yml` (mine was called `internal_users_2023-Aug-08_15-52-25.yml`). The interesting part is the admin user.

{% highlight yaml %}
admin:
  hash: "$2a$12$VcCDgh2NDk07JGN0rjGbM.Ad41qVR/YFJcgHp0UGns5JDymv..TOG"
  reserved: true
  backend_roles:
  - "admin"
  description: "Demo admin user"
{% endhighlight %}

Let's generate a new password hash for our new password, `password`.

{% highlight bash %}
sh-4.2$ ./plugins/opensearch-security/tools/hash.sh
**************************************************************************
** This tool will be deprecated in the next major release of OpenSearch **
** https://github.com/opensearch-project/security/issues/1755           **
**************************************************************************
[Password:] password
$2y$12$jeBybG79iCu0y.A1NMqdI.8gA/d0Mrg6VRI3BrGD4VvTfeA1Z4tXu
{% endhighlight %}

Edit the `current-config/internal_users_*.yml` file, and replace the password hash with the one above.

{% highlight yaml %}
admin:
  hash: "$2y$12$jeBybG79iCu0y.A1NMqdI.8gA/d0Mrg6VRI3BrGD4VvTfeA1Z4tXu"
  reserved: true
  backend_roles:
  - "admin"
  description: "Demo admin user"
{% endhighlight %}

Upload the configuration.

{% highlight bash %}
$ /usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh \
  -icl \
  -t internalusers \
  -f current-config/internal_users_[your file name here].yml \
  -cacert /usr/share/opensearch/config/root-ca.pem \
  -cert /usr/share/opensearch/config/kirk.pem \
  -key /usr/share/opensearch/config/kirk-key.pem

Security Admin v7
Will connect to localhost:9200 ... done
Connected as "CN=kirk,OU=client,O=client,L=test,C=de"
OpenSearch Version: 2.9.0
Contacting opensearch cluster 'opensearch' and wait for YELLOW clusterstate ...
Clustername: docker-cluster
Clusterstate: YELLOW
Number of nodes: 1
Number of data nodes: 1
.opendistro_security index already exists, so we do not need to create one.
Populate config from /usr/share/opensearch
Force type: internalusers
Will update '/internalusers' with current-config/internal_users_....yml 
   SUCC: Configuration for 'internalusers' created or updated
{% endhighlight %}

Test the new password.

{% highlight bash %}
$ curl --insecure -u admin:admin https://localhost:9200
Unauthorized
{% endhighlight %}

{% highlight bash %}
$ curl --insecure -u admin:password https://localhost:9200
{
  "name" : "b09419b98216",
  "cluster_name" : "docker-cluster",
  "cluster_uuid" : "SYUzvRvqT06ld8IdvE5okQ",
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
{% endhighlight %}

Note that restarting the Docker container will override your changes with a clean image.
