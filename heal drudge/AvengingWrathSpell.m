//
//  AvengingWrathSpell.m
//  heal drudge
//
//  Created by david on 1/29/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "AvengingWrathSpell.h"

#import "AvengingWrathEffect.h"

@implementation AvengingWrathSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Avenging Wrath";
        self.image = [ImageFactory imageNamed:@"avenging_wrath"];
        self.tooltip = @"Imbues you with wrathful light, increasing healing done by 100% and haste, critical strike chance, and damage by 20% for 20 sec.";
        self.triggersGCD = NO;
        self.cooldown = @( 3 * 60 );
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.castTime = @0;
        self.manaCost = @0;
        self.damage = @0;
        self.healing = @0;
        self.absorb = @0;
        
        self.school = HolySchool;
        
        self.castSoundName = @"avenging_wrath_cast";
    }
    return self;
}

- (void)handleHitWithSource:(Entity *)source target:(Entity *)target modifiers:(NSArray *)modifiers
{
    AvengingWrathEffect *aw = [AvengingWrathEffect new];
    [source addStatusEffect:aw source:source];
}

- (NSArray *)hdClasses
{
    return @[ [HDClass holyPaladin], [HDClass retPaladin] ];
}

- (AISpellPriority)aiSpellPriority
{
    AISpellPriority defaultPriority = FillerPriotity | CastWhenDamageDoneIncreasedPriority;
    return defaultPriority;
}

@end
