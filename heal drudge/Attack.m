//
//  Attack.m
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Attack.h"

@implementation Attack

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.caster = caster;
        self.name = @"Attack";
        self.image = [ImageFactory imageNamed:@"melee_attack"];
        self.tooltip = @"Attacks the target.";
        //self.triggersGCD = YES;
        //self.cooldown = @15; // XXX
        self.cooldown = @2;
        //self.isPeriodic = YES;
        //self.period = 0.5;
        //self.periodicDamage = @35714;
        //self.periodicDuration = 10;
        //self.hitRange = @7;
        self.damage = @15000;
        self.targeted = YES;
        
        self.spellType = DetrimentalSpell;
        
        //self.affectsMainTarget = YES;
    }
    return self;
}

@end
