---
layout: post
title: "A 1998 PDF-to-Text Converter"
date: 2026-10-09
tags: [ai, nostalgia, open-source, c++]
---

In 1998 I needed to convert PDF files to text for a search engine called Alkaline, without requiring separately installed libraries. So I wrote a C++ parser. Alkaline is another story.

I recovered the source from a backup dated December 26, 1998. It reads PDF 1.0 through 1.2, follows object references and page trees, decompresses content with bundled zlib, and prints metadata, page text and bookmark titles. There are my own string, vector and hash-table libraries in there too. The encryption code is a stub. This was a work in progress.

I wasn't reverse engineering an undocumented format. Adobe had [published the specification in 1993](https://www.adobe.com/accessibility/pdf.html), and my comments refer to the PDF Reference, right down to a page number for stream filters. This predates tagged PDF, introduced in 2001. Getting text meant interpreting page drawing commands, not following a tagged reading order.

I was very impressed by how clever the format was. You start near the end, find the cross-reference table, and use its byte offsets to jump straight to the objects you need. A page points to its content and resources, so the reader follows those references rather than parsing the whole file from beginning to end. You don't have to read the entire document to render one page.

GitHub Copilot CLI and I made it build again as a C++17 port, keeping the parsing approach but replacing the old containers with the standard library and using system zlib. The original is preserved unchanged. The port fixes binary stream lengths, line endings and several text operators, but it still targets those old PDF versions. Don't point it at a modern PDF and expect miracles.

![The restored PDF reader converting a sample document to text](/images/posts/2026/2026-10-09-a-1998-pdf-to-text-converter/pdfreader.gif)

The [source and port are on GitHub](https://github.com/dblock/cplusplus-pdf-reader), under the MIT license.
