//
//  BastionOfGloryEffect.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "BastionOfGloryEffect.h"

#import "WordOfGlorySpell.h"
#import "ImageFactory.h"

@implementation BastionOfGloryEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Bastion of Glory";
        self.duration = 20;
        self.image = [ImageFactory imageNamed:@"bastion_of_glory"];
        self.drawsInFrame = YES;
        self.effectType = BeneficialEffect;
    }
    
    return self;
}

- (BOOL)addModifiersWithSpell:(Spell *)spell modifiers:(NSMutableArray *)modifiers
{
    if ( spell.caster != self.source )
        return NO;
    
    if ( [spell isKindOfClass:[WordOfGlorySpell class]]
        && ( spell.target == self.source ) )
    {
        EventModifier *mod = [EventModifier new];
        mod.healingIncreasePercentage = @( self.currentStacks.doubleValue * 0.06 );
        [mod addBlock:^(Spell *spell, BOOL cheatedDeath) {
            [self.source consumeStatusEffect:self absolute:YES];
        }];
        [modifiers addObject:mod];
        return YES;
    }
    return NO;
}

@end
