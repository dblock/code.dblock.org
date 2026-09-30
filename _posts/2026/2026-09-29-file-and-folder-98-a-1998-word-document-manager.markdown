---
layout: post
title: "File & Folder 98: a 1998 Word Document Manager"
date: 2026-09-29
tags: [ai, open-source]
---

In the 1990s I wrote a document manager for a small business in Geneva with about 20 workstations. Most of its staff were new to computers, and folders were a challenging idea to grasp. They saved Word documents wherever Word happened to put them, and the network supervisor spent his days looking for lost files by panicked coworkers. File & Folder solved that problem. My 1999 product page said it was for "a small business which is sick and tired of seeing it's workers putting documents a bit everywhere in the system."

The first version, File & Folder 1.0, was a Visual Basic app for Windows 3.11. It sold as shareware for US$75.

![File & Folder 1.0](/images/posts/2026/2026-09-29-file-and-folder-98-a-1998-word-document-manager/ff10-main.png)

A 32-bit version for Windows 95 and NT, File & Folder 1.2, followed in 1996. It worked in one root folder with numbered subfolders, supposedly one per client or case number. You typed a number, and it listed the Word documents in that folder, or offered to create one. It drove Word over OLE automation to open and create documents. The source, the Word stand-in and the scripts to run it are [on GitHub](https://github.com/dblock/ff95).

In 1998 I attempted to generalize the idea and rewrote File & Folder from scratch in Delphi 3 as File & Folder 98. It replaced drives and directories with virtual volumes, simplifying the file system navigation into a layout that an administrator could choose. Under a volume, a folder held either documents or other folders, never both. Users created, opened, copied, moved and renamed Word documents within this one window, without needing to use the Word file dialogs. The tool also offered document previews.

![File & Folder 98 splash screen, Stolen Technologies](/images/posts/2026/2026-09-29-file-and-folder-98-a-1998-word-document-manager/ff98-splash-stolen.png)

![File & Folder 98 splash screen, Vestris](/images/posts/2026/2026-09-29-file-and-folder-98-a-1998-word-document-manager/ff98-splash-vestris.png)

![File & Folder 98 running under Wine on macOS](/images/posts/2026/2026-09-29-file-and-folder-98-a-1998-word-document-manager/ff98.gif)

File & Folder 98's original source, the port, the build scripts are [on GitHub](https://github.com/dblock/ff98).
