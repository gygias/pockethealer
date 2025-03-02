//
//  PrayerOfMendingSpell.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "PrayerOfMendingSpell.h"

#import "PrayerOfMendingEffect.h"

@implementation PrayerOfMendingSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Prayer of Mending";
        self.image = [ImageFactory imageNamed:@"prayer_of_mending"];
        self.tooltip = @"Bounces around healing people.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @10;
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.castTime = @1.5;
        self.manaCost = @( 0.024 * caster.baseMana.floatValue );
        self.damage = @0;
        self.healing = @( [caster.spellPower floatValue] * 0.442787 );
        self.absorb = @0;
        
        self.school = HolySchool;
        self.castSoundName = @"nature_cast";
        //self.hitSoundName = @"prayer_of_mending_hit";
    }
    return self;
}

- (NSArray *)hdClasses
{
    return @[ [HDClass discPriest], [HDClass holyPriest] ];
}

- (void)handleHitWithModifier:(EventModifier *)modifier
{    
    PrayerOfMendingEffect *pom = [PrayerOfMendingEffect new];
    pom.healingOnDamage = self.healing;
    [self.target addStatusEffect:pom source:self];
}

- (AISpellPriority)aiSpellPriority
{
    return FillerPriority | CastWhenAnyoneNeedsHealing;
}

@end
