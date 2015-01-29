//
//  BastionOfGloryEffect.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

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

- (BOOL)handleSpell:(Spell *)spell asSource:(BOOL)asSource source:(Entity *)source target:(Entity *)target modifier:(NSMutableArray *)modifiers handler:(EffectEventHandler)handler
{
    if ( [spell isKindOfClass:[WordOfGlorySpell class]]
        && ( target == self.source ) )
    {
        EventModifier *mod = [EventModifier new];
        mod.healingIncreasePercentage = @( self.currentStacks.doubleValue * 0.06 );
        [modifiers addObject:mod];
        handler(YES);
        return YES;
    }
    return NO;
}

@end
