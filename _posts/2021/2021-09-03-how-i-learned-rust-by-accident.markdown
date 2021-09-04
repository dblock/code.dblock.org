---
layout: post
title: How I Learned Rust by Accident
date: 2021-09-03
tags: [learning, rust]
comments: true
---
I had to quickly ramp up my Python over [the past few weeks](https://github.com/opensearch-project/opensearch-build/pulls?q=is%3Apr+is%3Aclosed+author%3Adblock). Mind, because Ruby is obviously better, I've never really written any Python in 20 years of programming. At least not production-grade Python with unit tests. Working on a real active codebase was the easiest and fastest way for me to learn, but I'm not telling you anything you didn't already know.

Then yesterday, I accidentally "learned" Rust. I'm, obviously, still a total Rust noob, but at least now I know what [Cargo and TOML](https://doc.rust-lang.org/cargo/reference/manifest.html) are, and I think I'm getting just sufficiently dangerous with it. Here's the full story.

The OpenSearch project uses a link checker called [lychee](https://github.com/lycheeverse/lychee) to ensure that links in the OpenSearch markdown docs work. The tool is open-source, and is written in [Rust](https://www.rust-lang.org/). Yesterday, the [icu-project.org](http://icu-project.org/) website became a redirect, causing the link checker to [fail](https://github.com/opensearch-project/OpenSearch/issues/1199), blocking CI.

I started fixing CI by adding `icu-project.org` to the list of websites to exclude, and noticed that the GitHub action code that ran the link checker was already excluding a long list of URLs with `--exclude=website1 --exclude=website2 --exclude=...`. I read the Lychee documentation to see if it supported exclusion lists that could be stored in files. It didn't, so I opened [a feature request](https://github.com/lycheeverse/lychee/issues/302). I was [pointed](https://github.com/lycheeverse/lychee/issues/302#issuecomment-909599246) to the fact that Lychee supported config files, but I would still have to put exclusions into a long list.

CI couldn't wait, but I was still not going to add a URL to a very long command-line. I devised a hack, and put the list of websites into a `.lycheeexclude` file, loaded the file into an environment variable with `LYCHEE_EXCLUDE=$(sed -e :a  -e 'N;s/\n/ /;ta' .lycheeexclude)` inside the GitHub action code, used it with {% raw %}`--exclude ${{ env.LYCHEE_EXCLUDE }}`{% endraw %}, and PRed this in [OpenSearch#1189](https://github.com/opensearch-project/OpenSearch/pull/1189) and [OpenSearch#1201](https://github.com/opensearch-project/OpenSearch/pull/1201).

I decided to add the `--exclude-file` feature to Lychee and began by checking out Lychee code and tried to build it. After minimal Internet reading I learned that one needed [rustup](https://rustup.rs/) to get started, as opposed to just installing Rust. I added that to the [Lychee README](https://github.com/lycheeverse/lychee/blob/master/README.md#contributing-to-lychee) for the next noob like me, and was able to run tests with `cargo test`.

The CI code linter was now complaining, so [I fixed all](https://github.com/lycheeverse/lychee/commit/c5d75447cad2a665e9bb126f2a04090ebd6df7f5) but [one problem](https://github.com/lycheeverse/lychee/pull/304#issuecomment-911603614) and [asked for help](https://github.com/lycheeverse/lychee/pull/304#issuecomment-912158085). I was now able to run `cargo clippy` and get a clean code lint.  

I finally copy-pasted code from the existing `--exclude` implementation into similarly looking code for  `--exclude-file`, copy-pasted more code from Stack Overflow to read a file line-by-line, [wrote some missing tests for the existing](https://github.com/lycheeverse/lychee/pull/306#discussion_r701921275) `--exclude` feature, added tests for the new `--exclude-file`, then [submitted a pull request](https://github.com/lycheeverse/lychee/pull/306). With my fixes above, CI was passing, except for a publish check.

It took me a while to comprehend that Lychee is actually a library called `lychee-lib` and a binary called `lychee-bin`, and that the publish check was trying to dry-run publishing the lib first, then the binary. The publishing dry-run was failing with an unresolved import, `error[E0432]: unresolved import lychee_lib::collector::Collector`. Ths looked suspicious, as the `Collector` code was recently added, breaking CI. I figured that the dry-run of the binary publication was picking up the previously released version of the lib, and not the current one. Incrementing the version in the source code of both the lib and the binary made this even more obvious as the publication dry-run couldn't find the new version of the lib.

I Googled the problem, and discovered [cargo-publish-all](https://crates.io/crates/cargo-publish-all) that was designed to address this exact scenario. However, that [failed](https://github.com/idanarye/rust-typed-builder/issues/57) with an obscure `error[E0433]: failed to resolve: use of undeclared crate or module proc_macro` that came from `rust-typed-builder`, and has been [an open issue for over a year](https://gitlab.com/torkleyy/cargo-publish-all/-/issues/3). The error made no sense to anyone, but the maintainer of rust-type-builder was able to come up with [a workaround](https://github.com/idanarye/rust-typed-builder/issues/57#issuecomment-912802451). A new version of that library, 0.9.1, was also cut.

I made a [final pull request](https://github.com/lycheeverse/lychee/pull/309) to the publish workflow and CI went back to green!

To summarize, Lychee now has a `--exclude-file` feature, and a working CI, while I got to learn Rust pretty much by accident. This would have never happened had I not be working in open-source by default. Oh, and it helped to be a bit persistent and not giving up on each one of the problems encountered above.

Similar accidents have generated defining moments in my career. Will I end up writing Rust full time one day? We shall see!




