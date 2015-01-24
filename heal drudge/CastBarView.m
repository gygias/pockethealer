//
//  CastBarView.m
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "CastBarView.h"

#import "Spell.h"

@implementation CastBarView

//@synthesize castingSpell = _castingSpell;
//
//- (void)setCastingSpell:(Spell *)castingSpell
//{
//    
//}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // fill bar
    if ( [[NSDate date] timeIntervalSinceDate:self.castingSpell.lastCastStartDate] >= self.castingSpell.castTime )
    {
        self.castingSpell = nil;
        return;
    }
    
    if ( self.castingSpell.castTime <= 0 )
        return;
    
    double percentCast = [[NSDate date] timeIntervalSinceDate:self.castingSpell.lastCastStartDate] / self.castingSpell.castTime;
    
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
    
    [self.castingSpell.name drawInRect:rect withAttributes:nil];
}


@end
