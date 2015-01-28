//
//  BladeDance.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "BladeDance.h"

@implementation BladeDance

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Blade Dance";
        self.image = [ImageFactory imageNamed:@"bladestorm"];
        self.tooltip = @"With blinding speed, Kargath rushes random targets every 2 sec. for 10 sec, doing 35,714 Physical damage to anyone within 7 yards.";
        //self.triggersGCD = YES;
        //self.cooldown = @15; // XXX
        self.cooldown = @15;
        self.isPeriodic = YES;
        self.period = 2.0;
        self.periodicDamage = @35714;
        self.periodicDuration = 10;
        self.hitRange = @7;
        
        self.affectsRandomRange = YES;
        self.periodicEffectChangesTargets = YES;
        
        self.canTargetTanks = NO;
        
        self.abilityLevel = NotableAbility;
    }
    return self;
}

@end
