---
layout: post
title: Programming Languages in 2022
date: 2022-12-27
tags: [learning, programming]
comments: true
---
I got stuck somewhere in British Columbia during the US "bomb" cyclone, with hours to spare. So I decided to finish [implementing samples that call OpenSearch with Sigv4 signing](/2022/07/11/making-sigv4-authenticated-requests-to-managed-opensearch.html) in each of the 8 existing language clients.

All these do the same operation: make an instance of a client, query and display the server version, create an index called `movies`, insert a record into movies for the Bennett Miller's 2011 "Moneyball", search for "miller", output the result, then cleanup by deleting the record, and then the empty index. Note that I have no idea why this specific film was chosen in all Elasticsearch documentation - I would have chosen Andrei Tarkovsky's 1972 "Solaris".

My only conclusion from this exercise is that the Go programming language is [objectively insane](https://jesseduffield.com/Gos-Shortcomings-1/).

| client                                                            | lines of code |
|-------------------------------------------------------------------|---------------|
| [go](https://github.com/dblock/opensearch-go-client-demo)         | 89            |
| [java](https://github.com/dblock/opensearch-java-client-demo)     | 80            |
| [rust](https://github.com/dblock/opensearch-rust-client-demo)     | 75            |
| [dotnet](https://github.com/dblock/opensearch-dotnet-client-demo) | 68            |
| [python](https://github.com/dblock/opensearch-python-client-demo) | 50            |
| [php](https://github.com/dblock/opensearch-php-client-demo)       | 50            |
| [node](https://github.com/dblock/opensearch-node-client-demo)     | 45            |
| [ruby](https://github.com/dblock/opensearch-ruby-client-demo)     | 44            |
