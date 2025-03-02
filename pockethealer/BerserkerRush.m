//
//  BerserkerRush.m
//  heal drudge
//
//  Created by david on 1/25/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "BerserkerRush.h"

#import "Enemy.h"

@implementation BerserkerRush

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.caster = caster;
        self.name = @"Berserker Rush";
        self.image = [ImageFactory imageNamed:@"berserker_rush"];
        self.tooltip = @"Kargath cuts his way towards you dealing 67% weapon damage to all targets in front of him, as well as increasing his physical damage done by 15% every 2 sec for 20 sec. Kargath's movement speed also increases by 40% every 2 sec for 20 sec.";
        //self.triggersGCD = YES;
        self.cooldown = @45; // "roughly every 30 seconds" -icyveins
        self.castTime = @1.5;
        //self.canTargetTanks = YES;
        self.affectsRandomRange = YES;
        self.damage = @( 100000 * ( .5 + ((Enemy *)caster).difficulty ) ); // TODO making this not a oneshot until "player iq" is a thing
        self.targeted = YES;
        
        self.abilityLevel = CatastrophicAbility;
        self.spellType = DetrimentalSpell;
        self.school = PhysicalSchool;
    }
    return self;
}


@end
