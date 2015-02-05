//
//  HandOfSacrificeEffect.m
//  heal drudge
//
//  Created by david on 1/29/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "HandOfSacrificeEffect.h"

#import "Event.h"

@implementation HandOfSacrificeEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Hand of Sacrifice";
        self.duration = 20;
        self.image = [ImageFactory imageNamed:@"hand_of_sacrifice"];
        self.drawsInFrame = YES;
        self.effectType = BeneficialEffect;
    }
    
    return self;
}

- (BOOL)addModifiersWithSpell:(Spell *)spell modifiers:(NSMutableArray *)modifiers
{
    if ( self.source == spell.target )
        return NO;
    
    if ( spell.damage.doubleValue <= 0 )
        return NO;
    
    BOOL consumed = NO;
    NSNumber *damageReduction = nil;
    NSNumber *thirtyPercentOfDamage = @( spell.damage.doubleValue * 0.3 );
    if ( thirtyPercentOfDamage.doubleValue >= self.healthTransferRemaining.doubleValue ) // TODO can't do this correctly, need the damage taken after modifiers are applied, maybe need a handle spell HIT vs handle spell (whatever point in time this method refers to)
    {
        damageReduction = self.healthTransferRemaining;
        consumed = YES;
    }
    else
        damageReduction = thirtyPercentOfDamage;
    
    EventModifier *mod = [EventModifier new];
    mod.damageTakenDecrease = damageReduction;
    if ( consumed )
    {
        [mod addBlock:^{
            [self.source consumeStatusEffect:self absolute:YES];
        }];
    }
    [modifiers addObject:mod];
    
    Event *transferredDamageEvent = [Event new];
    transferredDamageEvent.netDamage = thirtyPercentOfDamage;
    transferredDamageEvent.spell = spell;
    [self.source handleIncomingDamageEvent:transferredDamageEvent];
    
    return YES;
}

@end