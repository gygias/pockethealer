//
//  ArchangelEffect.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "ArchangelEffect.h"

@implementation ArchangelEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Archangel";
        self.duration = 18;
        self.maxStacks = @5;
        self.stacksAreInvisible = YES;
        self.effectType = BeneficialEffect;
    }
    
    return self;
}

- (BOOL)handleSpell:(Spell *)spell source:(Entity *)source target:(Entity *)target modifier:(NSMutableArray *)modifiers
{
    // TODO does 'beneficial' imply healing is defined? does it matter?
    EventModifier *mod = [EventModifier new];
    mod.healingIncreasePercentage = @( 0.05 * self.currentStacks.doubleValue );
    mod.source = self;
    [modifiers addObject:mod];
    return YES;
}

@end
