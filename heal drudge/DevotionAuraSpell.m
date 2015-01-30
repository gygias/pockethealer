//
//  DevotionAuraSpell.m
//  heal drudge
//
//  Created by david on 1/29/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "DevotionAuraSpell.h"

#import "DevotionAuraEffect.h"
#import "Encounter.h"

@implementation DevotionAuraSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Devotion Aura";
        self.image = [ImageFactory imageNamed:@"devotion_aura"];
        self.tooltip = @"Inspire all party and raid members within 40 yards, granting them immunity to Silence and Interrupt effects and reducing all magic damage taken by 20%. Lasts 6 sec.";
        self.triggersGCD = NO;
        self.targeted = YES;
        self.cooldown = @( 3 * 60 );
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @40;
        
        self.castTime = @0;
        self.manaCost = @0;
        self.damage = @0;
        self.healing = @0;
        self.absorb = @0;
        
        self.school = HolySchool;
        
        self.castSoundName = @"devotion_aura_cast";
    }
    return self;
}

- (void)handleHitWithSource:(Entity *)source target:(Entity *)target modifiers:(NSArray *)modifiers
{
    [source.encounter.raid.players enumerateObjectsUsingBlock:^(Entity *player, NSUInteger idx, BOOL *stop) {
        DevotionAuraEffect *da = [DevotionAuraEffect new];
        [player addStatusEffect:da source:source];
    }];
}

- (NSArray *)hdClasses
{
    return @[ [HDClass holyPaladin] ];
}

- (AISpellPriority)aiSpellPriority
{
    return CastBeforeLargeMagicDamagePriority;
}

@end
