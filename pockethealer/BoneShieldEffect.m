//
//  BoneShieldEffect.m
//  pockethealer
//
//  Created by david on 2/18/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "BoneShieldEffect.h"

@implementation BoneShieldEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Bone Shield";
        self.duration = ( 5 * 60 );
        self.image = [ImageFactory imageNamed:@"bone_shield"];
        self.effectType = BeneficialEffect;
        self.drawsInFrame = YES;
        self.currentStacks = @6;
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
        [self.owner consumeStatusEffect:self];
    }
    
    return modded;
}

@end
