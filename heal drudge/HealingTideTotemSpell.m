//
//  HealingTideTotemSpell.m
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "HealingTideTotemSpell.h"

@implementation HealingTideTotemSpell

- (id)initWithCaster:(Character *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Healing Tide Totem";
        self.image = [ImageFactory imageNamed:@"healing_tide"];
        self.tooltip = @"Summons a fucking totem.";
        self.triggersGCD = YES;
        self.cooldown = @( 3 * 60 );
        self.isBeneficial = YES;
        self.castableRange = @0;
        self.hitRange = @40;
        
        self.castTime = 0;
        self.manaCost = @( 0.056 * caster.baseMana.floatValue );
        self.damage = @0;
        self.healing = @( [caster.spellPower floatValue] * 3.32657 );
        self.absorb = @0;
    }
    return self;
}

- (NSArray *)hdClasses
{
    return @[ [HDClass restoShaman] ];
}

@end
