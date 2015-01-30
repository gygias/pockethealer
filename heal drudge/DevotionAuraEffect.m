//
//  DevotionAuraEffect.m
//  heal drudge
//
//  Created by david on 1/29/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "DevotionAuraEffect.h"

#import "ImageFactory.h"

@implementation DevotionAuraEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Devotion Aura";
        self.duration = 6;
        self.image = [ImageFactory imageNamed:@"devotion_aura"];
        self.drawsInFrame = YES;
        self.effectType = BeneficialEffect;
    }
    
    return self;
}

- (BOOL)handleSpell:(Spell *)spell asSource:(BOOL)asSource source:(Entity *)source target:(Entity *)target modifier:(NSMutableArray *)modifiers handler:(EffectEventHandler)handler
{
    if ( spell.school & MagicSchool )
    {
        EventModifier *mod = [EventModifier new];
        mod.damageTakenDecreasePercentage = @0.2;
        mod.school = MagicSchool;
        [modifiers addObject:mod];
        return YES;
    }
    return NO;
}

@end
