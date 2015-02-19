//
//  LayOnHandsSpell.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "LayOnHandsSpell.h"

#import "ForbearanceEffect.h"

@implementation LayOnHandsSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Lay on Hands";
        self.image = [ImageFactory imageNamed:@"lay_on_hands"];
        self.tooltip = @"Heals a friendly target for an amount equal to your maximum health.\n\nCannot be used on a target with Forbearance.  Causes Forbearance for 1 min.";
        self.triggersGCD = NO;
        self.targeted = YES;
        self.cooldown = @( 10 * 60 );
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        self.cooldownType = CooldownTypeMajor;
        
        self.castTime = @0;
        self.manaCost = @0;
        self.damage = @0;
        self.healing = caster.health;
        self.absorb = @0;
        
        self.school = HolySchool;
        
        self.hitSoundName = @"lay_on_hands_hit";
    }
    return self;
}

- (void)handleHitWithModifier:(EventModifier *)modifier
{
    ForbearanceEffect *f = [ForbearanceEffect new];
    [self.target addStatusEffect:f source:self.caster];
}

- (NSArray *)hdClasses
{
    return @[ [HDClass holyPaladin], [HDClass protPaladin], [HDClass retPaladin] ];
}

- (AISpellPriority)aiSpellPriority
{
    return CastWhenInFearOfAnyoneDyingPriority;
}

@end
