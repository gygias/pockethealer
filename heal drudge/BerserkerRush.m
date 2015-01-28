//
//  BerserkerRush.m
//  heal drudge
//
//  Created by david on 1/25/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "BerserkerRush.h"

@implementation BerserkerRush

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Berserker Rush";
        self.image = [ImageFactory imageNamed:@"berserker_rush"];
        self.tooltip = @"Kargath cuts his way towards you dealing 67% weapon damage to all targets in front of him, as well as increasing his physical damage done by 15% every 2 sec for 20 sec. Kargath's movement speed also increases by 40% every 2 sec for 20 sec.";
        //self.triggersGCD = YES;
        self.cooldown = @45; // "roughly every 30 seconds" -icyveins
        self.castTime = @1.5;
        //self.canTargetTanks = YES;
        self.affectsRandomRange = YES;
        self.damage = @1000000;
        
        self.abilityLevel = CatastrophicAbility;
        self.spellType = DetrimentalSpell;
    }
    return self;
}


@end
