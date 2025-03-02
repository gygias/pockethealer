//
//  UIColor+Extensions.m
//  pockethealer
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "UIColor+Extensions.h"

@implementation UIColor (UIColorExtensions)

+ (UIColor *)pinkColor
{
    return [UIColor colorWithRed:1 green: 0.6 blue:0.8 alpha:1];
}

+ (UIColor *)cooldownClockColor
{
    UIColor *blackColor = [UIColor blackColor];
    UIColor *cooldownClockColor = [blackColor colorWithAlphaComponent:0.75];
    return cooldownClockColor;
}

+ (UIColor *)disabledSpellColor
{
    UIColor *blackColor = [UIColor blackColor];
    UIColor *cooldownClockColor = [blackColor colorWithAlphaComponent:0.5];
    return cooldownClockColor;
}

+ (UIColor *)speechBubbleColor
{
    UIColor *blueColor = [UIColor whiteColor];
    UIColor *speechBubbleColor = [blueColor colorWithAlphaComponent:0.75];
    return speechBubbleColor;
}

@end
