//
//  IceboundFortitudeEffect.m
//  heal drudge
//
//  Created by david on 2/18/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "IceboundFortitudeEffect.h"

@implementation IceboundFortitudeEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Icebound Fortitude";
        self.duration = 8;
        self.image = [ImageFactory imageNamed:@"icebound_fortitude"];
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
        mod.damageTakenDecreasePercentage = @0.2;
        [modifiers addObject:mod];
        modded = YES;
    }
    return modded;
}

@end
