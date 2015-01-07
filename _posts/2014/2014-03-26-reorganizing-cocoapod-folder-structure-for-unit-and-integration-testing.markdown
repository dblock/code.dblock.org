---
layout: post
title: "Reorganizing CocoaPod Folder Structure for Unit and Integration Testing"
redirect_from: "/reorganizing-cocoapod-folder-structure-for-unit-and-integration-testing/"
date: 2014-03-26 14:06:21
tags: [cocoapods, ios, open source]
comments: true
dblog_post_id: 410
---
My first CocoaPod described in [this post](/your-first-cocoapod) sparked [a discussion](https://github.com/CocoaPods/pod-template/issues/25) with the CocoaPods team. There’re a few things I didn’t like about the project organization.

1. The name of the workspace was "Demo". I would expect the project to have the same name as the pod being written.
2. The demo project contained the Podfile, requiring developers to cd into Demo, then run _pod install_. I would expect the Podfile to live in the root of the project.
3. The demo project contained tests for the pod. I would expect the demo to be a demo and to have a test project that unit tests the pod being written.

All these issues can be addressed. I’ve reorganized two of my pods, [ARASCIIImageSwizzle](https://github.com/dblock/ARASCIISwizzle) and [ARTiledImageView](https://github.com/dblock/ARTiledImageView) and fixed all the issues above.

#### Folder Structure

Fixing the folder structure and naming is fairly straightforward. You can move the contents of the Demo folder one level up. This brings the Podfile to the root. The Podfile can also explicitly name the workspace.

{% highlight ruby %}
workspace 'ARASCIISwizzle'

pod 'ARASCIISwizzle', :path => 'ARASCIISwizzle.podspec'

xcodeproj 'Demo.xcodeproj'
{% endhighlight %}

You’ll have to update .travis.yml to build a different workspace and to reference the development pod in the same folder.

{% highlight yaml %}
language: objective-c

before_install:
  - brew update
  - brew uninstall xctool
  - brew install xctool
  - export LANG=en_US.UTF-8
  - gem i cocoapods --no-ri --no-rdoc
  - pod install

xcode_workspace: ARASCIISwizzle.xcworkspace

xcode_scheme: Demo

xcode_sdk: iphonesimulator
{% endhighlight %}

You can [see this commit in ARTiledImageView](https://github.com/dblock/ARTiledImageView/commit/9620887d879c3a7251829c6a0027271473ab7069) that accomplishes the same.

#### Integration Tests

The tests that are part of the Demo project are really integration tests. I’ve renamed those consequently with a bulk replace of file names and within the source code. You can see it in [this commit](https://github.com/dblock/ARTiledImageView/commit/5e4fbf975af6b291e3650c85fa00f8b3e89c5735) in ARTiledImageView.

#### Unit Tests

Let's build a clean unit test project for the pod, independent of the Demo project.

Create a new empty project in XCode called "Tests" or, if you prefer, "UnitTests".

Add a target.

![]({{ site.url }}/images/posts/2014/2014-03-26-reorganizing-cocoapod-folder-structure-for-unit-and-integration-testing/screenshot_6.jpg)

Choose Cocoa Touch Unit Testing bundle.

![]({{ site.url }}/images/posts/2014/2014-03-26-reorganizing-cocoapod-folder-structure-for-unit-and-integration-testing/screenshot_4.jpg)

Open _Manage Schemes_ and make sure the scheme is Shared. Then edit the Test project’s scheme and check the Run box under the Build action.

![]({{ site.url }}/images/posts/2014/2014-03-26-reorganizing-cocoapod-folder-structure-for-unit-and-integration-testing/screenshot_5.jpg)

The Podfile must now reference "Demo", "Tests" and the "IntegrationTests" project. The syntax for that is a bit backwards, discussed in [https://github.com/CocoaPods/CocoaPods/issues/1922](https://github.com/CocoaPods/CocoaPods/issues/1922).

{% highlight ruby %}
workspace 'ARASCIISwizzle'

pod 'ARASCIISwizzle', :path => 'ARASCIISwizzle.podspec'

xcodeproj 'Demo.xcodeproj'

target 'Demo' do
  pod 'FLKAutoLayout', '~> 0.1.1'
  xcodeproj 'Demo.xcodeproj'
end

target 'IntegrationTests' do
  pod 'Specta', '~> 0.2.1'
  pod 'Expecta', '~> 0.2.3'
  pod 'FBSnapshotTestCase', :head
  pod 'EXPMatchers+FBSnapshotTest', :head
  xcodeproj 'Demo.xcodeproj'
end

target 'Tests' do
  pod 'Specta', '~> 0.2.1'
  pod 'Expecta', '~> 0.2.3'
  pod 'FBSnapshotTestCase', :head
  pod 'EXPMatchers+FBSnapshotTest', :head
  pod 'OCMock', '~> 2.2.3'
  xcodeproj 'Tests.xcodeproj'
end
{% endhighlight %}

Travis will build "Tests" and "IntegrationTests" in a matrix.

{% highlight yaml %}
xcode_scheme:
  - Demo
  - Tests
{% endhighlight %}

You can see the results of the above in [this commit in ARASCIISwizzle](https://github.com/dblock/ARASCIISwizzle/commit/e8b906eb54d46025238b8a95833b51c8549932e3).

#### Conclusion

This is a lot closer to the Rubygems-style organization where everything is accessible from the top and tests live at the same level as pod classes.
