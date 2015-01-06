---
layout: post
title: "Non-Traditional Methods of Choosing Technology for a Software Project"
redirect_from: "/non-traditional-methods-of-choosing-technology-for-a-software-project"
date: 2011-07-06 14:15:03
tags: [technology]
comments: true
---
Yesterday I gave a [talk on choosing technology for a software project](/slides-from-choosing-technology). I argued that building software is unlike building rockets, toasters or power plants. This was very well received and the audience gave plenty of examples to support my thesis. I then described the traditional approaches of choosing technology: picking a stack, a framework and considering scalability, complexity, cost, etc. You make a spreadsheet and fill the little boxes. It was a necessary and boring introduction.

Finally, the part that had my classroom most engaged was about non-traditional methods.

#### Flipping a Coin

![]({{ site.url }}/images/posts/2011/2011-07-06-non-traditional-methods-of-choosing-technology-for-a-software-project/image_2.jpg)

Most experienced engineers that I get a chance to talk to believe that traditional approaches yield about the same quality of results as flipping a coin. Committee-type technology decisions that evaluate many angles often make poor choices that produce average outcomes. For instance, after eliminating all the dumb and inapplicable choices for a web project, can you really choose between Ruby-on-Rails, Pythonon-Django or Lift-on-Scala? It’s a matter of preference and experience and good developers can make almost any of these work.

Flip a coin. See which way the wind blows.

#### Developer Happiness

![]({{ site.url }}/images/posts/2011/2011-07-06-non-traditional-methods-of-choosing-technology-for-a-software-project/image_5.jpg)

What makes developers happy? Large engineering organizations tend to believe that it’s ping-pong tables and free pizza. They are wrong. Engineers like to make their own choices, love to work on cutting edge technology, solving really hard problems. They like when their brains stream code. Your project can easily achieve all these goals by putting developer happiness on the top of the decision-making stack and by demonstrating trust in choices made by the hard-working individual contributors. Sometimes technology managers can (and must) help make those happy choices.

```
- Bob, what technology would you like to use for project X?
- I’m comfortable with Java since I’ve been doing it for the last 100 years.
- Bob, would you like to try Scala instead?
- Wow! Yes!
```

You now have an energized engineer that feels ownership and has a little taste of the risky and unknown. He’s going to work twice as hard and inspire others.

#### Bullet Proof Logic

![]({{ site.url }}/images/posts/2011/2011-07-06-non-traditional-methods-of-choosing-technology-for-a-software-project/image_8.jpg)

Instead of flipping a coin we can use simple logic that has nothing to do with technology per-se. For example, you can choose something that worked for you before. It’s a safe bet. You can pick a different framework from one that worked for you because you want to try something new, making things a bit exciting. Finally, you can choose technology because someone else uses it for a tangent problem space.

We knew we needed a NoSQL database. So we picked [MongoDB](http://mongodb.org) because [Foursquare](http://foursquare.com) uses. It also happened that [10gen](http://10gen.com), the company behind MongoDB was two blocs away and we had a chance to meet with some really smart people that work there. But frankly, at the moment of that decision we had no technical reason for picking MongoDB out of the dozens of NoSQL databases on the market. In fact, many could have easily demonstrated better reliability and scalability. Strangely, we haven’t regretted this choice - it just felt right and continues to feel so today.

#### Iterative and Pragmatic

![]({{ site.url }}/images/posts/2011/2011-07-06-non-traditional-methods-of-choosing-technology-for-a-software-project/image_11.jpg)

My most frequent approach to choosing technology is a pragmatic one. I encourage my team to try anything, iterate on it and decide to keep or toss something later, once we know better. For example, [Gib](http://blog.shortforgilbert.com/) just tried [Sugarskull](https://github.com/hij1nx/SugarSkull) on a 30-second pitch by [hij1nx](http://twitter.com/hij1nx). He spent a couple of days replacing Backbone.js routes with it and was jazzed to do it. Sugarskull just came out of the oven, still steaming hot! Right now it feels amazing, but none of us have any idea whether this was an excellent choice or a decision that will run the project into the ground.

The pragmatic approach means making choices based on these criteria.

- Easy to Learn and Put to Use
- Frustration-less and Fitting
- Has a Growing and Vibrant Community
- Provides Elegant Solutions to Messy Problems

What do you think? How do you make your technology choices?

