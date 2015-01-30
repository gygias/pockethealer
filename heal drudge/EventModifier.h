//
//  EventModifier.h
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Spell.h"

@interface EventModifier : NSObject

@property SpellSchool school;
@property NSNumber *damageIncreasePercentage;
@property NSNumber *damageIncrease;
@property NSNumber *healingIncreasePercentage;
@property NSNumber *healingIncrease;
@property NSNumber *hasteIncreasePercentage;
@property NSNumber *damageTakenDecreasePercentage;
@property BOOL      instantCast;
@property NSNumber *cheatDeathAndApplyHealing;
@property NSNumber *powerCostDecreasePercentage;
@property NSObject *source; // this isn't really necessary but helpful for debugging

@property NSNumber *absorbedDamage;
@property NSNumber *healOnDamage;

@end
