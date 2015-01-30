//
//  Impale.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Impale.h"

@implementation Impale

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Impale";
        self.image = [ImageFactory imageNamed:@"hunger_for_blood"];
        self.tooltip = @"With blinding speed, Kargath rushes random targets every 2 sec. for 10 sec, doing 35,714 Physical damage to anyone within 7 yards.";
        //self.triggersGCD = YES;
        self.cooldown = @30; // "roughly every 30 seconds" -icyveins
        self.isPeriodic = YES;
        self.period = 1;
        self.periodicDuration = 10;
        self.periodicDamage = @38392;
        //self.hitRange = @7;
        
        self.canTargetTanks = YES;
        
        self.abilityLevel = DangerousAbility;
        self.spellType = DetrimentalSpell;
        self.school = PhysicalSchool;
    }
    return self;
}

@end
