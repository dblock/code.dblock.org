---
layout: post
title: "Writing Data to Amazon S3 from Apache Spark"
date: 2017-04-27
tags: [scala, spark, s3, aws]
comments: true
---
I [recently started working with Apache Spark, Hadoop, HDFS and Hive](/2017/04/02/getting-started-with-spark-hadoop-hdfs-hive.html). I [made some jobs in Scala that generated website sitemaps](https://artsy.github.io/blog/2017/04/02/generating-sitemaps-with-apache-spark) and another that [calculated the imporance of an artwork amongst all other artist's artworks](https://artsy.github.io/blog/2017/04/21/calculating-the-importance-of-an-artwork-with-apache-spark). Today I wrote an inverted index that exploded a dictionary of art genome data.

The input is millions of rows containing a (gene name -> gene value) dictionary, stored in HDFS as `map<string,double>`, and the output is many more millions of rows of JSON such as `{ artist_id: "id", name: "gene name", value: "gene value" }` exported to S3. This index is ultimately imported back into MongoDB and used on Artsy for fast lookup of artworks or artists that have certain genes within a requested range.

In order to write a single file of output to send to S3 our Spark code calls `RDD[string].collect()`. This works well for small data sets - we can save a `.jsondump` file to the local file system and send it to S3.

{% highlight scala %}
def save(
  results: RDD[String],
): Unit = {
  // create a temporary file
  val file = File.createTempFile(buildName, "jsondump")
  file.deleteOnExit()

  // stream data into the file
  val bw = new BufferedWriter(new FileWriter(file))
  results.collect().foreach { f =>
    bw.write(f)
    bw.newLine()
  }
  bw.close()

  // send the file to S3
  val request = new PutObjectRequest("bucket", "file.jsondump", file)
  new AmazonS3Client.putObject(request)
}
{% endhighlight %}

For larger datasets this code causes `java.lang.OutOfMemoryError : GC overhead limit exceeded`. An obvious solution would be to partition the data and send pieces to S3, but that would also require changing the import code that consumes that data. Fortunately, Spark lets you mount S3 as a file system and use its built-in functions to write unpartitioned data.

{% highlight scala %}
def save(
  results: RDD[String],
): Unit = {
  results.repartition(1).saveAsTextFile(s"s3a://bucket/file.jsondump.tmp")
  new AmazonS3Client.copyObject(
    "bucket", "file.jsondump.tmp/part-00000",
    "bucket", "file.jsondump"
  )
  new AmazonS3Client.deleteObject("bucket", s"file.jsondump.tmp/part-00000")
  new AmazonS3Client.deleteObject("bucket", s"file.jsondump.tmp/_SUCCESS")
}
{% endhighlight %}

In the code above `repartition` doesn't bring the results into driver memory, it just prompts a shuffle of the data on the network to one single location, unlike `collect`. This can be slow due to network overhead but doesn't run out of memory. Then, we use the native `saveAsTextFile` to stream this data to S3 and cleanup after ourselves.

For `s3a://` to work you need to configure credentials globally, however you can also do it in code if you want to experiment.

{% highlight scala %}
results.sparkContext.hadoopConfiguration.set("fs.s3a.access.key", "...")
results.sparkContext.hadoopConfiguration.set("fs.s3a.secret.key", "...")
{% endhighlight %}

A few useful notes and links.

* [S3 Support in Apache Hadoop](https://cwiki.apache.org/confluence/display/HADOOP2/AmazonS3)
* [Dealing with java.lang.OutOfMemoryError : GC overhead limit exceeded in Spark](https://stackoverflow.com/a/22742982/123094)
* [What is the difference between s3n, s3a and s3?](https://stackoverflow.com/q/33356041/123094)
