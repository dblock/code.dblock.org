---
layout: post
title: "Mapping and Tiling on iOS"
redirect_from: "/mapping-and-tiling-on-ios/"
date: 2014-03-19 14:44:16
tags: [ios, art.sy, open source]
comments: true
---
I’ve learned a great deal about iOS UI in the past couple of months, mostly working on the [Artsy Mobile app](http://iphone.artsy.net/) and the in-Fair experience for the [New York Armory Show](http://iphone.artsy.net/). I feel incredibly lucky to have [Orta](http://orta.github.io/) from CocoaPods fame sitting a few feet away and being a patient mentor. We’ve built a map that, unlike many similar indoor maps, actually doesn’t suck. Huge kudos to [KatarinaBatina](http://www.katarinabatina.com/), who did a ton of design work and everybody else at Artsy who has contributed boatloads of client and server-side code to make this happen.

A few open-source projects came out of this. I’ve extracted the image zoom portion into [ARTiledImageView](https://github.com/dblock/ARTiledImageView). It’s capable of displaying really large images at multiple zoom levels that you can tile with another really simple command-line tool, [dzt](https://github.com/dblock/dzt). This has been long available on the web [OpenSeaDragon](http://openseadragon.github.io/), and is now at your fingertips on iOS. The second library is [NAMapKit](https://github.com/neilang/namapkit). It’s a really simple framework that combines an image and map annotations. We’ve hacked on it heavily and I’ve spent a couple of weeks refactoring its code to enable a clean way of supporting multiple map types, including ones backed by tiled images. Finally, shout out to [ios-snapshot-test-case](https://github.com/facebook/ios-snapshot-test-case) and [ios-snapshot-test-case-expecta](https://github.com/dblock/ios-snapshot-test-case-expecta), which make testing of all this UI stuff a breeze.

![](https://raw.github.com/wiki/neilang/NAMapKit/demos/artsy-iphone-app-armory-2014.gif)
