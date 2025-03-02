//
//  CastBarView.m
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "CastBarView.h"

#import "Spell.h"
#import "Entity.h"

@implementation CastBarView

#define CAST_BAR_IMAGE_SQUARE ( self.frame.size.height * 0.8 )
#define CAST_BAR_TOP_MARGIN ( self.frame.size.height * 0.1 )
#define CAST_BAR_LEFT_MARGIN ( CAST_BAR_TOP_MARGIN )

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, 20);
}

- (void)drawRect:(CGRect)rect {
    
    Spell *spell = self.entity.castingSpell;
    if ( ! spell )
        return;
    
    if ( [[NSDate date] timeIntervalSinceDateMinusPauseTime:spell.lastCastStartDate] >= spell.lastCastEffectiveCastTime )
        return;
    
    if ( spell.lastCastEffectiveCastTime <= 0 )
        return;
    
    if ( self.entity.castingSpell == nil )
        return;
    
    if ( ! CGRectEqualToRect(_lastRect, rect) )
        _refreshCachedValues = YES;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // fill bar
    
    double percentCast = [[NSDate date] timeIntervalSinceDateMinusPauseTime:spell.lastCastStartDate] / spell.lastCastEffectiveCastTime;
    percentCast = spell.isChanneled ? ( 1 - percentCast ) : percentCast;
    
    CGRect barRect = CGRectMake(rect.origin.x,rect.origin.y,rect.size.width * percentCast,rect.size.height);
    CGContextAddRect(context, barRect);
    CGContextSetFillColorWithColor(context,
                                     [UIColor grayColor].CGColor);
    CGContextFillPath(context);
    
    CGRect castRect = CGRectMake(rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    CGContextAddRect(context, castRect);
    CGContextSetStrokeColorWithColor(context,
                                     [UIColor whiteColor].CGColor);
    CGContextStrokePath(context);
    
    if ( _refreshCachedValues )
        _imageRect = CGRectMake(rect.origin.x + CAST_BAR_LEFT_MARGIN,rect.origin.y + CAST_BAR_TOP_MARGIN,CAST_BAR_IMAGE_SQUARE,CAST_BAR_IMAGE_SQUARE);
    [spell.image drawInRect:_imageRect blendMode:kCGBlendModeNormal alpha:0.5];
    if ( _refreshCachedValues )
        _textRect = CGRectMake(_imageRect.origin.x + CAST_BAR_LEFT_MARGIN + CAST_BAR_IMAGE_SQUARE,rect.origin.y + CAST_BAR_TOP_MARGIN,rect.size.width, rect.size.height);
    if ( ! _textAttributes )
        _textAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
    [spell.name drawInRect:_textRect withAttributes:_textAttributes];
    
    NSString *remainingTime = [NSString stringWithFormat:@"-%0.1fs",spell.lastCastEffectiveCastTime - [[NSDate date] timeIntervalSinceDateMinusPauseTime:spell.lastCastStartDate]];
    CGSize remainingTimeSize = [remainingTime sizeWithAttributes:_textAttributes];
    CGFloat rightMargin = remainingTimeSize.width + 5;
    if ( _refreshCachedValues )
        _remainingTimeRect = CGRectMake(rect.origin.x + rect.size.width - rightMargin, rect.origin.y + CAST_BAR_TOP_MARGIN, rightMargin, rect.size.height);
    [remainingTime drawInRect:_remainingTimeRect withAttributes:_textAttributes];
    
    [self _drawGCDThingInRect:rect];
    
    _refreshCachedValues = NO;
}

#define GCD_TICK_SIZE 3
- (void)_drawGCDThingInRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSDate *nextGCD = self.entity.nextGlobalCooldownDate;
    if ( nextGCD )
    {
        double ratio = -[[NSDate date] timeIntervalSinceDateMinusPauseTime:nextGCD] / self.entity.currentGlobalCooldownDuration;
        double invertedRatio = ( 1 - ratio );
        //if ( self.castingSpell.isChanneled )
        //    ratio = ( 1 - ratio );
        CGRect gcdNubRect = CGRectMake(rect.origin.x + ( invertedRatio * rect.size.width ), rect.origin.y + rect.size.height - GCD_TICK_SIZE, GCD_TICK_SIZE, GCD_TICK_SIZE);
        CGContextAddRect(context, gcdNubRect);
        CGContextSetFillColorWithColor(context,
                                       [UIColor whiteColor].CGColor);
        CGContextFillPath(context);
    }
}

- (PlayViewDrawMode)playViewDrawMode
{
    return RealTimeDrawMode;
}

@end
