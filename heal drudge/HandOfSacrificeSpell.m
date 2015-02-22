//
//  HandOfSacrificeSpell.m
//  heal drudge
//
//  Created by david on 1/29/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "HandOfSacrificeSpell.h"

#import "HandOfSacrificeEffect.h"

@implementation HandOfSacrificeSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Hand of Sacrifice";
        self.image = [ImageFactory imageNamed:@"hand_of_sacrifice"];
        if ( caster.hdClass.specID == HDRETPALADIN )
            self.tooltip = @"Places a Hand on a party or raid member, instantly removing all harmful Magic effects from the target, and transferring 30% of damage taken to the Paladin for 12 sec or until the Paladin has transferred 100% of their maximum health. Players may only have one Hand on them per Paladin at any one time.";
        else
            self.tooltip = @"Places a Hand on a party or raid member, transferring 30% of damage taken to the Paladin for 12 sec or until the Paladin has transferred 100% of their maximum health. Players may only have one Hand on them per Paladin at any one time.";
        self.triggersGCD = NO;
        self.targeted = YES;
        self.cannotSelfTarget = YES;
        self.cooldown = @( 2 * 60 );
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        self.cooldownType = CooldownTypeMinor;
        
        self.castTime = @0;
        self.manaCost = @(0.07 * caster.baseMana.floatValue);
        self.damage = @0;
        self.healing = @0;
        self.absorb = @0;
        
        self.school = MagicSchool;
        
        self.hitSoundName = @"hand_spell_hit";
    }
    return self;
}

- (void)handleHitWithModifier:(EventModifier *)modifier
{
    HandOfSacrificeEffect *hos = [HandOfSacrificeEffect new];
    // TODO ret also dispels, apparently
    hos.healthTransferRemaining = self.caster.health;
    [self.target addStatusEffect:hos source:self];
}

- (NSArray *)hdClasses
{
    return @[ [HDClass holyPaladin], [HDClass retPaladin] ];
}

- (AISpellPriority)aiSpellPriority
{
    AISpellPriority defaultPriority = CastBeforeAnyoneTakesLargeHit;
    return defaultPriority;
}

@end
