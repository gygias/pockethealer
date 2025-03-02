//
//  MindBenderSpell.m
//  pockethealer
//
//  Created by david on 2/18/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "MindBenderSpell.h"

@implementation MindBenderSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Mindbender";
        self.image = [ImageFactory imageNamed:@"mindbender"];
        self.tooltip = @"Creates a Mindbender to attack the target. Caster receives 0.75% mana when the Mindbender attacks. Lasts 15 sec.\n\nReplaces Shadowfiend.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @( 1 * 60 );
        self.spellType = DetrimentalSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.castTime = @0;
        self.manaCost = @(0);
        self.isPeriodic = YES;
        self.periodicDamage = @1000; // TODO
        self.periodicHeal = @0;
        self.periodicDuration = 15;
        self.period = 12.0 / self.periodicDuration;
        
        self.school = ShadowSchool;
    }
    return self;
}

- (void)handleTickWithModifier:(EventModifier *)modifier firstTick:(BOOL)firstTick
{
    double maxManaDouble = self.caster.power.doubleValue;
    double currentManaDouble = self.caster.currentResources.doubleValue;
    double regenedMana = 0.0075 * self.caster.power.doubleValue;
    if ( regenedMana + self.caster.currentResources.doubleValue > maxManaDouble )
        self.caster.currentResources = self.caster.power;
    else
        self.caster.currentResources = @( currentManaDouble + regenedMana );
}

- (NSArray *)hdClasses
{
    return @[ [HDClass discPriest], [HDClass holyPriest] ];
}

- (AISpellPriority)aiSpellPriority
{
    AISpellPriority priority = NoPriority;
    if ( self.caster.currentResourcePercentage.doubleValue < 0.95 )
        priority |= ConsumeChargePriority;
    return priority;
}

@end
