---
layout: post
title: To Wrap or not to Wrap in Markdown?   
date: 2021-06-07
tags: [markdown, oss]
comments: true
---
I keep antagonizing OSS contributors trying to wrap text in Markdown files, e.g. [here](https://github.com/opensearch-project/OpenSearch/pull/689#issuecomment-839241016) and [here](https://github.com/opensearch-project/OpenSearch/pull/712#issuecomment-855271225). 

Should one wrap text in .markdown files at 80 columns or should one not?

First, let me say that I don't care. Except that I do. Wrapped text in markdown really feeds my OCD in the worst possible way, right behind missing periods at the end of sentences, and two spaces. Oddly, I don't care about tabs vs. spaces.

Here's a logical argument for _not wrapping_ text in markdown.

Markdown doesn't use line the breaks: whether you include a line break in your markdown or not the rendered result is the same, unless you use 2 line breaks.

For example, the following old text

```
A quick brown fox jumps 
over the lazy dog.
```

is replaced with the following new text

```
The quick brown fox 
jumps over a lazy dog.
````

This has somehow become a 2-line change. Pain and suffering.

Instead, the change would have looked as follows.

```
>A quick brown fox jumps over the lazy dog.
<The quick brown fox jumps over a lazy dog.
```

So much easier to grok, isn't it?

GitHub does a great job at the diff, compare:

The quick brown fox 
jumps over a lazy dog.

The quick brown fox jumps over a lazy dog.