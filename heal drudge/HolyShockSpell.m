//
//  HolyShockSpell.m
//  heal drudge
//
//  Created by david on 1/29/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "HolyShockSpell.h"

@implementation HolyShockSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Holy Shock";
        self.image = [ImageFactory imageNamed:@"holy_fire"];
        self.tooltip = @"Deals [ 140% of Spell Power ] Holy damage to an enemy, or [ 140% of Spell Power ] healing to an ally, and grants 1 Holy Power.\n\nHoly Shock has double the normal critical strike chance."; // TODO double crit chance?
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @6;
        self.spellType = BeneficialOrDeterimentalSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.castTime = @0;
        self.manaCost = @( .0735 * caster.baseMana.floatValue );
        self.damage = @0;
        self.healing = @( [caster.spellPower floatValue] * 1.4 );
        self.damage = @( [caster.spellPower floatValue] * 1.4 );
        self.grantsAuxResources = @1;
        self.absorb = @0;
        
        self.school = HolySchool;
        
        self.hitSoundName = @"heal_hit"; // TODO
    }
    return self;
}

- (NSArray *)hdClasses
{
    return @[ [HDClass holyPaladin] ];
}

- (AISpellPriority)aiSpellPriority
{
    return ChargePriority |
            CastWhenSomeoneNeedsHealingPriority |
            CastWhenTankNeedsHealingPriority;
}

@end
