//
//  EventModifier.h
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <Foundation/Foundation.h>

#import "Spell.h"

typedef void (^EventModifierBlock)(Spell * spell,BOOL cheatedDeath);

@interface EventModifier : NSObject
{
    NSMutableArray *_blocks;
}

@property SpellSchool school;
@property NSNumber *damageIncreasePercentage;
@property NSNumber *damageIncrease;
@property NSNumber *healingIncreasePercentage;
@property NSNumber *healingIncrease;
@property NSNumber *hasteIncreasePercentage;
@property NSNumber *damageTakenDecreasePercentage;
@property NSNumber *damageTakenDecrease;
@property BOOL      instantCast;
@property NSNumber *cheatDeathAndApplyHealing;
@property NSNumber *powerCostDecreasePercentage;
@property BOOL      crit;
@property NSObject *source; // this isn't really necessary but helpful for debugging

@property NSNumber *absorbedDamage;
@property NSNumber *healOnDamage;

@property NSArray *blocks;
- (void)addBlock:(EventModifierBlock)block;

+ (EventModifier *)netModifierWithSpell:(Spell *)spell modifiers:(NSArray *)modifiers;

@end
