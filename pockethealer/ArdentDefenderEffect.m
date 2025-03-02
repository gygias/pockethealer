//
//  ArdentDefenderEffect.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "ArdentDefenderEffect.h"

#import "Entity.h"
#import "ImageFactory.h"

@implementation ArdentDefenderEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Ardent Defender";
        self.duration = 10;
        self.image = [ImageFactory imageNamed:@"ardent_defender"];
        self.drawsInFrame = YES;
        self.effectType = BeneficialEffect;
    }
    
    return self;
}

- (BOOL)addModifiersWithSpell:(Spell *)spell modifiers:(NSMutableArray *)modifiers
{
    if ( spell.target != self.source )
        return NO;
    
    EventModifier *mod = [EventModifier new];
    mod.cheatDeathAndApplyHealing = @( self.source.health.doubleValue * 0.12 );
    [mod addBlock:^(Spell *spell, BOOL cheatedDeath) {
        if ( cheatedDeath )
            [self.source consumeStatusEffect:self absolute:YES];
    }];
    [modifiers addObject:mod];
    return YES;
}

@end
