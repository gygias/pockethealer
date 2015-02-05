//
//  EventModifier.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "EventModifier.h"

@implementation EventModifier

- (id)init
{
    if ( self = [super init] )
    {
        _blocks = [NSMutableArray new];
    }
    
    return self;
}

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
    if ( self.damageTakenDecreasePercentage )
        descriptionString = [NSString stringWithFormat:@"%@(decrease damage taken by %0.2f%%)",descriptionString?@" & ":@"",self.damageTakenDecreasePercentage.doubleValue];
    return descriptionString;
}

- (void)addBlock:(EventModifierBlock)block
{
    [_blocks addObject:block];
}

@end
