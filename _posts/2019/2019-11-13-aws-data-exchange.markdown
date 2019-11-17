---
layout: post
title: "Building AWS Data Exchange and the Value of Simple Ideas at Scale"
tags: [aws, aws data exchange]
date: 2019-11-13
comments: true
---
Six months ago [I joined AWS](/2019/05/20/day-one-at-amazon-aws-principal-engineer-interviewing.html) to work on a new service, [AWS Data Exchange](https://aws.amazon.com/data-exchange/), launched today. AWS Data Exchange makes it easy to find, subscribe to, and use third-party data in the cloud.

<iframe width="560" height="315" src="https://www.youtube.com/embed/2M7S-rsCgfg" frameborder="0" allow="accelerometer; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe><br />

This is just the starting line for AWS Data Exchange.

Building the service I learned the value of simple ideas executed at scale. The service is conceptually simple, solving a number of existing customer problems. It splits the provider and subscriber responsibilities into two distinct processes - providers take care of publishing data updates, and subscribers receive data and updates with less effort. All the heavy lifting and shifting of data is done by AWS Data Exchange on top of Amazon S3, at scale, with battle tested reliability and high availability.

From a purely technical point of view, in the past customers would have to do a ton of 1-off handshakes for data to change hands. It got particularly unwieldily when you had to deal with permissions or immutability. By decomposing the problem into separate workflows it became really easy to solve many of these challenges. Providers publish once, and can easily supply updates. Subscribers are guaranteed immutability. Billing and entitlements are taken care of. Eseentialy, customers get increased reliability, higher availability and much lower cost.

Check out a [blog post on how to find and acquire new data sets, and retrieve new updates automatically](https://aws.amazon.com/blogs/big-data/find-and-acquire-new-data-sets-and-retrieve-new-updates-automatically-using-aws-data-exchange/) and [how to publish and update data products dynamically](https://aws.amazon.com/blogs/big-data/publish-and-update-data-products-dynamically-with-aws-data-exchange/), as well as some working code on [github.com/aws-samples/aws-dataexchange-api-samples](https://github.com/aws-samples/aws-dataexchange-api-samples).
