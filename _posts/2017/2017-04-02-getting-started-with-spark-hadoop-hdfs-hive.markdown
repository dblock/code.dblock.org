---
layout: post
title: "Getting Started with Spark, Hadoop, HDFS and Hive"
date: 2017-04-02
tags: [scala, spark, hive]
comments: true
---
Two weeks ago I had zero experience with Spark, Hive, or Hadoop. Two weeks later I [was able to reimplement Artsy sitemaps using Spark](http://artsy.github.io/blog/2017/04/02/generating-sitemaps-with-apache-spark) and even gave a "Getting Started" workshop to my team (with some help from [@izakp](https://github.com/izakp)). I've also made some [pull requests into Hive-JSON-Serde](https://github.com/rcongiu/Hive-JSON-Serde/pulls?utf8=%E2%9C%93&q=is%3Apr%20author%3Adblock%20) and am starting to really understand what's what in this fairly complex, yet amazing ecosystem.

This post will get you started with Hadoop, HDFS, Hive and Spark, fast.

### What is Spark?

Apache Spark is a _fast and general purpose engine for large-scale data processing_. You can write code in Scala or Python and it will automagically parallelize itself on top of Hadoop. It basically runs map/reduce.

### What is Hadoop and HDFS?

Hadoop is a software library, which is a _framework that allows for the distributed processing of large data sets across clusters of computers using simple programming models_. It's really a common library called _Hadoop Common_ and a framework called _Hadoop MapReduce_ that sits on top of a distributed file system, called HDFS.

### What is Yarn?

The _Hadoop Distributed File System_ or _HDFS_ is a way to distribute file system data to a bunch of workers. The distribution, job scheduling and cluster resource management is done by a system called _Yarn_.

### What is Hive?

Hadoop alone doesn't know much about data structure and deals with text files. Most humans work with SQL, so the Apache _Hive_ data warehouse software _facilitates reading, writing, and managing large datasets residing in distributed HDFS storage using SQL_. It lets you create and query a SQL schema on top of text files, which can be in various formats, including the usual CSV or JSON.

## Running Locally

A good place to start is to run a few things locally.

## Hadoop

On OSX run `brew install hadoop`, then configure it ([This post](https://amodernstory.com/2014/09/23/installing-hadoop-on-mac-osx-yosemite) was helpful.) I turned the configuration into a script in my [dotfiles](https://github.com/dblock/dotfiles/tree/master/hadoop). Once installed you can run `hstart`. Once working, you can navigate to a local resource manager on `http://localhost:50070` or the job tracker on `http://localhost:8088` and run a small test.

{% highlight shell %}
$> wget https://www.dropbox.com/s/cyuah7lc31g0x3h/hadoop-mapreduce-examples-2.6.0.jar?dl=1 -O hadoop-mapreduce-examples-2.6.0.jar
$> hadoop jar hadoop-mapreduce-examples-2.6.0.jar  pi 10 100

Number of Maps  = 10
Samples per Map = 100
...
Job Finished in 3.203 seconds
Estimated value of Pi is 3.14800000000000000000
{% endhighlight %}

## Hive

Once you've installed Hadoop, install Hive. On OSX run `brew install hive`, the configure it. I turned the configuration into a script in my [dofiles](https://github.com/dblock/dotfiles/tree/master/hive) as well. The biggest difficulty is that you need to initialize a metastore where Hive stores its configuration information with `schematool -initSchema -dbType derby` (or another `dbType`, such as `mysql` or `postgres`). In the case of Derby, the `metastore_db` is created in the same directory as from where you run the command, so it needs to be tied down to a location via `hive-site.xml`.

{% highlight xml %}
<configuration>
  <property>
    <name>javax.jdo.option.ConnectionURL</name>
    <value>jdbc:derby:;databaseName=/usr/local/Cellar/hive/metastore_db;create=true</value>
    <description>JDBC connect string for a JDBC metastore</description>
  </property>
</configuration>
{% endhighlight %}

Once installed you can run `hive` and get a `hive> ` prompt.

Before we do that, lets get some data into HDFS.

{% highlight shell %}
$> cat /tmp/physicists.csv
Albert,Einstein
Marie,Curie


$> hadoop fs -mkdir /user/data
$> hadoop fs -put /tmp/physicists.csv /user/data

$> hadoop fs -ls /user/data
-rw-r--r--   1 dblock supergroup         39 2017-04-03 12:51 /user/data/physicists.csv
{% endhighlight %}

Load data into Hive. If you have existing data files you can just use those and add a schema on top of them with `CREATE EXTERNAL TABLE`.

{% highlight shell %}
$> hive

hive> CREATE EXTERNAL TABLE physicists(first string, last string)
      ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
      WITH SERDEPROPERTIES (
         "separatorChar" = ",",
         "quoteChar"     = "'",
         "escapeChar"    = "\\"
      )
      STORED AS TEXTFILE
      LOCATION '/user/data';

OK
Time taken: 0.602 seconds

hive> hive> SELECT * FROM physicists;
OK

Albert  Einstein
Marie Curie

Time taken: 1.732 seconds, Fetched: 3 row(s)
{% endhighlight %}

## Spark

Neither Hadoop or Hive are prerequisites to run Spark on OSX, install it with `brew install apache-spark`. From your installation in `/usr/local/Cellar/apache-spark/X.Y.Z` run `./bin/run-example SparkPi 10` from there. You should see `Pi is roughly 3.1413551413551413`.

You can run a Spark shell with `spark-shell`. Lets play with a [sample dataset of country GDPs](https://gist.githubusercontent.com/izakp/2244e9b256fab99cf8bbf6215d9c02c6/raw/a92422f29412fcac34e4847cf0d5409e1d057e29/gdp.json) curated for us by [@ByzantineFault](https://twitter.com/ByzantineFault) during a recent [@ArtsyOpenSource](https://twitter.com/artsyopensource) Spark workshop.

{% highlight shell %}
$> wget https://gist.githubusercontent.com/izakp/2244e9b256fab99cf8bbf6215d9c02c6/raw/a92422f29412fcac34e4847cf0d5409e1d057e29/gdp.json

$> spark-shell

Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 2.1.0
      /_/

scala> val gdpDF = spark.read.json("/tmp/gdp.json")
gdpDF: org.apache.spark.sql.DataFrame = [Country Code: string, Country Name: string ... 2 more fields]

scala> gdpDF.printSchema()
root
 |-- Country Code: string (nullable = true)
 |-- Country Name: string (nullable = true)
 |-- Value: double (nullable = true)
 |-- Year: long (nullable = true)
{% endhighlight %}

We can turn this data into a proper _resilient distributed dataset_ (RDD).

{% highlight shell %}
scala> val gdpRDD = gdpDF.rdd
gdpRDD: org.apache.spark.rdd.RDD[org.apache.spark.sql.Row] = MapPartitionsRDD[12] at rdd at <console>:27

scala> gdpRDD.count()
res3: Long = 10355

scala> val pairRDD = gdpRDD.map( row => (row.get(1), row.getAs[Double](2)) )
pairRDD: org.apache.spark.rdd.RDD[(Any, Double)] = MapPartitionsRDD[13] at map at <console>:29

scala> pairRDD.foreach(println)
(Arab World,3.6229613725645E10)
(Arab World,4.31351681965945E10)
(Arab World,5.47808799760272E10)
(Arab World,1.04523001271412E11)
(Arab World,1.15752821947206E11)
(Arab World,1.44057806919486E11)
(Arab World,1.65984443446144E11)
(Arab World,1.83528095316993E11)
(Arab World,2.47491798430331E11)
...

scala> pairRDD.groupByKey().foreach(println)
(Australia,CompactBuffer(1.85743084331952E10, 1.96516967185575E10, 1.98868854294994E10, 2.15007279650577E10, 2.37585395900997E10, 2.5930115354463E10, 2.72550117594355E10, 3.03830216149625E10, 3.264755291746E10, 3.66121626161944E10, 4.12520998992048E10, 4.51271138985329E10, 5.19369158878505E10, 6.37001921844971E10, 8.87899778924097E10, 9.70981838044517E10, 1.0483297617547E11, 1.10115852259693E11, 1.18238213399504E11, 1.34607520163581E11, 1.49679108635098E11, 1.7655752931615E11, 1.93684210526316E11, 1.76929340196537E11, 1.93232204310813E11, 1.80215540385058E11, 1.82032736429771E11, 1.89113287453679E11, 2.35787252619325E11, 2.9947479846918E11, 3.10944978838015E11, 3.25641629385449E11, 3.25313389217873E11, 3.12028527262507E11, 3.22874437910758E11, 3.68022720522721E11, 4.0140971168437E11, 4.35636249804351E11, 3.9932510343892E11, 3.8869219200401E11, 4.14987125541669E11, 3.784882472899E11, 3.94250732524069E11, 4.66451368666278E11, 6.12871674491393E11, 6.93338595699895E11, 7.47205750224618E11, 8.53441155688153E11, 1.05503165229816E12, 9.26283274398423E11, 1.14126776018815E12, 1.38806635609196E12, 1.53442590576266E12, 1.56037247312521E12, 1.45377021067204E12))
...
{% endhighlight %}

Lets calculate the total GDP for each country during the years surveyed.

{% highlight shell %}
scala> pairRDD.reduceByKey((a,b) => a + b).foreach(println)
(Australia,2.0298746299037598E13)
(Small states,2.778625996176125E12)
(Brazil,3.212770450746525E13)
...
{% endhighlight %}

For more advanced examples check out the [Spark programming guide](https://spark.apache.org/docs/latest/programming-guide.html).

We can also get our data from our previous Hive installation (Spark comes with its own "standalone" hive, too) by linking `hive-site.xml` into Spark's `libexec/conf/hive-site.xml` as in [my dotfiles](https://github.com/dblock/dotfiles/tree/master/spark).

{% highlight shell %}
$> ln -s /usr/local/Cellar/hive/2.1.0/libexec/conf/hive-site.xmlhive/conf/hive-site.xml /usr/local/Cellar/spark/2.1.0/libexec/conf/hive-site.xmlhive/conf/hive-site.xml

$> spark-shell

scala> val hc = new org.apache.spark.sql.hive.HiveContext(sc)
hc: org.apache.spark.sql.hive.HiveContext = org.apache.spark.sql.hive.HiveContext@26838837

scala> val rdd = hc.sql("SELECT * FROM physicists")

scala> rdd.foreach(row => println(row))
[Albert,Einstein]
[Marie,Curie]
{% endhighlight %}

## Next Steps

The next step should be to write a Spark job in Scala. If you want to share one, I'll add it to this tutorial.
