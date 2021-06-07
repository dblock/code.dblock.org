---
layout: post
title: To Wrap or Not to Wrap in Markdown?   
date: 2021-06-07
tags: [markdown, oss]
comments: true
---
I keep antagonizing OSS contributors trying to wrap text in Markdown files, e.g. [here](https://github.com/opensearch-project/OpenSearch/pull/689#issuecomment-839241016) and [here](https://github.com/opensearch-project/OpenSearch/pull/712#issuecomment-855271225). 

Should one wrap text in .markdown files at 80 columns or should one not?

First, let me say that I don't care. Except that I do. Wrapped text in markdown really feeds my OCD in the worst possible way, right behind missing periods at the end of sentences, and two spaces. Oddly, I don't care about tabs vs. spaces.

Here's a logical argument for _not wrapping_ text in markdown.

Markdown doesn't use line the breaks: whether you include a line break in your markdown or not the rendered result is the same, unless you use 2 line breaks.

For example, consider the following text wrapped at 23 characters for illustration purposes.

```
A quick brown fox jumps 
over the lazy dog.
```

We swap "a" and "the", producing the following new text.

```
The quick brown fox 
jumps over a lazy dog.
````

Because of a line wrap, this 2-word change is now a 2-line change. It hurts.

Without the wrap the diff would have been super clean.

```
>A quick brown fox jumps over the lazy dog.
<The quick brown fox jumps over a lazy dog.
```

Furthermore, GitHub [does an even better job at the 1-line diff](https://github.com/dblock/code.dblock.org/commit/99a4948a737ef21bf4025f3faa5b6167410e3de8).

![diff]({{ site.url }}/images/posts/2021/2021-06-07-to-wrap-or-not-to-wrap-in-markdown/diff.png)

Notice how the word "jumps" was highlighted, even though it wasn't actually changed.

For an argument _for_ wrapping text, see [this comment](https://github.com/opensearch-project/OpenSearch/pull/712#issuecomment-855271225).