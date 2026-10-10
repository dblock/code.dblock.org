---
layout: post
title: "The Second Life of Autoconf for MS-DOS"
date: 2026-09-27
tags: [vestris, nostalgia, dos]
---

Before GNU Autoconf generated `configure` scripts, there was a DOS program called Autoconf. It let you keep one `CONFIG.SYS` and one `AUTOEXEC.BAT`, then choose among boot configurations by pressing a key.

You did not have to wait for a menu. The PC BIOS kept early keystrokes in its keyboard queue, so you could press a configuration letter before `AUTOCONF.SYS` had even loaded. When the driver finally ran, it found the key and continued immediately.

I did not write the original. I copied its x86 assembly source by hand from a French computer magazine. It was the first assembly program I had ever seen and the first piece of code I compiled. I spent the next three or four years extending it into my first commercial product.

For a long time I could not remember who had written that first version. I had thrown away the magazine, forgotten the issue, and lost the trail before old print archives became easy to search. Only now, with AI helping sift through a large collection of scanned SVM issues downloaded from [Abandonware Magazines](https://www.abandonware-magazines.org/) and the [Internet Archive](https://archive.org/), was I able to find the seven pages I had copied.

## The Magazine

[![Cover of Science & Vie Micro issue 88, November 1991](/images/posts/2026/2026-09-27-the-second-life-of-autoconf-for-ms-dos/svm-88-cover-small.png)](/images/posts/2026/2026-09-27-the-second-life-of-autoconf-for-ms-dos/svm-88-autoconf-pages-227-233.pdf)

The original Autoconf appeared in the [November 1991 issue of *Science & Vie Micro*, number 88](https://archive.org/details/science-et-vie-micro-088), on pages 227–233. The article, [“La configuration idéale”](https://github.com/dblock/autoconf/blob/master/original/SVM-88-Autoconf-pages-227-233.pdf), was written by [Julien Pommier](http://gruntthepeon.free.fr/) and won the magazine's monthly programming contest, including a 2,000-franc prize.

The seven pages contained the complete assembly listings for `AUTOCONF.ASM` and the 11-byte `READCONF.COM`, installation instructions, sample startup files, and the commands required to build everything with MASM, LINK, and EXE2BIN.

I must have spent a week copying the listing without understanding what most of it did, correcting it character by character, and figuring out how to assemble it. I needed multiple boot configurations because I was tired of editing `CONFIG.SYS` whenever I wanted to play a game.

Thirty-five years later, Copilot and I transcribed the listings again and built them under DOS with JWasm. They produced a 1,180-byte `AUTOCONF.SYS` and the original 11-byte `READCONF.COM`.

Then the original program booted again.

![The original 1991 Autoconf selecting DOOM during an MS-DOS 5 boot](/images/posts/2026/2026-09-27-the-second-life-of-autoconf-for-ms-dos/autoconf-original-doom-boot.gif)

### Finding Julien

Once I knew his name, I sent Julien the article with a short question: “Is this you?”

He replied the next morning: “Yes it’s me 35 years ago!” He had searched for the article several times but had never found it. He also had no idea that the program had developed a life after its publication. He had no Internet access or BBS at the time, never heard about my fork, later forgot the program's name, and could not find it among all the results for the other Autoconf used by Linux software.

Being published in SVM had been a major moment of pride for him. Finding the article and the reconstructed history, he wrote, brought back “a whole chapter of my life.”

I told him that his program was the first code I had ever compiled and that it must have influenced my entire career. I had wanted to thank its author for decades, but I had thrown away the magazine and could no longer identify him. Old floppies and hard drives disappeared too, taking some of my own source snapshots with them.

Julien was reading the new [`HISTORY.md`](https://github.com/dblock/autoconf/blob/master/HISTORY.md) while we exchanged messages. Two people who had never met were finally comparing what the same small assembly program had meant to each of them.

### My Autoconf

![Autoconf banner advertising multiple configurations, assembly code, DOS, Windows 95, and freeware](/images/posts/2026/2026-09-27-the-second-life-of-autoconf-for-ms-dos/autoconf-banner.png)

I lived in Geneva from 1990 through 1999. My versions of Autoconf circulated mostly as ZIP archives on BBSs, beginning with Boris & Co. (`[Ne/V\eSiS]`), which operated from the basement of Infomaniak when it was still a computer store. The archives traveled alongside pirated software.

The compact magazine program grew into more than 7,000 lines of assembly. It gained named and nested configurations, a sorted menu, configuration previews, one-boot line editing, many keyboard layouts, searchable help, Windows 95 support, and `BOOTIT`, which could reboot directly into a chosen configuration.

There were also occasional small contributions from others. The full sequence of 145 recorded changes, command-line options, companion utilities, and source archaeology can be found in the [reconstructed project history](https://github.com/dblock/autoconf/blob/master/HISTORY.md).

The preserved later binary also boots under MS-DOS 5.

![The later Autoconf selecting DOOM during an MS-DOS 5 boot](/images/posts/2026/2026-09-27-the-second-life-of-autoconf-for-ms-dos/autoconf-doom-boot.gif)

The source and both preserved English and French binaries contain the same build string:

```text
assembl.: 11/01/96 (14:26)
```

That dates the surviving Autoconf 3.00 beta 2 build to January 11, 1996 at 14:26.

### MegaBoot

The same search uncovered another program. A friend of mine, David, wrote MegaBoot in 1996 while we spent time in the basement of Infomaniak in Carouge, Switzerland.

MegaBoot was a spiritual successor to Autoconf: another DOS character-device driver that rewrote the in-memory `CONFIG.SYS`, but with a full-screen menu. I restored the source, made it build with JWasm, fixed two recovered bugs, and booted it under MS-DOS 5.

![MegaBoot selecting DOOM during an MS-DOS 5 boot](/images/posts/2026/2026-09-27-the-second-life-of-autoconf-for-ms-dos/megaboot-doom-boot.gif)

David granted MegaBoot an MIT license. It now has its own repository at [`dblock/megaboot`](https://github.com/dblock/megaboot).

### What Happened to It

MS-DOS 6.0 added native multiple configurations in 1993. Autoconf did not disappear immediately; development continued through the January 1996 beta, and it still offered many things DOS did not.

Here is the same Minimal DOS, DOOM, and Windows 95 setup implemented with the native MS-DOS 6.22 startup menu.

![MS-DOS 6.22 selecting DOOM with its native multiple-configuration menu](/images/posts/2026/2026-09-27-the-second-life-of-autoconf-for-ms-dos/msdos622-multiconfig.gif)

Autoconf faded later. By the time software distribution moved from BBSs to the Internet, I had not moved the project with it, some of its source had been lost, and DOS already had a built-in solution. A separate boot-configuration product was no longer necessary.

The original and later Autoconf sources now live together in [`dblock/autoconf`](https://github.com/dblock/autoconf). MegaBoot lives in [`dblock/megaboot`](https://github.com/dblock/megaboot). Most importantly, I finally found Julien and got to say thank you.

### Links

- [Autoconf source and reconstructed history](https://github.com/dblock/autoconf)
- [MegaBoot source](https://github.com/dblock/megaboot)
- [Original November 1991 SVM article and source listing](/images/posts/2026/2026-09-27-the-second-life-of-autoconf-for-ms-dos/svm-88-autoconf-pages-227-233.pdf)
- [Complete SVM issue 88 on Internet Archive](https://archive.org/details/science-et-vie-micro-088)
- [My 2011 post about Autoconf](https://code.dblock.org/2011/09/06/autoconf-maybe-the-first-example-of-microsoft-pushing-features-into-the-os-to-kill-a-competitor.html)
