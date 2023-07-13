---
layout: post
title: "2011 – The Year of NoSQL Data Breaches?"
redirect_from: "/2011-the-year-of-nosql-data-breaches/"
date: 2011-01-27 14:27:27
tags: [mongodb, security, databases]
comments: true
dblog_post_id: 162
---
![]({{ site.url }}/images/posts/2011/2011-01-27-2011-the-year-of-nosql-data-breaches/image_3.jpg)

My latest article, [2011 – The Year of NoSQL Data Breaches?](https://web.archive.org/web/20120330060217/https://www.teamshatter.com/uncategorized/2011-%E2%80%93-the-year-of-nosql-data-breaches) was published this morning on TeamSHATTER.

I wanted to take a tangent on this topic and write down a paragraph or two about my hands-on experience with one of the NoSQL databases, [MongoDB](https://www.mongodb.org).

I have been experimenting using Mongo for a non-security-related pet project for several months now. I chose it as an alternative to a MySQL that was being used as a mix for inherently relational data, but mostly vector-type data where the number of vector items is not known ahead of time. For example, take a vector of times [t<sub>1</sub> = 1, t<sub>2</sub> = 0, t<sub>3</sub> = 15] associated with an object X. The zeros in this problem don’t matter, so we only need to store t<sub>1</sub> and t<sub>3</sub>. The relational schema has a table of _time_ with _time_id_ and _time_name_ – t<sub>1</sub> has ID of 42 and name "t1", and a table of time_values with  _object_id_, _time_id_ and _time_value_. This way we can re-create the vector of times for object X by selecting all the non-zero values from the time table and joining with the time table to get the location of the value within the vector. In contrast, in MongoDB (or any other NoSQL document-oriented database), given a document X we can store another document called times within it. X looks like this: `X = { id: ..., times: { t1: 1, t3 = 15 }}`. This problem has suddenly become trivial.

Out of all databases I’ve tried I picked MongoDB. It’s very well suited for the above-mentioned problem. It requires almost no installation, has a small footprint and excellent performance. It’s an extremely well engineered product by the smartest people in the room. It follows the same all-in-one philosophy that we successfully applied with the [Alkaline search engine](https://github.com/dblock/alkaline) a decade ago and is a pleasure to work with.

You can see why I was hesitant to write anything that could be even remotely negative about Mongo. So I showed the draft to a dozen people before publishing the article and everyone told me that it stroke a good balance, calling people’s attention on what’s important: secure your sensitive data. It’s pretty clear that MongoDB team is working on features in the priority order based on real customer input, so I am confident that it’s a matter of time till enterprise-grade security is built into this awesome database by either the Mongo team or independent contributors, provided there’s enough corporate interest. If you’re in a big company with lots of money and are using MongoDB, [pay some money to 10gen for commercial support](https://www.mongodb.com/support) and/or partner with them and sponsor the development of features that you need.
