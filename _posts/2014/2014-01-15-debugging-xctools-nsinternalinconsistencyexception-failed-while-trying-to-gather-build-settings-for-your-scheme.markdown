---
layout: post
title: "Debugging XCTool’s NSInternalInconsistencyException: Failed while trying to gather build settings for your scheme"
redirect_from: "/debugging-xctools-nsinternalinconsistencyexception-failed-while-trying-to-gather-build-settings-for-your-scheme"
date: 2014-01-15 15:05:00
tags: [xcode, ios, travis-ci]
comments: true
---
Took me a while to figure this one out, trying to add a Travis-CI build to [https://github.com/dblock/ios-snapshot-test-case-expecta](https://github.com/dblock/ios-snapshot-test-case-expecta).

The project build succeeds locally. Also succeeds on a different machine with a clean checkout. But [fails in Travis](https://travis-ci.org/dblock/ios-snapshot-test-case-expecta/builds/16998345) with an obscure error:

```
xctool -workspace
   FBSnapshotTestCaseDemo/FBSnapshotTestCaseDemo.xcworkspace
   -scheme FBSnapshotTestCaseDemo
   -configuration Debug clean

[Info] Loading settings for scheme 'FBSnapshotTestCaseDemo' ...

2014-01-15 06:34:35.661 xctool[2048:2807]
   *** Assertion failure in -[XcodeSubjectInfo buildSettingsForATarget],
   /tmp/xctool-WSKd/xctool-0.1.14/xctool/xctool/XcodeSubjectInfo.m:813
2014-01-15 06:34:35.727 xctool[2048:2807]
   *** Terminating app due to uncaught exception 'NSInternalInconsistencyException',
   reason: 'Failed while trying to gather build settings for your scheme; tried with actions: build, test, analyze'

*** First throw call stack:
(
   0   CoreFoundation   07fff98bbcb06 __exceptionPreprocess + 198
   1   libobjc.A.dylib  07fff8fa7f3f0 objc_exception_throw + 43
   2   CoreFoundation   07fff98bbc948 +[NSException raise:format:arguments:] + 104
   3   Foundation       07fff979634c2 -[NSAssertionHandler handleFailureInMethod:object:file:lineNumber:description:] + 189
   4   xctool           00001041b7ccf -[XcodeSubjectInfo buildSettingsForATarget] + 548
   5   xctool           00001041b89d1 -[XcodeSubjectInfo loadSubjectInfo] + 150
   6   xctool           00001041adbe4 -[Options validateAndReturnXcodeSubjectInfo:errorMessage:] + 2521
   7   xctool           00001041a5e67 -[XCTool run] + 1303
   8   xctool           00001041a50eb main + 507
   9   xctool           00001041a2f84 start + 52
   10  ???              0000000000008 0 + 8
)
libc++abi.dylib: terminate called throwing an exception
make: *** [clean] Abort trap: 6
```

It says: _Failed while trying to gather build settings for your scheme; tried with actions: build, test, analyze._

After some digging through xctool’s source code I found that it [tries to run the following command](https://github.com/facebook/xctool/blob/master/xctool/xctool/XcodeSubjectInfo.m#L764):

```
SHOW_ONLY_BUILD_SETTINGS_FOR_FIRST_BUILDABLE=YES
DYLD_INSERT_LIBRARIES=/usr/local/Cellar/xctool/0.1.14/libexec/lib/xcodebuild-fastsettings-shim.dylib
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild
test
-showBuildSettings
-project FBSnapshotTestCaseDemo/FBSnapshotTestCaseDemo.xcodeproj
-scheme FBSnapshotTestCaseDemo
```

It’s just trying to collect build settings for the scheme specified.

Interestingly, this succeeds locally for me, but fails on Travis with the following error.

```
xcodebuild: error: The project 'FBSnapshotTestCaseDemo' does not contain a scheme named 'FBSnapshotTestCaseDemo'
```

This is the real problem, the schemes are user-specific unless marked as _shared_ in the project. Both of my machines have the same username, but Travis obviously has another.

You can change this in [Manage Schemes](https://developer.apple.com/library/ios/recipes/xcode_help-scheme_editor/Articles/SchemeManage.html) in XCode.

![]({{ site.url }}/images/posts/2014/2014-01-15-debugging-xctools-nsinternalinconsistencyexception-failed-while-trying-to-gather-build-settings-for-your-scheme/screenshot_1.jpg)

![]({{ site.url }}/images/posts/2014/2014-01-15-debugging-xctools-nsinternalinconsistencyexception-failed-while-trying-to-gather-build-settings-for-your-scheme/screenshot_2.jpg)

Opened [https://github.com/facebook/xctool/issues/295](https://github.com/facebook/xctool/issues/295) to improve the error messaging in XCTool.

And [here’s a successful build of the ios-snapshot-test-case-expecta project on Travis](https://travis-ci.org/dblock/ios-snapshot-test-case-expecta).
