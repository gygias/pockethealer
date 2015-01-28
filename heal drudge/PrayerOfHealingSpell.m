//
//  PrayerOfHealingSpell.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PrayerOfHealingSpell.h"

@implementation PrayerOfHealingSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Prayer of Healing";
        self.image = [ImageFactory imageNamed:@"prayer_of_healing"];
        self.tooltip = @"Heals a group within 30 yards.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @0;
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.castTime = @2.5;
        self.manaCost = @( 0.07128 * caster.baseMana.floatValue );
        self.damage = @0;
        self.healing = @( [caster.spellPower floatValue] * 2.21664 );
        self.absorb = @0;
        
        self.affectsPartyOfTarget = YES;
        
        self.school = HolySchool;
    }
    return self;
}

- (NSArray *)hdClasses
{
    return @[ [HDClass discPriest], [HDClass holyPriest] ];
}

@end
