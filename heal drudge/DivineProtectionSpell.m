//
//  DivineProtectionSpell.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "DivineProtectionSpell.h"

#import "DivineProtectionEffect.h"

@implementation DivineProtectionSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Divine Protection";
        self.image = [ImageFactory imageNamed:@"divine_protection"];
        self.tooltip = @"Reduces magic damage taken by 40%.";
        self.triggersGCD = YES;
        self.cooldown = @15;
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        self.school = MagicSchool;
        
        self.castTime = @0;
        self.manaCost = @(0.035 * caster.baseMana.floatValue);
        self.damage = @0;
        self.healing = @0;
        self.absorb = @0;
        
        self.school = HolySchool;
        
        self.hitSoundName = @"power_word_shield_hit"; // TODO
    }
    return self;
}

- (void)handleHitWithModifier:(EventModifier *)modifier
{
    DivineProtectionEffect *dp = [DivineProtectionEffect new];
    [self.caster addStatusEffect:dp source:self.caster];
}

- (NSArray *)hdClasses
{
    return @[ [HDClass holyPaladin], [HDClass protPaladin], [HDClass retPaladin] ];
}

- (AISpellPriority)aiSpellPriority
{
    AISpellPriority defaultPriority = CastBeforeLargeHitPriority | CastWhenInFearOfSelfDyingPriority;
    if ( self.caster.hdClass.specID == HDPROTPALADIN )
        return defaultPriority | FillerPriority;
    return defaultPriority;
}

@end
