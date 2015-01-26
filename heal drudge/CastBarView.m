//
//  CastBarView.m
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "CastBarView.h"

#import "Spell.h"
#import "Entity.h"

@implementation CastBarView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // fill bar
    if ( [[NSDate date] timeIntervalSinceDate:self.castingSpell.lastCastStartDate] >= self.effectiveCastTime.doubleValue )
    {
        self.castingSpell = nil;
        self.effectiveCastTime = nil;
        return;
    }
    
    if ( self.effectiveCastTime.doubleValue <= 0 )
        return;
    
    double percentCast = [[NSDate date] timeIntervalSinceDate:self.castingSpell.lastCastStartDate] / self.effectiveCastTime.doubleValue;
    percentCast = self.castingSpell.isChanneled ? ( 1 - percentCast ) : percentCast;
    
    CGRect rectangle = CGRectMake(rect.origin.x,rect.origin.y,rect.size.width * percentCast,rect.size.height);
    CGContextAddRect(context, rectangle);
    CGContextSetFillColorWithColor(context,
                                     [UIColor grayColor].CGColor);
    CGContextFillPath(context);
    
    rectangle = CGRectMake(rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    CGContextAddRect(context, rectangle);
    CGContextSetStrokeColorWithColor(context,
                                     [UIColor whiteColor].CGColor);
    CGContextStrokePath(context);
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
    [self.castingSpell.name drawInRect:rect withAttributes:attributes];
    
    NSString *remainingTime = [NSString stringWithFormat:@"-%0.1fs",self.effectiveCastTime.doubleValue - [[NSDate date] timeIntervalSinceDate:self.castingSpell.lastCastStartDate]];
    CGSize remainingTimeSize = [remainingTime sizeWithAttributes:attributes];
    CGFloat rightMargin = remainingTimeSize.width + 5;
    CGRect remainingTimeRect = CGRectMake(rect.origin.x + rect.size.width - rightMargin, rect.origin.y, rightMargin, rect.size.height);
    [remainingTime drawInRect:remainingTimeRect withAttributes:attributes];
    
    [self _drawGCDThingInRect:rect];
}

#define GCD_TICK_SIZE 3
- (void)_drawGCDThingInRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSDate *nextGCD = self.castingEntity.nextGlobalCooldownDate;
    if ( nextGCD )
    {
        double ratio = -[[NSDate date] timeIntervalSinceDate:nextGCD] / self.castingEntity.currentGlobalCooldownDuration;
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


@end
