//
//  PowerWordBarrierEffect.m
//  pockethealer
//
//  Created by david on 2/19/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PowerWordBarrierEffect.h"

@implementation PowerWordBarrierEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Power Word: Barrier";
        self.duration = 8;
        self.image = [ImageFactory imageNamed:@"power_word_barrier"];
        self.effectType = BeneficialEffect;
        self.drawsInFrame = YES;
    }
    
    return self;
}

- (BOOL)addModifiersWithSpell:(Spell *)spell modifiers:(NSMutableArray *)modifiers
{
    if ( spell.target == self.owner && spell.caster.isEnemy )
    {
        EventModifier *mod = [EventModifier new];
        mod.damageTakenDecreasePercentage = @0.25;
        [modifiers addObject:mod];
        return YES;
    }
    
    return NO;
}

@end
