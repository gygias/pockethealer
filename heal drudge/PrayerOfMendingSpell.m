//
//  PrayerOfMendingSpell.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

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
    }
    return self;
}

- (NSArray *)hdClasses
{
    return @[ [HDClass discPriest], [HDClass holyPriest] ];
}

- (void)handleHitWithSource:(Entity *)source target:(Entity *)target modifiers:(NSArray *)modifiers
{    
    PrayerOfMendingEffect *pom = [PrayerOfMendingEffect new];
    [target addStatusEffect:pom source:source];
}

@end
