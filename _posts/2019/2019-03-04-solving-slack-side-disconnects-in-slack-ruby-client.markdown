---
layout: post
title: "Solving Slack-Side Disconnects in slack-ruby-client"
date: 2019-03-04
tags: [slack, ruby]
comments: true
---
In June 2018 users started reporting slack-side disconnects in their Ruby bots, reported via [slack-ruby-client#208](https://github.com/slack-ruby/slack-ruby-client/issues/208), regardless of the concurrency library (Eventmachine or Celluloid) used. I was already observing this behavior in my larger production bots, especially [playplay.io](https://www.playplay.io) with hundreds of teams.

Because this was a new behavior I assumed that the client was not seeing or handling some new type of communication error correctly at the websocket library layer. This has been an issue before, and in the case of Celluloid, IO exceptions had to be handled by emitting a `:close` event [here](https://github.com/slack-ruby/slack-ruby-client/blob/master/lib/slack/real_time/concurrency/celluloid.rb#L39). That is, the websocket library was seeing a problem and raising an exception, but the client didn't properly emit a close event, so the bots just sat there waiting for something to happen.

{% highlight ruby %}
def run_loop
  loop { read }
rescue EOFError, Errno::ECONNRESET, Errno::EPIPE => e
  driver.emit(:close, WebSocket::Driver::CloseEvent.new(1001, 'server closed connection'))
end
{% endhighlight %}

The `Faye::WebSocket::Client` implementation has not seen a similar problem as it deferred reading data to `WebSocket::Driver::StreamReader`, which seemed to bubble up disconnects properly until these reports.

The server-side disconnects had started happening without any code changes, so naturally I assumed this was new behavior at Slack and opened a ticket on June 13. Slack quickly looped in [@aoberoi](https://github.com/aoberoi) from the SDKs team to help, but he found nothing wrong on the Slack side.

### Bandaids

To relieve the immediate problem I stuck a restart into my bots (eg. [slack-strava@bc29324](https://github.com/dblock/slack-strava/commit/bc293248bae678dd9299b1d2888443adedae4da8)) and began seeing about a dozen of these server-side disconnects every hour.

{% highlight ruby %}
def cron
  once_and_every 60 * 60 do
    ping_teams!
  end
end

def ping_teams!
  Team.active.each do |team|
    begin
      ping = team.ping!
      next if ping[:presence].online
      logger.warn "DOWN: #{team}"
      after 60 do
        ping = team.ping!
        unless ping[:presence].online
          logger.info "RESTART: #{team}"
          SlackStrava::Service.instance.start!(team)
        end
      end
    rescue StandardError => e
      logger.warn "Error pinging team #{team}, #{e.message}."
    end
  end
end
{% endhighlight %}

Gross, but effective.

### Async Implementation

Because both the asynchronous library and the websocket implementation were used by thousands of projects, I naturally assumed slack-ruby-client would be more likely to have a bug. The celluloid-io code that I wrote was not detecting server-side disconnects occasionally, therefore we must have not been using celluloid-io correctly in [concurrency/celluloid.rb](https://github.com/slack-ruby/slack-ruby-client/blob/master/lib/slack/real_time/concurrency/celluloid.rb#L31). I summarized my conclusion in [celluloid-io#187](https://github.com/celluloid/celluloid-io/issues/187) and asked for help.

It turned out that Celluloid::IO was effectively unmaintained and I was told to switch to [async](https://github.com/socketry/async). While that was a viable idea, replacing the concurrency library could easily create many new bugs without fixing the underlying issue. I wanted to understand the root cause, first.

### Websocket Ruby Driver

Interestingly, both Celluloid and EventMachine used [websocket-ruby-driver](https://github.com/faye/websocket-driver-ruby) and, since both concurrency libraries exhibited a similar problem, I opened [websocket-driver-ruby#61](https://github.com/faye/websocket-driver-ruby/issues/61) and asked for ideas. I got a really helpful response from [@ioquatix](https://github.com/ioquatix), the author of async.

I didn't realize the socket `read` could return `nil`, meaning something like a disconnect. A read of length 0 returned `nil`. You also needed to handle empty strings, which may have meant that the client was disconnected. That's `EPIPE`, `EOFError`, `ECONNRESET`, `nil` and `""`.

Adding the code to handle all of the above in [slack-ruby-client#216](https://github.com/slack-ruby/slack-ruby-client/pull/216) solved nothing.

### What else could go wrong?

There was some speculation that the bug was in `Celluloid::IO::SSLSocket`. It wasn't.

### Async-Websocket

Having no good ideas I ventured into replacing EventMachine and Celluloid with Async in [slack-ruby-client#219](https://github.com/slack-ruby/slack-ruby-client/pull/219) with a lot of help. That solved nothing, as expected, but replaced an unsupported library with a supported one.

### Websocket-Level Ping Monitoring

We naturally reached the obvious conclusion that there was no bug and that the protocol required an active heartbeat, and that there was none implemented.

[@RodneyU215](https://github.com/RodneyU215) from Slack stepped in and added ping monitoring in [slack-ruby-client#226](https://github.com/slack-ruby/slack-ruby-client/pull/226) following [Slack's RTM guidelines](https://api.slack.com/rtm) (see Ping and Pong). The entire discussion and the evolution of that code is worth a read. I notably learned that Ruby `Time.now` was [not monotonic](https://blog.dnsimple.com/2018/03/elapsed-time-with-ruby-the-right-way/).

I found the final code in [slack-ruby-client#226](https://github.com/slack-ruby/slack-ruby-client/pull/226) to be a rather elegant and straightforward example of a complex asynchronous process.

### Released Libraries

The active ping monitoring was released in slack-ruby-client 0.14.1, slack-ruby-bot 0.12.0 and slack-ruby-bot-server 0.9.0 and seemed to have worked well, short of [slack-ruby-client#257](https://github.com/slack-ruby/slack-ruby-client/issues/257) being watched.

### Thanks

Again, much thanks to Slack's team for debugging, support and code, including [Rodney Urquhart](https://github.com/RodneyU215), [Ankur Oberoi](https://github.com/aoberoi) and [Jason Roche](https://github.com/roach), as well as [Samuel Williams](https://github.com/ioquatix) for his Async library, his adult supervision and for catching tons of non-obvious hard bugs across multiple code reviews.

### Links

* [slack-ruby-client#208](https://github.com/slack-ruby/slack-ruby-client/issues/208): Slack-side disconnects.
* [celluloid-io#187](https://github.com/celluloid/celluloid-io/issues/187): Help with server-side disconnects in slack-ruby-client.
* [slack-ruby-client#216](https://github.com/slack-ruby/slack-ruby-client/pull/216): Handle `Errno::ECONNRESET` and empty buffer reads with celluloid-io.
* [slack-ruby-client#219](https://github.com/slack-ruby/slack-ruby-client/pull/219): Added support for async-websocket.
* [slack-ruby-client#226](https://github.com/slack-ruby/slack-ruby-client/pull/226), [#232](https://github.com/slack-ruby/slack-ruby-client/pull/232), [#236](https://github.com/slack-ruby/slack-ruby-client/pull/236), [#234](https://github.com/slack-ruby/slack-ruby-client/pull/234), [#254](https://github.com/slack-ruby/slack-ruby-client/issues/254): Adding Slack Socket level ping/pong.
* [slack-ruby-bot#203](https://github.com/slack-ruby/slack-ruby-bot/pull/203): Removed restart logic.
* [slack-ruby-bot-server#93](https://github.com/slack-ruby/slack-ruby-bot-server/pull/93): Removed ping worker.
* [slack-ruby-client#262](https://github.com/slack-ruby/slack-ruby-client/pull/262): Better disconnect handling, fixing occasional failures to reconnect.
