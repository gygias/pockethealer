//
//  UIView+SharedDrawing.h
//  heal drudge
//
//  Created by david on 2/20/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PocketHealer.h"

@interface UIView (SharedDrawing)

- (void)drawCooldownClockInRect:(CGRect)rect withPercentage:(double)percentage;
- (void)drawRoundedRectangleInRect:(CGRect)rect color:(UIColor *)color radius:(CGFloat)radius;

@end
