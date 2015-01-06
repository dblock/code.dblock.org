---
layout: post
title: "Mocking UIAlertView with OCMock"
redirect_from: "/mocking-uialertview-with-ocmock/"
date: 2014-01-16 23:35:25
tags: [objective-c, ios, testing]
comments: true
dblog_post_id: 406
---
Let's mock a UIAlertView with [OCMock](http://ocmock.org/). Here’s a simple alert:

```objc
UIAlertView *alert = [[UIAlertView alloc]
   initWithTitle:@"Title"
   message:@"Please press a button."
   delegate:...
   cancelButtonTitle:@"Cancel"
   otherButtonTitles:@"OK", nil];

[alert show];
```

And a test that ensures that the alert has been displayed.

```objc
id mockAlertView = [OCMockObject mockForClass:[UIAlertView class]];
[[[mockAlertView stub] andReturn:mockAlertView] alloc];
(void)[[[mockAlertView expect] andReturn:mockAlertView]
                          initWithTitle:@"Title"
                                message:@"Please press a button."
                               delegate:OCMOCK_ANY
                      cancelButtonTitle:OCMOCK_ANY
                      otherButtonTitles:OCMOCK_ANY, nil];
[[mockAlertView expect] show];

// make the alert appear here

[mockAlertView verify];
[mockAlertView stopMocking];
```

The only interesting thing here is that you need to _stopMocking_ the class or other tests will still have the mock enabled and will expect _show_ to be called, producing weird and seemingly unrelated errors.

Related to this – if you’re going to be performing actions based on _UIAlertView_ button presses, I highly recommend [UIAlertView+Blocks](https://github.com/ryanmaxwell/UIAlertView-Blocks), which lets you write the callback inline with the view. I haven’t figured out how to test that, you can [help me on StackOverflow](http://stackoverflow.com/questions/21174836/how-can-i-mock-a-uialertview-with-a-callback).
