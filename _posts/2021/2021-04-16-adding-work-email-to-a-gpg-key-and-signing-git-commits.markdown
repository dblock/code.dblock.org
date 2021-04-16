---
layout: post
title: Adding Work E-Mail to a GPG Key and Signing Git Commits
date: 2021-04-16
tags: [git, gpg, security, privacy]
comments: true
---
Last week I joined the [OpenSearch Team](https://opensearch.org/) at AWS, a community-driven, open source fork of Elasticsearch and Kibana (read more about it [here](https://aws.amazon.com/blogs/opensource/introducing-opensearch/)).
 
Security is always our top priority at AWS, so I had to learn some new development best practices in this area. One of my colleagues, and Apache contributor [@nknize](https://github.com/nknize) has been signing his commits with GPG. I decided to add my work e-mail address to my existing GPG key, and setup git signing as well.

### Generating Keys

If you don't already have a key, install [gpg2](https://gnupg.org/download/) (e.g. `brew install gpg`), and follow the instructions in [this doc](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-gpg-key). It will tell you to run `gpg --full-generate-key`. 

You can list keys with `gpg --list-secret-keys --keyid-format LONG` and note the key ID.

{% highlight bash %}
gpg --list-secret-keys --keyid-format LONG
/Users/dblock/.gnupg/pubring.kbx
--------------------------------
sec   rsa2048/75BF031B7C94E183 2013-12-24 [SC]
      4A720FE790B07A68744E371675BF031B7C94E183
uid                 [ultimate] Daniel Doubrovkine <dblock[at]dblock.org>
{% endhighlight %}

In my example the key ID is `75BF031B7C94E183`.

### Backing up Keys

I export and store a copy of my GPG keys in Dropbox and store the private key passphrase in 1Password. The latter is required to export or import a private key (gpg will prompt you). 

{% highlight bash %}
gpg --export-secret-key 75BF031B7C94E183 > 75BF031B7C94E183.gpg
{% endhighlight %}

### Adding my Work E-Mail

I only have one identity, but multiple e-mails. I decided to add my work e-mail to my GPG key (YMMV) as explained [here](https://docs.github.com/en/github/authenticating-to-github/associating-an-email-with-your-gpg-key).

{% highlight bash %}
gpg --edit-key 75BF031B7C94E183

$ gpg> adduid

# follow prompts, finish with `save`

{% endhighlight %}

My key now has both my personal and work e-mail addresses.

{% highlight bash %}
$ gpg --list-secret-keys --keyid-format LONG
/Users/dblock/.gnupg/pubring.kbx
--------------------------------
sec   rsa2048/75BF031B7C94E183 2013-12-24 [SC]
      4A720FE790B07A68744E371675BF031B7C94E183
uid                 [ultimate] Daniel Doubrovkine <dblock[at]amazon.com>
uid                 [ultimate] Daniel Doubrovkine <dblock[at]dblock.org>
ssb   rsa2048/960955779E55310A 2013-12-24 [E]

{% endhighlight %}

I then exported the public key with `gpg -a --export 3AA5C34371567BD2` and [added it to my Github account](https://docs.github.com/en/articles/adding-a-new-gpg-key-to-your-github-account).

### Signing Git Commits

I wanted to enable commit signing globally to avoid having to constantly appenad `-S` to `git commit`, and [added the following settings to my dotfiles](https://github.com/dblock/dotfiles/commit/073adde3335182ce33625951c84a8431adea8256).

{% highlight bash %}
# make GPG work
export GPG_TTY=$(tty)

# use my key to sign all commits
git config --global user.signingkey 75BF031B7C94E183
# automatically sign all commits
git config --global commit.gpgsign true
{% endhighlight %}

### Checking it Out

Commit signatures appear in `git log --show-signature`.

{% highlight bash %}
~/source/dotfiles (master)$ git log --show-signature -1
commit 073adde3335182ce33625951c84a8431adea8256 (HEAD -> master, origin/master, origin/HEAD)
gpg: Signature made Thu Apr 15 18:19:41 2021 EDT
gpg:                using RSA key 4A720FE790B07A68744E371675BF031B7C94E183
gpg: Good signature from "Daniel Doubrovkine <dblock[at]amazon.com>" [ultimate]
gpg:                 aka "Daniel Doubrovkine <dblock[at]dblock.org>" [ultimate]
Author: dblock <dblock[at]amazon.com>
Date:   Thu Apr 15 18:19:41 2021 -0400

    Installing GPG keys.
{% endhighlight %}

And you can see a nice icon next to verified commits on GitHub!

![verified]({{ site.url }}/images/posts/2021/2021-04-16-adding-work-email-to-a-gpg-key-and-signing-git-commits/verified.gif)

Now, how do I get verified [on Twitter](https://twitter.com/dblockdotorg)?!