//
//  PainSuppressionSpell.m
//  pockethealer
//
//  Created by david on 1/25/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "PainSuppressionSpell.h"

#import "PainSuppressionEffect.h"

@implementation PainSuppressionSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Pain Suppression";
        self.image = [ImageFactory imageNamed:@"pain_suppression"];
        self.tooltip = @"Suppresses pain.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @( 3 * 60 );
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        self.cooldownType = CooldownTypeMajor;
        
        self.castTime = @0;
        self.manaCost = @(0.016 * caster.baseMana.floatValue); // TODO
        self.damage = @0;
        self.healing = @0;
        self.absorb = @0;
        
        self.school = HolySchool;
        
        self.hitSoundName = @"nature_cast"; // TODO does this have a sound?
    }
    return self;
}

- (void)handleHitWithModifier:(EventModifier *)modifier
{
    PainSuppressionEffect *effect = [PainSuppressionEffect new];
    [self.target addStatusEffect:effect source:self];
}

- (NSArray *)hdClasses
{
    return @[ [HDClass discPriest] ];
}

- (AISpellPriority)aiSpellPriority
{
    return CastBeforeAnyoneTakesLargeHit;
}

@end
