//
//  ShieldOfTheRighteousEffect.m
//  pockethealer
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "ShieldOfTheRighteousEffect.h"

#import "ImageFactory.h"

@implementation ShieldOfTheRighteousEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Shield of the Righteous";
        self.duration = 3;
        self.image = [ImageFactory imageNamed:@"shield_of_the_righteous"];
        self.drawsInFrame = YES;
        self.effectType = BeneficialEffect;
    }
    
    return self;
}

- (BOOL)addModifiersWithSpell:(Spell *)spell modifiers:(NSMutableArray *)modifiers
{
    if ( spell.caster != self.source )
        return NO;
    
    EventModifier *mod = [EventModifier new];
    mod.damageTakenDecreasePercentage = @0.4; // TODO
    [modifiers addObject:mod];
    return YES;
}

@end
