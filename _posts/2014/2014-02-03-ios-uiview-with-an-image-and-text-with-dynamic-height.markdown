---
layout: post
title: "iOS UIView with an Image and Text with Dynamic Height"
redirect_from: "/ios-uiview-with-an-image-and-text-with-dynamic-height/"
date: 2014-02-03 05:29:55
tags: [objective-c, ios, ui]
comments: true
---
Last week I struggled with this rather basic problem of adjusting the height of a UIView dynamically.

_TL;DR_: the solution was to align the bottom edge of  with a control with the view.

![]({{ site.url }}/images/posts/2014/2014-02-03-ios-uiview-with-an-image-and-text-with-dynamic-height/image_6.jpg)

We use a custom _UIView_ with a fixed height of 120px to display a separator, an image and text on its right. We also use [FLKAutoLayout](https://github.com/dkduck/FLKAutoLayout), which is where all these nice alignment methods come from.

```objc
- (void)displayText:(NSString *)text andImage:(NSString *)imageUrl
{
   UIView *separator = [[UIView alloc] init];
   separator.backgroundColor = [UIColor colorWithWhite: 0xe5/255.f alpha:1];
   [self addSubview:separator];
   [separator constrainHeight:@"1"];
   [separator constrainWidthToView:self predicate:nil];
   [separator alignCenterXWithView:self predicate:nil];

   ARAspectRatioImageView *imageView = [[ARAspectRatioImageView alloc] init];
   NSURL *imageUrl = [NSURL URLWithString:url];
   [imageView setImageWithURL:imageUrl];
   [self addSubview:imageView];
   [imageView alignTopEdgeWithView:self predicate:@"20"];
   [imageView alignLeadingEdgeWithView:self predicate:@"20"];
   [imageView constrainWidth:@"80"];
   [imageView setContentMode:UIViewContentModeScaleAspectFit];

   UILabel *labelView = [[UILabel alloc] init];
   labelView.text = text;
   [self addSubview:labelView];
   [labelView alignTopEdgeWithView:imageView predicate:@"0"];
   [labelView alignAttribute:NSLayoutAttributeLeading
                 toAttribute:NSLayoutAttributeTrailing
                      ofView:imageView predicate:@"20"];
   [labelView alignTrailingEdgeWithView:self predicate:@"-20"];
}

- (CGSize)intrinsicContentSize
{
   return CGSizeMake(UIViewNoIntrinsicMetric, 120);
}
```

This is obviously problematic for tall images and cropping art is a major offense. How do we dynamically calculate the height of the view based on the image and/or text height? Since the image is loaded dynamically, are we going to have to write some pretty involved code to wait until its height is known? Do we need to auto-size the label and calculate its height after it wraps over multiple lines?

The answer is that we don’t need to do any of this. With auto-layout we need to attach the image and the text to the bottom of the containing view.

```objc
[self alignBottomEdgeWithView:labelView predicate:@"10"];
[self alignBottomEdgeWithView:imageView predicate:@"10"];
```

With this constraint auto-layout seems to be smart enough to pick the tallest control to calculate the height of the view.

![]({{ site.url }}/images/posts/2014/2014-02-03-ios-uiview-with-an-image-and-text-with-dynamic-height/image_11.jpg)
