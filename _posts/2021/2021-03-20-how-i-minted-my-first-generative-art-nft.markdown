---
layout: post
title: "How I Minted My First Generative Art NFT"
date: 2021-03-20
tags: [nft, art, drawing, generative art]
comments: true
---
I've long watched my inspiring friends make generative art and mint NFTs. I own a handful of works on paper by [Dmitri Cherniak](https://linktr.ee/dmitricherniak), and we've [briefly collaborated in 2019](https://www.instagram.com/p/BtuX53IHMBx/) - Dmitri made digital works, and I drew a smaller set inspired by his output. I really enjoyed observing his process, and thought about trying making digital drawings myself, but then I stubbornly stuck to making my own works on paper. Dmitri's recent success with [Ringers](https://opensea.io/assets/art-blocks?search%5BstringTraits%5D%5B0%5D%5Bname%5D=Ringers&search%5BstringTraits%5D%5B0%5D%5Bvalues%5D%5B0%5D=All%20Ringers) selling at crazy prices was not overnight. He has long made, and believed in generative art, he's a true artist that doesn't care much about commercial success. Nevertheless, the $ outcomes are worthy of a mention, his art is now being recognized by collectors outside of the traditional gallery system.

Last week, after listening to a conversation with [Osinachi](https://twitter.com/osinachiart), an incredibly inspiring Nigerian artist that has been minting NFTs for a while, I finally decided to give generative art NFTs a go.

You can buy one of the works [here](https://opensea.io/collection/generative-sanguines), until they sell out. **Update**: works 1-6 have sold as of March 24th, 2021.

![](https://raw.githubusercontent.com/dblock/p5art/master/shape.gif)

Here's the technicalities of how I minted my first NFTs.

1. I started with [p5-typescript-starter](https://github.com/Gaweph/p5-typescript-starter), including [fixing a typo](https://github.com/Gaweph/p5-typescript-starter/pull/14).
2. Found inspiration in my own [existing paper drawing](https://www.instagram.com/p/B9etMYGnMQ3/).
3. Reproduced the sanguine (`color('#850505')`) shape [in code](https://github.com/dblock/p5art/blob/master/sketch/sketch.ts#L28), using `quad`.
4. Animated 10 frames and saved them to files using `saveCanvas`.
5. Created [a collection on OpenSea](https://opensea.io/collection/generative-sanguines). Each work is a unique result of a different frame.
6. Bought $200 worth of ETH on Coinbase, and moved it to OpenSea to pay gas on some wallet initialization process.
7. Listed [work 1/10](https://opensea.io/assets/0x495f947276749ce646f68ac8c248420045cb7b5e/48718886585399041049872855307944290111042886289234588241181420742469385977857) in an auction, and sold my first NFT to my first bidder, someone I don't know!
8. In hindsight listing as an auction was a mistake because the seller ends up paying gas fees, which are high, at about $50 per transaction. I have since listed, and sold, works 2-6 as "buy now" for a fixed price. Buyer pays gas fee for those to complete.
