---
layout: post
title: "Migrating from a relational to a NoSQL cloud database?"
redirect_from: "/migrating-from-a-relational-to-a-nosql-cloud-database"
date: 2012-12-10 02:35:04
tags: [scale, performance, technology, art.sy, mysql, mongodb, databases]
comments: true
---
![image]({{ site.url }}/images/posts/2012/2012-12-10-migrating-from-a-relational-to-a-nosql-cloud-database/image%5b10%5d.jpg)

I was recently quoted in a [TechRepublic article](http://www.techrepublic.com/blog/datacenter/migrating-from-a-relational-to-a-nosql-cloud-database/5904), making rather sweeping general statements about how the free open-source NoSQL databases are the best thing since both SQL and sliced bread. I think some context may have been lost there, so it’s worth talking about it.

Two years ago I was looking at the Art.sy prototype implemented with MySQL. I found out that it was doing a JOIN to compose the hundreds of genes with their values for each of N artworks at startup time, where N > 10000. That cannot scale, but it’s a dumb problem with many solutions. The best approach I could think of was to choose a store that natively supported a hash-like data structure – therefore I chose MongoDB. Learning how to use it was easy – much easier than even installing Oracle 11g. But even I can argue today that a relational database would have continued to pay dividends by helping me with data integrity, while a NoSQL store required a lot of programming discipline. Do you trust a programmer or the machine? The jury is out.

The article’s conclusion begins with _"Foursquare’s and Art.sy’s applications may be somewhat unique."_ I would want to stop there. Every single application that you’re building is unique and deserves individualized attention to its data. Furthermore, database technology makes giant leaps every year in both SQL and NoSQL spaces - when I started, Heroku didn’t have a [PostgreSQL](https://postgres.heroku.com/) offering that can do 1TB storage with a 68GB cache layer and fork-and-follow, and Amazon did not have [DynamoDB](http://aws.amazon.com/dynamodb/) that runs off SSDs. Personally, I don’t make such a black and white distinction between SQL and NoSQL anymore – these are powerful tools available to the developers – I choose the best tool for the job in front of me.

PS: we use MongoDB in production and I strongly recommend it, but if you find me talking excitedly about the next big thing in databases today, it’s likely to be [Datomic](http://www.datomic.com).
