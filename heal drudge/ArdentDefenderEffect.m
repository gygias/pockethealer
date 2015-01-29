//
//  ArdentDefenderEffect.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

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

- (BOOL)handleSpell:(Spell *)spell asSource:(BOOL)asSource source:(Entity *)source target:(Entity *)target modifier:(NSMutableArray *)modifiers handler:(EffectEventHandler)handler
{
    EventModifier *mod = [EventModifier new];
    mod.cheatDeathAndApplyHealing = @( source.health.doubleValue * 0.12 );
    [modifiers addObject:mod];
#warning TODO there is currently no way for this to be consumed IF the target dies
    //handler(YES);
    return YES;
}

@end
