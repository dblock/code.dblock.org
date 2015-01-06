---
layout: post
title: "N queens puzzle: a scheme and x86 assembly solution"
redirect_from: "/n-queens-puzzle-a-scheme-and-x86-assembly-solution/"
date: 2009-09-22 19:00:00
tags: [scheme]
comments: true
---
The **eight queens puzzle** is the problem of putting eight chess queens on an 8×8 chessboard such that none of them is able to capture any other using the standard chess queen's moves. The queens must be placed in such a way that no two queens would be able to attack each other. Thus, a solution requires that no two queens share the same row, column, or diagonal. The eight queens puzzle is an example of the more general **_n_ queens puzzle** of placing _n_ queens on an _n_×_n_ chessboard, where solutions exist only for _n_ = 1 or _n_ ≥ 4.

[http://en.wikipedia.org/wiki/Eight_queens_puzzle](http://en.wikipedia.org/wiki/Eight_queens_puzzle)

I dug up some [old code](https://github.com/dblock/reines) that implemented the puzzle solution(s) in scheme and x86 assembly.

- [Scheme Source](https://github.com/dblock/reines/blob/master/REINES.S)
- [x86 Assembly Source, Base Algorithm](https://github.com/dblock/reines/blob/master/REINEONE.ASM)
- [x86 Assembly Source, All Optimizations](https://github.com/dblock/reines/blob/master/REINES.ASM)
- [x86 Executable](https://github.com/dblock/reines/raw/master/REINES.EXE)

I remember trying to get solutions for large (over 10) boards in 1995 and my PC was a little slow. Things are very different today. Here's an example of solution number 128570 for a board of 20.

```
(128570) 11 1 3 5 12 2 15 13 18 14 4 6 19 16 10 7 20 8 17 9
```



