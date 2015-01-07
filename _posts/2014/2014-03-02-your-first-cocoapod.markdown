---
layout: post
title: "Your First CocoaPod"
redirect_from: "/your-first-cocoapod//"
date: 2014-03-02 13:58:00
tags: [objective-c, ios, open source]
comments: true
dblog_post_id: 408
---
Right behind [Your First Ruby Gem](http://code.dblock.org/your-first-ruby-gem), here’s a walkthrough of creating your first Objective-C CocoaPod. Now, I must admit that after only two months of Objective-C programming, I am not nearly an expert. So I enlisted [Orta from CocoaPods](http://orta.github.io/) to stand behind my back and poke me with a stick whenever I did something wrong. It’s also important to note that there’s a lot of development going on in CocoaPods and my walkthrough represents the current state of affairs as of February 2014.

#### TL;DR

This was really easy. Open-source in Objective-C FTW!

I wrote [objc-ngram](https://github.com/dblock/objc-ngram), a small [n-gram](http://en.wikipedia.org/wiki/N-gram) library. For example, you could use it as a rudimentary full text search engine.

![]({{ site.url }}/images/posts/2014/2014-03-02-your-first-cocoapod/image_4.jpg)

#### Create a Pod

Get CocoaPods by running _gem install cocoapods_. Create a pod.

```
$ pod lib create objc-ngram

Creating `objc-ngram` Pod
Configuring template
To learn more about the template see `https://github.com/CocoaPods/pod-template`.
To learn more about creating a new pod, see `http://guides.cocoapods.org/making/making-a-cocoapod`.
```

This creates an _objc-ngram_ folder with a bunch of files. As of now, it’s missing a _Gemfile_, that I have created manually_._

{% highlight ruby %}
source 'https://rubygems.org'

gem 'cocoapods'
{% endhighlight %}

Run `bundle install`, which will generate a _Gemfile.lock _and a _.bundle_ folder. We don’t intend to lock the version of CocoaPods, so add _Gemfile.lock_ and .bundle to _.gitignore_.

#### Create a Demo/Test Project

Let's get rid of the default project created by _pod_ and re-create one that will reference our pod as a development pod.

```
$ rm -rf Project
```

Create a new iOS Single View Application project and place it into the folder created above (_objc-ngram_).

![]({{ site.url }}/images/posts/2014/2014-03-02-your-first-cocoapod/image_10.jpg)

Inside the Demo folder, create a Podfile. Yes, we’re going to write tests, using [Specta](https://github.com/specta/specta) and [Expecta](https://github.com/specta/expecta).

{% highlight ruby %}
pod "objc-ngram", :path => "../objc-ngram.podspec"

target "DemoTests" do
  pod 'Specta', '~> 0.2.1'
  pod 'Expecta', '~> 0.2.3'
end
{% endhighlight %}

Run `pod install`.

```
Demo> $ pod install
Analyzing dependencies
Fetching podspec for `objc-ngram` from `../objc-ngram.podspec`
Downloading dependencies
Installing Expecta (0.2.3)
Installing Specta (0.2.1)
Installing objc-ngram (0.1.0)
Generating Pods project
Integrating client project
[!] From now on use `Demo.xcworkspace`.
```

Add the _Demo/Pods_ folder, which includes all the pods installed from _pod install_,  to _.gitignore_.

Reopen the newly generated _Demo.xcworkspace_ from XCode. The project should build and run.

#### Housekeeping

This is a good opportunity to update _README_, _CHANGELOG_ and _LICENSE_.

Create a repository on Github and push the code you have so far.

#### Continuous Integration

There’s no excuse not to have tests or continuous integration for an open-source project.

In XCode, open _Manage Schemes _and make the _Demo_ scheme shared.

![]({{ site.url }}/images/posts/2014/2014-03-02-your-first-cocoapod/image_16.jpg)

Create a _.travis.yml_ file at the root of your project.

{% highlight yaml %}
language: objective-c

before_script:
  - export LANG=en_US.UTF-8
  - cd Demo ; pod install ; cd ..

xcode_workspace: Demo/Demo.xcworkspace

xcode_scheme: Demo

xcode_sdk: iphonesimulator
{% endhighlight %}

Enable the project to build in [Travis-CI](https://travis-ci.org/profile) and add a build status icon to the README.

[![Build Status](https://travis-ci.org/dblock/objc-ngram.png)](https://travis-ci.org/dblock/objc-ngram)

#### Code & Tests

Write code and tests. Code goes into the [Classes](https://github.com/dblock/objc-ngram/tree/master/Classes) folder. Tests go into the [Demo](https://github.com/dblock/objc-ngram/tree/master/Demo/DemoTests) project. Note, that in order for new class files to be visible to the project you must remember to rerun `pod install`. Pod will also enable ARC for those new files, automatically.

I always write tests and start with very obvious ones for each and every new class. This serves as a placeholder for more useful functionality.

{% highlight objc %}
#define EXP_SHORTHAND

#include <Specta/Specta.h>
#include <Expecta/Expecta.h>
#include <objc-ngram/OCNDictionary.h>

SpecBegin(OCNDictionarySpec)

__block OCNDictionary *dict = nil;

describe(@"default width", ^{
    beforeEach(^{
        dict = [OCNDictionary dictionary];
    });

    it(@"creates an instance", ^{
        expect(dict).toNot.beNil();
    });
});

SpecEnd
{% endhighlight %}

CocoaPods lets you easily try pods with `pod try`, so the Demo project should also do something useful and visually stimulating.

#### Releasing the Pod

Run `pod lib lint` and fix any issues.

Run `pod spec lint` and make sure the project version looks right. You should see an error about a tag missing.

```
[!] Pod::Executable fetch origin tags/1.0.0 2>&1
fatal: Couldn't find remote ref tags/1.0.0
```

Once ready, tag 1.0.0 and push it to Github.

```
git tag 1.0.0
git push --tags
```

Clone [https://github.com/cocoapods/specs](https://github.com/cocoapods/specs). Create a versioned folder under _specs_, eg. _specs/dblock/objc-ngram/1.0.0_. Place the .podspec file from your project there. Check that the version in _.podspec_ matches the folder name. Create a branch, commit the change and push it to your fork. Make a pull request to [https://github.com/CocoaPods/specs](https://github.com/CocoaPods/specs), mine was [https://github.com/CocoaPods/Specs/pull/8606](https://github.com/CocoaPods/Specs/pull/8606).

#### Test Drive

Once the pull request has been merged, try your pod.

```
pod repo update
pod try objc-ngram
```

Full source code for objc-ngram is in [https://github.com/dblock/objc-ngram](https://github.com/dblock/objc-ngram).
