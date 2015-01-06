---
layout: post
title: "Toyota Production System & Why Should Architects Write Code"
redirect_from: "/toyota-production-system-why-should-architects-write-code/"
date: 2012-02-12 16:05:14
tags: [technology, architecture]
comments: true
---
![toyota]({{ site.url }}/images/posts/2012/2012-02-12-toyota-production-system-why-should-architects-write-code/toyota_7.jpg)

I recently read ["The Darker Side of Lean"](http://astro.temple.edu/~rmudambi/Teaching/BA951/Week_04/Toyota-Darker-Side-Mehri.pdf) by Darius Mehri. It is a fascinating account of the evil aspects of the much celebrated Toyota Production System. The author of the paper is a mechanical engineer. Yet, the way he describes Japanese approach to choosing technology struck me as déjà vu.

> _To arrive at the best design, the engineers would gather huge amounts of information, comparing new designs with previous designs. If the technology unearthed by their research could benefit the product in any way, they would include it in the many alternatives they were considering. Sobek, Ward and Liker’s research compare Toyota’s approach to product development as set-based design where "designers think and reason about sets of design alternatives. Over time, these sets are gradually narrowed as the designers eliminate inferior alternatives until they find a final solution." They claim this method differs from the conventional practice of choosing a single design early on and iterating to improve it until a solution is obtained._

We often think of software architects as experienced developers whose job is to consider all aspects of a future system, including scalability and performance. At extremes this causes architects to lock themselves in a room for days and think about all possible alternatives by making long lists or drawing endless architecture diagrams. Vendors are invited and feature matrices are compared. It’s a very similar process to the one described in this paper, heavily adopted by the Enterprise.

A simple solution is to ensure that architects write code, at least 40% of their time. This forces us to _"choose a single design early and iterate to improve it"_. The consequences are felt first hand. And when we feel pain with our own skin, we know when it’s time to throw out a component, technology or system and when to go back to the drawing board.
