//
//  ArchangelEffect.m
//  pockethealer
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "ArchangelEffect.h"

#import "ImageFactory.h"

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
        self.image = [ImageFactory imageNamed:@"archangel"];
    }
    
    return self;
}

- (BOOL)addModifiersWithSpell:(Spell *)spell modifiers:(NSMutableArray *)modifiers
{
    if ( spell.caster != self.source )
        return NO;
    
    // TODO does 'beneficial' imply healing is defined? does it matter?
    EventModifier *mod = [EventModifier new];
    mod.healingIncreasePercentage = @( 0.05 * self.currentStacks.doubleValue );
    //mod.
    mod.source = self;
    [modifiers addObject:mod];
    return YES;
}

@end
