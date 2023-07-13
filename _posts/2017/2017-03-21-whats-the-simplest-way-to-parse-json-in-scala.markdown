---
layout: post
title: "What's the simplest way to parse JSON in Scala?"
date: 2017-03-21
tags: [scala, json]
comments: true
---
While XML is a first-class citizen in Scala, there's no "default" way to parse JSON. So searching StackOverflow and Google yields all kinds of responses that seem unnecessarily complicated.

### Jackson

[This SO answer describes the easiest solution](https://stackoverflow.com/questions/20029412/scala-play-parse-json-into-map-instead-of-jsobject/20034844#20034844), which gives you a `Map[String, Object]`, use [jackson-module-scala](https://github.com/FasterXML/jackson-module-scala).

{% highlight scala %}
import scala.io._
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.module.scala.DefaultScalaModule
import com.fasterxml.jackson.module.scala.experimental.ScalaObjectMapper

object Main {
  def main(args: Array[String]): Unit = {
    val filename = args.head
    // read
    println(s"Reading ${args.head} ...")
    val json = Source.fromFile(filename)
    // parse
    val mapper = new ObjectMapper() with ScalaObjectMapper
    mapper.registerModule(DefaultScalaModule)
    val parsedJson = mapper.readValue[Map[String, Object]](json.reader())
    println(parsedJson)
  }
}
{% endhighlight %}

Here's the output from a [sample JSON](https://github.com/dblock/scala-parse-json/blob/master/example.json).

{% highlight shell %}
Reading example.json ...
Map(glossary -> Map(title -> example glossary, GlossDiv -> ..., GlossTerm -> Standard Generalized Markup Language)))))
{% endhighlight %}

### Liftweb JSON

The `lift-json` JSON parser in [Liftweb](https://github.com/lift/framework) does a good job, too, but returns `JObject`-like types instead of raw `String` or `Map[String, Object]`.

{% highlight scala %}
import scala.io._
import net.liftweb.json._

object Main {
  def main(args: Array[String]): Unit = {
    val filename = args.head
    // read
    println(s"Reading ${args.head} ...")
    val json = Source.fromFile(filename)
    // parse
    let parsedJson = net.liftweb.json.parse(json.mkString)
    println(parsedJson)
  }
}
{% endhighlight %}

Here's the output from a [sample JSON](https://github.com/dblock/scala-parse-json/blob/master/example.json).

{% highlight shell %}
JObject(List(JField(glossary, ...)))
{% endhighlight %}

### Source

The code above is [here](https://github.com/dblock/scala-parse-json), maybe someone can contribute an example for writing JSON?
