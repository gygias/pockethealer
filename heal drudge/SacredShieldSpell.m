//
//  SacredShieldSpell.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "SacredShieldSpell.h"

#import "SacredShieldEffect.h"

@implementation SacredShieldSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Sacred Shield";
        self.image = [ImageFactory imageNamed:@"divine_protection"];
        self.tooltip = @"Protects the target with a shield of holy light.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @60;
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.castTime = @0;
        self.manaCost = @0;
        self.damage = @0;
        self.healing = @0;
        self.absorb = @0;
        
        self.school = HolySchool;
        
        //self.hitSoundName = @"power_word_shield_hit"; // TODO
    }
    return self;
}

- (void)handleHitWithSource:(Entity *)source target:(Entity *)target modifiers:(NSArray *)modifiers
{
    SacredShieldEffect *ss = [SacredShieldEffect new];
    [source addStatusEffect:ss source:source];
}

- (NSArray *)hdClasses
{
    return @[ [HDClass holyPaladin], [HDClass protPaladin], [HDClass retPaladin] ]; // todo this is a talent
}

- (AISpellPriority)aiSpellPriority
{
    AISpellPriority defaultPriority = CastBeforeLargeHitPriority | CastWhenInFearOfDyingPriority;
    if ( self.caster.hdClass.specID == HDPROTPALADIN )
        return defaultPriority | FillerPriotity;
    return defaultPriority;
}

@end
