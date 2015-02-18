//
//  AvengersShieldSpell.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "AvengersShieldSpell.h"

@implementation AvengersShieldSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Avenger's Shield";
        self.image = [ImageFactory imageNamed:@"avengers_shield"];
        self.tooltip = @"Hurls your shield at an enemy target, dealing (160% of Attack power) Holy damage, interrupting and silencing the target for 3 sec, and then jumping to 2 additional nearby enemies.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @15;
        self.spellType = DetrimentalSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        self.grantsAuxResources = @1;
        
        self.castTime = @0;
        self.manaCost = @(0.7 * caster.baseMana.floatValue);
        self.damage = @( 1.60 * caster.attackPower.floatValue );
        
        self.school = HolySchool;
        
        self.hitSoundName = @"avengers_shield_hit";
    }
    return self;
}

- (NSArray *)hdClasses
{
    return @[ [HDClass protPaladin] ];
}

- (AISpellPriority)aiSpellPriority
{
    return FillerPriority;
}

@end
