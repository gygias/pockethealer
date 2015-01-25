//
//  EventModifier.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "EventModifier.h"

@implementation EventModifier

- (NSString *)description
{
    NSString *descriptionString = nil;
    if ( self.damageIncrease )
        descriptionString = [NSString stringWithFormat:@"%@(increase damage by %@)",descriptionString?@" & ":@"",self.damageIncrease];
    else if ( self.damageIncreasePercentage )
        descriptionString = [NSString stringWithFormat:@"%@(increase damage by %0.2f%%)",descriptionString?@" & ":@"",self.damageIncreasePercentage.doubleValue];
    if ( self.healingIncrease )
        descriptionString = [NSString stringWithFormat:@"%@(increase healing by %@)",descriptionString?@" & ":@"",self.healingIncrease];
    else if ( self.healingIncreasePercentage )
        descriptionString = [NSString stringWithFormat:@"%@(increase healing by %0.2f%%)",descriptionString?@" & ":@"",self.healingIncreasePercentage.doubleValue];
    if ( self.hasteIncreasePercentage )
        descriptionString = [NSString stringWithFormat:@"%@(increase haste by %0.2f%%)",descriptionString?@" & ":@"",self.hasteIncreasePercentage.doubleValue];
    return descriptionString;
}

@end
