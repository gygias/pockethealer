//
//  EventModifier.m
//  pockethealer
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

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
        descriptionString = [NSString stringWithFormat:@"%@(increase damage by %@)",descriptionString?[NSString stringWithFormat:@"%@ & ",descriptionString]:@"",self.damageIncrease];
    if ( self.damageIncreasePercentage )
        descriptionString = [NSString stringWithFormat:@"%@(increase damage by %0.2f%%)",descriptionString?[NSString stringWithFormat:@"%@ & ",descriptionString]:@"",self.damageIncreasePercentage.doubleValue * 100];
    if ( self.healingIncrease )
        descriptionString = [NSString stringWithFormat:@"%@(increase healing by %@)",descriptionString?[NSString stringWithFormat:@"%@ & ",descriptionString]:@"",self.healingIncrease];
    if ( self.healingIncreasePercentage )
        descriptionString = [NSString stringWithFormat:@"%@(increase healing by %0.2f%%)",descriptionString?[NSString stringWithFormat:@"%@ & ",descriptionString]:@"",self.healingIncreasePercentage.doubleValue];
    if ( self.hasteIncreasePercentage )
        descriptionString = [NSString stringWithFormat:@"%@(increase haste by %0.2f%%)",descriptionString?[NSString stringWithFormat:@"%@ & ",descriptionString]:@"",self.hasteIncreasePercentage.doubleValue];
    if ( self.damageTakenDecreasePercentage )
        descriptionString = [NSString stringWithFormat:@"%@(decrease damage taken by %0.2f%%)",descriptionString?[NSString stringWithFormat:@"%@ & ",descriptionString]:@"",self.damageTakenDecreasePercentage.doubleValue * 100];
    if ( self.cheatDeathAndApplyHealing )
        descriptionString = [NSString stringWithFormat:@"%@(cheat death and heal for %@)",descriptionString?[NSString stringWithFormat:@"%@ & ",descriptionString]:@"",self.cheatDeathAndApplyHealing];
    if ( self.powerCostDecreasePercentage )
        descriptionString = [NSString stringWithFormat:@"%@(reduce power cost by %0.2f%%)",descriptionString?[NSString stringWithFormat:@"%@ & ",descriptionString]:@"",self.powerCostDecreasePercentage.doubleValue * 100];
    if ( self.parryIncreasePercentage )
        descriptionString = [NSString stringWithFormat:@"%@(increase parry by %0.2f%%)",descriptionString?[NSString stringWithFormat:@"%@ & ",descriptionString]:@"",self.parryIncreasePercentage.doubleValue * 100];
    if ( self.crit )
        descriptionString = [NSString stringWithFormat:@"%@(crit)",descriptionString?[NSString stringWithFormat:@"%@ & ",descriptionString]:@""];
    if ( self.crit )
        descriptionString = [NSString stringWithFormat:@"%@(instant cast)",descriptionString?[NSString stringWithFormat:@"%@ & ",descriptionString]:@""];
    if ( self.absorbedDamage )
        descriptionString = [NSString stringWithFormat:@"%@(absorb %@ damage)",descriptionString?[NSString stringWithFormat:@"%@ & ",descriptionString]:@"",self.absorbedDamage];
    if ( descriptionString )
    {
        if ( self.healOnDamage )
            descriptionString = [NSString stringWithFormat:@"%@(heal on damage for %@)",descriptionString?[NSString stringWithFormat:@"%@ & ",descriptionString]:@"",self.healOnDamage];
        descriptionString = [NSString stringWithFormat:@"%@ -love (((%@)))",descriptionString,self.source?self.source:@"anonymous"];
    }
    else
        descriptionString = @"(empty modifier)";
    
    return descriptionString;
}

- (void)addBlock:(EventModifierBlock)block
{
    [_blocks addObject:block];
}

