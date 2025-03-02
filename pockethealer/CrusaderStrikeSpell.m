//
//  CrusaderStrikeSpell.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "CrusaderStrikeSpell.h"

@implementation CrusaderStrikeSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Crusader Strike";
        self.image = [ImageFactory imageNamed:@"crusader_strike"];
        self.tooltip = @"An instant strike that causes 100% Physical damage.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @4.5;
        self.spellType = DetrimentalSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        self.grantsAuxResources = @1;
        
        self.castTime = @0;
        self.manaCost = @(0.02 * caster.baseMana.floatValue);
        self.damage = @( 0.92448 * caster.attackPower.floatValue );
        
        self.school = HolySchool;
        
        self.hitSoundName = @"crusader_strike_hit"; // TODO
    }
    return self;
}

- (NSArray *)hdClasses
{
    return @[ [HDClass holyPaladin], [HDClass protPaladin], [HDClass retPaladin] ];
}

- (AISpellPriority)aiSpellPriority
{
    AISpellPriority defaultPriority = FillerPriority;
    if ( ! [self.caster.hdClass isEqual:[HDClass holyPaladin]] )
        defaultPriority |= ChargePriority;
    return defaultPriority;
}

@end
