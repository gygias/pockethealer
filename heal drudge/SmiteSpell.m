//
//  SmiteSpell.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "SmiteSpell.h"

@implementation SmiteSpell

- (id)initWithCaster:(Character *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Smite";
        self.image = [ImageFactory imageNamed:@"smite"];
        self.tooltip = @"Smite an enemy.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @10;
        self.castableRange = @30;
        self.castTime = 1.5;
        
        self.manaCost = @( 0.015 * caster.baseMana.floatValue );
        
        // hit
        self.damage = @( 0.92448 * caster.spellPower.floatValue );
        self.damageType = HolyDamage;
    }
    return self;
}

- (NSArray *)hdClasses
{
    return @[ [HDClass discPriest], [HDClass holyPriest], [HDClass shadowPriest] ];
}

@end
