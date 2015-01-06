---
layout: post
title: "Don’t Hate UI Testing - Reliably Testing Asynchronous UI w/ RSpec & Capybara"
redirect_from: "/dont-hate-ui-testing-reliably-testing-asynchronous-ui-w-rspec-capybara/"
date: 2012-02-12 17:00:05
tags: [rspec, selenium, capybara, testing, dotnetinstaller]
comments: true
dblog_post_id: 316
---
![capybara4-510x394]({{ site.url }}/images/posts/2012/2012-02-12-dont-hate-ui-testing-reliably-testing-asynchronous-ui-w-rspec-capybara/capybara4-510x394_2.jpg)

Last week I wrote [an article on the Art.sy Enginering blog about testing with RSpec and Capybara](http://artsy.github.com/blog/2012/02/03/reliably-testing-asynchronous-ui-w-slash-rspec-and-capybara).

This wasn’t the first time I dealt with UI testing. And I am definitely getting a hang of it. I believe it goes in hand with the fact that I detest using mocks in tests and prefer to test the real thing. Sacrificing test purity for better coverage is better, IMHO.

I’ve done quite a bit of Win32 UI testing: read [this post](http://code.dblock.org/automating-win32-ui-testing-systemwindowsautomation-and-project-white). In fact, the entire dotNetInstaller InstallEditor test suite manipulates UI. For the anecdote I was writing a DNI feature on the Subway and the guy sitting next to me looked at my computer as if it were possessed. He proceeded telling me a story about how he thought his computer was hijacked, what the best Anti-Virus was and how he got rid of unusual Windows problems. He was incredible and spoke with great passion. I gave him my card and asked him to come and give a motivational talk on the topic of "computers have a life of their own". Too bad he never did.

I’ve done a bit of GWT UI testing with Selenium. That was a major pain. Capybara definitely takes a lot of that pain away.

I know the test automation community is always complaining about brittle and slow tests that involve a real browser. I refuse to be a hater – UI test automation, otherwise known as _integration testing_, has saved my product’s behind many, many times.
