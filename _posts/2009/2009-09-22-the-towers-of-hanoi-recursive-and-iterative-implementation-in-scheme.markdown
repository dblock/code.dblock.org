---
layout: post
title: "The Towers of Hanoi: recursive and iterative implementation in Scheme"
redirect_from: "/the-towers-of-hanoi-recursive-and-iterative-implementation-in-scheme/"
date: 2009-09-22 19:00:00
tags: [scheme]
comments: true
dblog_post_id: 51
---
Legend has it that a group of Eastern monks are the keepers of three towers on which sit 64 golden rings. Originally all 64 rings were stacked on one tower with each ring smaller than the one beneath. The monks are to move the rings from this first tower to the third tower one at a time but never moving a larger ring on top of a smaller one. Once the 64 rings have all been moved, the world will come to an end.

It seems that the "Towers of Hanoi" puzzle was actually invented from scratch probably together with the accompanying legend only in 1883 by the French mathematician Edouard Lucas. At least there is no known written record about the puzzle or the legend prior to 1883 [> Read More](http://hanoitower.mkolar.org/)  [> Original Puzzle Instructions](http://www.cs.wm.edu/~pkstoc/toh.html)

I dug up an implementation in scheme. There's the classic recursive method. But my classmate Radu Stancu came up (independently) with an iterative implementation. This is from 1995.

The iterative method is based on how disks move. There's a number of 2^n - 1 steps to do where n is the number of disks. This can be proven by recurrence. Each disk moves the same way all the time:

- disk 3 in a 3 disks' case will move by 2 all the time
- disk 2 will move by 1 all the time (one step rotation)
- disk 1 will move by 2 all the time (two steps rotation)

With an example of 3 disks containing the disk number you move and knowing the step "length", you can easilly see that all the information for the move is included in the move number itself! This is just the general idea.

- [Source Code](https://github.com/dblock/hanoi)



