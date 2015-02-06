//
//  ArdentDefenderSpell.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "ArdentDefenderSpell.h"

#import "ArdentDefenderEffect.h"

@implementation ArdentDefenderSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Ardent Defender";
        self.image = [ImageFactory imageNamed:@"ardent_defender"];
        self.tooltip = @"Damage taken reduced by 20%.\nThe next attack that would otherwise kill you will instead cause you to be healed for 12% of your maximum health.";
        self.triggersGCD = YES;
        self.cooldown = @(3 * 60);
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.castTime = @0;
        self.manaCost = @0;
        self.damage = @0;
        self.healing = @0;
        self.absorb = @0;
        
        self.school = HolySchool;
        
        self.castSoundName = @"ardent_defender_cast";
        self.hitSoundName = @"ardent_defender_hit";
    }
    return self;
}

- (void)handleHitWithModifier:(EventModifier *)modifier
{
    ArdentDefenderEffect *ad = [ArdentDefenderEffect new];
    [self.caster addStatusEffect:ad source:self.caster];
}

- (NSArray *)hdClasses
{
    return @[ [HDClass protPaladin] ];
}

- (AISpellPriority)aiSpellPriority
{
    AISpellPriority defaultPriority = CastBeforeLargeHitPriority | CastWhenInFearOfDyingPriority;
    return defaultPriority;
}

@end
