//
//  AvengingWrathEffect.m
//  heal drudge
//
//  Created by david on 1/29/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "AvengingWrathEffect.h"

@implementation AvengingWrathEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Avenging Wrath";
        self.duration = 20;
        self.image = [ImageFactory imageNamed:@"avenging_wrath"];
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
    if ( self.source.hdClass.specID == HDHOLYPALADIN )
        mod.healingIncreasePercentage = @0.2;
    else if ( self.source.hdClass.specID == HDRETPALADIN )
        mod.damageIncreasePercentage = @0.2; // TODO does ret still have wings?
    [modifiers addObject:mod];
    return YES;
}

@end
