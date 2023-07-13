---
layout: post
title: "Google Finance Web API Ruby Client"
date: 2017-12-30
tags: [technology, finance, ruby]
comments: true
---
There's a bunch of financial market APIs out there, and after having tried a few for [slack-market](https://market.playplay.io) I still ended up using Yahoo Finance, undocumented, but wildly popular, "API". What I really wanted was to find a plain simple HAL or GraphQL API or a Ruby client that could give me basic interday and intraday data for a given ticker, aggregated from multiple exchanges. But most options were just far too complex, extremely comprehensive to a point of being unusable for basic scenarios, not developer-friendly, or too expensive. Yahoo then suddenly and permanently discontinued their API in May 2017, in a beautiful example of how a big company fails to nurture and build upon developer relations.

[Google Finance](https://finance.google.com) has a similarly undocumented web API. Hey Google, maybe you have an opportunity here to pickup where Yahoo left? Lets see how long that one lasts.

To abstract away the hodgepodge of undocumented and unsupported URLs and to make simple tasks easy, I wrote [google-finance-ruby-client](https://github.com/dblock/google-finance-ruby-client). The library supports retrieving stock quotes and historical prices in a structured form and returns object oriented results with properly coerced and documented properties. It also handles errors sanely.

### Get a Quote

{% highlight ruby %}
quote = GoogleFinance::Quote.get('MSFT')

quote.last_trade_price # 84.26
quote.change # 0.09
quote.change_in_percent # 0.11
quote.change_in_percent_s # "+0.11%"
{% endhighlight %}

### Interday Prices

{% highlight ruby %}
prices = GoogleFinance::History.get('MSFT')

prices.first # #<GoogleFinance::Price close=85.54 date=#<Date: 2017-12-29> high=86.05 low=85.5 open=85.63 volume=18717406>
{% endhighlight %}

### Intraday Prices

{% highlight ruby %}
prices = GoogleFinance::Prices.get('GOOG', interval: 60 * 60, period: '1d')

prices.count # 7

prices # array of GoogleFinance::Price, date=2017-12-29 10:00AM, 11:00AM, etc.
{% endhighlight %}

IANAL, but do note that if your application is for public consumption, using the Google Finance API [seems to be against Google's terms of service](https://groups.google.com/forum/#!msg/google-finance-apis/O8fjsgnamHE/-ZKSjif4yDIJ). YMMV.
