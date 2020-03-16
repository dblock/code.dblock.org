---
layout: post
title: "Working with AWS SDK for PHP and Data Exchange"
date: "2020-03-16"
tags: [php, aws, aws data exchange]
---
I made a website in PHP around 1996, right after the birth of the thing itself, to replace some dirty C++ CGI scripts. That didn't live for long, so I haven't really done PHP in 24 (!) years.

And so, [having recently struggled with using the AWS C++ SDK](/2020/03/06/working-with-aws-cpp-sdk-and-data-exchange.html), I decided to waste more time, and build a "hello world" [PHP sample for AWS Data Exchange](https://github.com/aws-samples/aws-dataexchange-api-samples/pull/34) using the [AWS SDK for PHP](https://aws.amazon.com/sdk-for-php/). It was almost too easy.

### Installing PHP

The [Getting Started documentation](https://docs.aws.amazon.com/sdk-for-php/v3/developer-guide/getting-started_index.html) was straightforward. On my Mac I ran `brew install php` and called it a day.

{% highlight bash %}
$ php -v
PHP 7.4.3 (cli) (built: Feb 20 2020 12:23:37) ( NTS )
Copyright (c) The PHP Group
Zend Engine v3.4.0, Copyright (c) Zend Technologies
    with Zend OPcache v7.4.3, Copyright (c), by Zend Technologies
{% endhighlight %}

### Installing Composer

Apparently, PHP now comes with a package manager called [Composer](https://getcomposer.org/download/). I put mine into `/usr/local/bin`.

{% highlight bash %}
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
php -r "unlink('composer-setup.php');"
{% endhighlight %}

### Getting the AWS SDK for PHP

I made a new directory, and added the AWS SDK for PHP as a dependency.

{% highlight bash %}
> mkdir all-entitled-datasets
> cd all-entitled-datasets
all-entitled-datasets> composer require aws/aws-sdk-php
{% endhighlight %}

This generated project, including a `composer.json`, and ran `composer install`, which downloaded dependencies and created a `composer.lock` file for future runs of `composer install` to maintain consistent versions.

### Writing Code

All PHP code is within `<?php ?>` tags. The following example initializes the AWS SDK, creates an instance of a Data Exchange client, and lists entitled datasets.

{% highlight bash %}
<?php

require 'vendor/autoload.php';

$sharedConfig = [
  'region' => 'us-east-1',
  'version' => 'latest'
];

$sdk = new Aws\Sdk($sharedConfig);

$dx = $sdk->createDataExchange();

$result = $dx->listDataSets(['Origin' => 'ENTITLED']);

foreach ($result['DataSets'] as $data_set) {
    echo $data_set['OriginDetails']['ProductId'] . '/' . $data_set['Name'] . "\n" .
      '  ' . $data_set['Description'] . "\n";
}

?> 
{% endhighlight %}

### Running the Sample

To run the sample, set `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` and `AWS_REGION`.

{% highlight bash %}
all-entitled-datasets> php all-entitled-datasets.php
prod-zg4u6tpyxud5i/7ae12084f47ea658ab62ee90edd513dd: NYC Property Sales 2014
  Over 80,000 property sales in New York City in 2014
prod-zg4u6tpyxud5i/05964b659bbcb607d43c0d5845838e7f: NYC Property Sales 2015
  Over 80,000 property sales in New York City in 2015
prod-zg4u6tpyxud5i/fc19d00c8780199e4fccd21f4834c905: NYC Property Sales 2018
  A table of 80,000+ New York City property sales occurring in 2018, organized by borough, including sale price and sale date. 
prod-zg4u6tpyxud5i/7d8f73e3c5acdde79fd2874dd98afdcd: NYC Property Sales 2016
  Over 80,000 property sales in New York City in 2016
prod-zg4u6tpyxud5i/50782dc315b94e46fdbd4a12cec6820e: NYC Property Sales 2017
  Records of over 80,000 property sales transactions. 
{% endhighlight %}

### Links

See [aws-dataexchange-api-samples#34](https://github.com/aws-samples/aws-dataexchange-api-samples/pull/34) for complete working code.
