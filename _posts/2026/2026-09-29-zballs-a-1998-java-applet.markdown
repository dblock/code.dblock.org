---
layout: post
title: "zBalls: a 1998 Java Applet"
date: 2026-09-29
tags: [ai, java, open-source, nostalgia]
---

In January 1998, a classmate and I wrote a game. It was called "Bolongas zBalls", and it was a Java applet.

<video controls preload="metadata" width="350" style="display: block; margin-bottom: 1.5em;" poster="/images/posts/2026/2026-09-29-zballs-a-1998-java-applet/zballs.png">
  <source src="/images/posts/2026/2026-09-29-zballs-a-1998-java-applet/zballs.mp4" type="video/mp4">
</video>

You click to start, then move the mouse, without clicking. Touch the dark ball to blow it up, and the next ball turns dark. Clear them all and the next level doubles the number of balls. Touch a plain ball and it spawns another one, so if you're sloppy, the balls multiply until you lose. Each level has a time limit.

The intro music is the theme song from Capitaine Flam, the French version of the Japanese cartoon Captain Future, which aired on TF1 in 1981. I honestly don't remember why we used it, nor why the game is called "Bolongas".

Applets were removed in [JDK 26](https://openjdk.org/jeps/504), which is a shame, because a gray box that froze your browser for ten seconds and then asked you to trust a stranger's code was clearly the future of the web.

You can find the source [on GitHub](https://github.com/dblock/zballs) and play the game [here](https://dblock.github.io/zballs/).
