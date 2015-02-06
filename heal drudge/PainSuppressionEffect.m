//
//  PainSuppressionEffect.m
//  heal drudge
//
//  Created by david on 1/25/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "PainSuppressionEffect.h"

#import "ImageFactory.h"

@implementation PainSuppressionEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Pain Suppression";
        self.duration = 8;
        self.image = [ImageFactory imageNamed:@"pain_suppression"];
        self.effectType = BeneficialEffect;
        self.drawsInFrame = YES;
    }
    
    return self;
}

- (BOOL)addModifiersWithSpell:(Spell *)spell modifiers:(NSMutableArray *)modifiers
{
    if ( spell.caster != self.source )
        return NO;
    
    // borrowed time doesn't seem to be consumed in WoD
    //if ( handler )
    //    handler(YES);
    return [self _applyDamageTakenDecrease:modifiers];
}

- (BOOL)_applyDamageTakenDecrease:(NSMutableArray *)modifiers
{
    EventModifier *mod = [EventModifier new];
    mod.damageTakenDecreasePercentage = @0.4;
    [modifiers addObject:mod];
    return YES;
}

@end
