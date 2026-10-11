---
layout: post
title: "ELPDS: Inspecting FAT Partitions in 1995"
date: 2026-10-11
tags: [ai, nostalgia, open-source, c++, dos, licensing]
---

I recovered another program I wrote in 1995: [`ELPDS`](https://github.com/dblock/elpds), or Enhanced Logical & Physical Drive Status. Run `ELPDS C:` and it reports physical disk geometry, partition entries, FAT boot-sector details, and free space. It doesn't change anything on the disk. My help says it was for checking whether a partition existed and was formatted. I think I was just trying to learn about the underlying partition mechanics.

![ELPDS inspecting a FAT16 demo disk in DOSBox-X](/images/posts/2026/2026-10-11-elpds-a-1995-dos-disk-inspection-tool/elpds-dosbox.png)

I didn't write all of it. The help credits "Mr. Schaeffer" for a "huge part of FIPS code." That was Arno Schaefer, whose name I misspelled. FIPS could split a FAT partition without deleting its files, often to make room for Linux. Comparing my code with the [archived FIPS source](https://web.mit.edu/ghudson/sipb/fips/logdr_st.cc) found nearly identical boot-sector parsing, disk geometry routines, and even comments. I had turned its disk-reading machinery into a standalone status tool.

GitHub Copilot CLI and I made a separate DOS port using Open Watcom, leaving the original source and executable unchanged. It runs in DOSBox-X against a disposable FAT16 disk image: 16 heads, 63 sectors per track, 65 cylinders, and about 32 MiB. We fixed decoding and error handling, but this is still a tool for old DOS disks, not modern ones.

The [source, port, and build instructions are on GitHub](https://github.com/dblock/elpds). FIPS was GPL version 2 or later, so ELPDS is too. Thirty-one years later, I finally got the author's name and the license right.
