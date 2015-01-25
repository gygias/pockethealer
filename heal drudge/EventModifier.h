//
//  EventModifier.h
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventModifier : NSObject

@property NSNumber *damageIncreasePercentage;
@property NSNumber *damageIncrease;
@property NSNumber *healingIncreasePercentage;
@property NSNumber *healingIncrease;
@property NSNumber *hasteIncreasePercentage;
@property BOOL      instantCast;
@property NSNumber *powerCostDecreasePercentage;
@property NSObject *source; // this isn't really necessary but helpful for debugging

@end
