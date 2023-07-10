---
layout: post
title: "Making HTTPs Requests in Ruby & JavaScript w/ Node.js"
redirect_from: "/making-https-requests-in-ruby-javascript-w-nodejs/"
date: 2013-09-30 05:33:31
tags: [nodejs, javascript, ruby]
comments: true
dblog_post_id: 394
---
Making HTTPs requests seems oddly difficult. Why can't an HTTP library just figure things out for me like curl does? It mostly can.

#### Ruby

You have to breakup the URL into a host, port and path, then make a request with _use_ssl_.

```
$ irb

require 'net/http'

uri = URI::parse("https://artsy.net/api/v1/system/up")
Net::HTTP.start uri.host, uri.port, use_ssl: (uri.scheme == "https") do |http|
 request = Net::HTTP::Get.new(uri.path)
 response = http.request request
 puts response.body
end
```

#### Node.js

A little simpler, [superagent](https://github.com/ladjs/superagent), also known as "ajax with less suck", can take care of everything.

```
$ npm install -g superagent

$ coffee

http = require('superagent')
http.get('https://artsy.net/api/v1/system/up').end((err, res) -> console.log res.body)
```
