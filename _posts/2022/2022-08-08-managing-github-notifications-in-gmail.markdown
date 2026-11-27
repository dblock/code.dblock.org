---
layout: post
title: Managing GitHub Notifications in GMail
date: 2022-08-08
tags: [github, email]
---
My e-mail inbox is flooded with GitHub notifications, just like yours.

Having tried half a dozen ways to get a queue of notifications, I settled on creating a filter and use it to label the email, and remove it from the inbox, the first time I receive a new notification for a repo I am subscribed to on GitHub.

<img src="{{ site.url }}/images/posts/2022/2022-08-08-managing-github-notifications-in-gmail/rules.gif" />

Then I check those emails in bulk and never miss anything.

<img src="{{ site.url }}/images/posts/2022/2022-08-08-managing-github-notifications-in-gmail/labels.gif" />

So, as you can see, with hundreds of labels, the GMail sidebar became unusable. I wrote [gmail-toggle](https://github.com/dblock/gmail-toggle), a Chrome extension that hides the labels, categories, and messages you've already read with one click. Install it from the [Chrome Web Store](https://chromewebstore.google.com/detail/toggle-categories-and-lab/ckejkcopppahbffilefogkmhcgepmnog).

<video controls preload="metadata" width="100%" style="display: block; margin-bottom: 1.5em;" poster="/images/posts/2022/2022-08-08-managing-github-notifications-in-gmail/gmail-toggle.png">
  <source src="/images/posts/2022/2022-08-08-managing-github-notifications-in-gmail/gmail-toggle.mp4" type="video/mp4">
</video>
