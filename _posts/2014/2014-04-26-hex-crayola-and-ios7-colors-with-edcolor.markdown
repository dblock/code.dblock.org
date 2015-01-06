---
layout: post
title: "Hex, Crayola and iOS7 Colors with EDColor"
redirect_from: "/hex-crayola-and-ios7-colors-with-edcolor/"
date: 2014-04-26 12:48:25
tags: [cocoapods, ios, open source]
comments: true
dblog_post_id: 412
---
If you are in the market for a color library, you’ll find many. I needed to convert a hex color into a _UIColor_. Let's try with Artsy purple. Rumor is that it was inspired by [Kenny Scharf's "Purple"](https://artsy.net/artwork/kenny-scharf-purple).

```objc
+ (UIColor *)artsyPurple
{
    return [UIColor colorWithRed:106/255.f green:11/255.f blue:193/255.f alpha:1];
}
```

Gross. One of the bigger problems with this code is that it creates a different color on 32-bit vs. 64-bit as a result of a non-integer division. Yes, we do write tests that compare snapshot images with [ios-snapshot-testcase](https://github.com/facebook/ios-snapshot-test-case) and those created on 32-bit simulators will fail on 64-bit ones. Also, someone with good vision will notice that our brand purple isn’t quite the same purple :)

What we want is to convert the color from its hex color.

```objc
+ (UIColor *)artsyPurple
{
    return [UIColor colorWithHex:0x6a0bc1];
}
```

What happens in every developer’s mind is a mystery to me: seems like _everyone_ has rolled out their own conversion macro or library. I have counted no less than twelve implementations, two in our own codebase. This is why I personally don’t like the approach taken by the Apple and Microsoft, which only expose the lowest level API possible as a general rule.

The library to end this madness is [EDColor](https://github.com/thisandagain/color). It also supports HSL, HSB, CIELAB and even Crayola crayon colors.

```objc
// UIColor+HSB
UIColor *red = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f];
UIColor *blue = [red offsetWithHue:-0.56f saturation:0.0f brightness:0.0f alpha:0.0f];

// UIColor+HSL
UIColor *red = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f];
UIColor *pink = [red offsetWithHue:0.0f saturation:0.0f lightness:0.82f alpha:0.0f];

// UIColor+CIELAB
UIColor *red = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f];
UIColor *brighterRed = [red offsetWithLightness:15.0f a:0.0f b:0.0f alpha:0.0f];

// UIColor+Crayola
UIColor *mint    = [UIColor colorWithCrayola:@"Magic Mint"];
UIColor *blue    = [UIColor colorWithCrayola:@"Midnight Blue"];
UIColor *rorange = [UIColor colorWithCrayola:@"Orange Red"];

// UIColor+iOS7
UIColor *yellow    = [UIColor iOS7yellowColor];
UIColor *greenGradientStart = [UIColor iOS7greenGradientStartColor];
UIColor *greenGradientEnd = [UIColor iOS7greenGradientEndColor];
```

I [contributed](https://github.com/thisandagain/color/pull/17) the iOS7 colors implementation from [here](https://github.com/mobilemagicdevelopers/UIColor-iOS7Colors), and found two bugs while writing tests. So, if you find another color library, you should merge it in as well. I reached out to [Caran d’Ache](http://www.carandache.com/) to get their color palette, but didn’t get a reply.

![](https://cloud.githubusercontent.com/assets/542335/2783933/2adda48c-cb34-11e3-831b-f134774f35d3.gif)
