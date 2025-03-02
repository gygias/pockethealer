//
//  GuardianOfAncientKingsEffect.m
//  pockethealer
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "GuardianOfAncientKingsEffect.h"

#import "ImageFactory.h"

@implementation GuardianOfAncientKingsEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Guardian of Ancient Kings";
        self.duration = 12;
        self.image = [ImageFactory imageNamed:@"guardian_of_ancient_kings"];
        self.effectType = BeneficialEffect;
        self.drawsInFrame = YES;
    }
    
    return self;
}

- (BOOL)addModifiersWithSpell:(Spell *)spell modifiers:(NSMutableArray *)modifiers
{
    BOOL modded = NO;
    if ( spell.caster.isEnemy && spell.target == self.owner )
    {
        EventModifier *mod = [EventModifier new];
        mod.damageTakenDecreasePercentage = @0.5;
        [modifiers addObject:mod];
        modded = YES;
    }
    return modded;
}

@end