//@property SpellSchool school;
//@property NSNumber *damageIncreasePercentage;
//@property NSNumber *damageIncrease;
//@property NSNumber *healingIncreasePercentage;
//@property NSNumber *healingIncrease;
//@property NSNumber *hasteIncreasePercentage;
//@property NSNumber *damageTakenDecreasePercentage;
//@property NSNumber *damageTakenDecrease;
//@property BOOL      instantCast;
//@property NSNumber *cheatDeathAndApplyHealing;
//@property NSNumber *powerCostDecreasePercentage;
//@property BOOL      crit;
//@property NSObject *source; // this isn't really necessary but helpful for debugging
//
//@property NSNumber *absorbedDamage;
//@property NSNumber *healOnDamage;

+ (EventModifier *)netModifierWithSpell:(Spell *)spell modifiers:(NSArray *)modifiers
{
    EventModifier *netMod = [EventModifier new];
    
    [modifiers enumerateObjectsUsingBlock:^(EventModifier *mod, NSUInteger idx, BOOL *stop) {
        
        if ( mod.school != AnySchool && ! ( mod.school & spell.school ) )
        {
            PHLog(spell,@"the school of %@'s %@ doesn't match that of %@",mod.source,mod,spell);
            return;
        }
        
        if ( mod.damageIncrease )
            netMod.damageIncrease = @( netMod.damageIncrease.doubleValue + mod.damageIncrease.doubleValue );
        if ( mod.damageIncreasePercentage )
            netMod.damageIncreasePercentage = @( netMod.damageIncreasePercentage.doubleValue + mod.damageIncreasePercentage.doubleValue );
        if ( mod.healingIncrease )
            netMod.healingIncrease = @( netMod.healingIncrease.doubleValue + mod.healingIncrease.doubleValue );
        if ( mod.healingIncreasePercentage )
            netMod.healingIncreasePercentage = @( netMod.healingIncreasePercentage.doubleValue + mod.healingIncreasePercentage.doubleValue );
        if ( mod.hasteIncreasePercentage )
            netMod.hasteIncreasePercentage = @( netMod.hasteIncreasePercentage.doubleValue + mod.hasteIncreasePercentage.doubleValue );
        if ( mod.damageTakenDecrease )
            netMod.damageTakenDecrease = @( netMod.damageTakenDecrease.doubleValue + mod.damageTakenDecrease.doubleValue );
        if ( mod.damageTakenDecreasePercentage )
            netMod.damageTakenDecreasePercentage = @( netMod.damageTakenDecreasePercentage.doubleValue + mod.damageTakenDecreasePercentage.doubleValue );
        if ( mod.instantCast )
            netMod.instantCast = YES;
        if ( mod.cheatDeathAndApplyHealing )
            netMod.cheatDeathAndApplyHealing = @( netMod.cheatDeathAndApplyHealing.doubleValue + mod.cheatDeathAndApplyHealing.doubleValue );
        if ( mod.powerCostDecreasePercentage )
            netMod.powerCostDecreasePercentage = @( netMod.powerCostDecreasePercentage.doubleValue + mod.powerCostDecreasePercentage.doubleValue );
        if ( mod.parryIncreasePercentage )
            netMod.parryIncreasePercentage = @( netMod.parryIncreasePercentage.doubleValue + mod.parryIncreasePercentage.doubleValue );
        if ( mod.crit )
            netMod.crit = YES;
        if ( mod.absorbedDamage )
            netMod.absorbedDamage = @( netMod.absorbedDamage.doubleValue + mod.absorbedDamage.doubleValue );
        if ( mod.healOnDamage )
            netMod.healOnDamage = @( netMod.healOnDamage.doubleValue + mod.healOnDamage.doubleValue );
        
        [mod.blocks enumerateObjectsUsingBlock:^(EventModifierBlock block, NSUInteger idx, BOOL *stop) {
            [netMod addBlock:block];
        }];
    }];
    
    return netMod;
}

@end
