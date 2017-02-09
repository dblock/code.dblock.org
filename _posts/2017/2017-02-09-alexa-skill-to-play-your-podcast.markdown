---
layout: post
title: "Building an Alexa Skill to Play Your Podcast"
date: 2017-02-09
tags: [alexa, amazon, echo]
comments: true
---
If you've never listened to the Artsy podcast, I highly recommend it. Available on [iTunes](https://itunes.apple.com/us/podcast/artsy/id1096194516) and [Soundcloud](https://soundcloud.com/artsypodcast) and now on your Amazon Echo.

First, _enable Artsy_, then _ask artsy to play the latest podcast_ or _ask Artsy for a summary of the latest podcast_. The code uses the audio player functionality introduced in [alexa-app](https://github.com/alexa-js/alexa-app) 2.4.0 and is [artsy/elderfield#56](https://github.com/artsy/elderfield/pull/56).

The Artsy editorial team uploads the podcast to SoundCloud, which exposes an [RSS feed](http://feeds.soundcloud.com/users/soundcloud:users:211089382/sounds.rss) that is used to publish to iTunes. YMMV wrt how you generate an RSS feed - when I was new to podcasting with Pod5, I had settled on a [Jekyll-based system](https://github.com/pod5/pod5.github.io).

The intent retrieves the podcast, extracts the MP3 URL and calls `audioPlayerPlayStream`.

{% highlight javascript %}
app.intent('PodcastIntent', {},
    "utterances": [
      "to play the latest podcast"
    ]
  },
  function(req, res) {
    // retrieve the podcast Mpeg enclosure from the RSS feed
    var podcastStream = ...;
    return podcastStream.then(function(audioMpegEnclosure) {
      // SSL required by Amazon, available on SoundCloud
      var streamUrl = audioMpegEnclosure.url.replace('http://', 'https://');
      var stream = {
        url: streamUrl,
        token: streamUrl,
        offsetInMilliseconds: 0
      }
      res.audioPlayerPlayStream('REPLACE_ALL', stream);
      res.send();
    });
  }
);
{% endhighlight %}

Note that we set the value of `token` to the MP3 stream URL. This is supposed to be a unique opaque identifier, but the URL works well and allows to pause the playback with `audioPlayerStop` and resume the podcast with `audioPlayerPlayStream` without having to lookup the MP3 location.

{% highlight javascript %}
app.intent('AMAZON.PauseIntent', {},
  function(req, res) {
    console.log('app.AMAZON.PauseIntent');
    res.audioPlayerStop();
    res.send();
  }
);

app.intent('AMAZON.ResumeIntent', {},
  function(req, res) {
    console.log('app.AMAZON.ResumeIntent');
    if (req.context.AudioPlayer.offsetInMilliseconds > 0 &&
      req.context.AudioPlayer.playerActivity === 'STOPPED') {
        res.audioPlayerPlayStream('REPLACE_ALL', {
          // hack: use token to remember the URL of the stream
          token: req.context.AudioPlayer.token,
          url: req.context.AudioPlayer.token,
          offsetInMilliseconds: req.context.AudioPlayer.offsetInMilliseconds
      });
    }
    res.send();
  }
);
{% endhighlight %}

There's not much more to it.
