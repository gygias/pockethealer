//
//  FlashHealSpell.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "FlashHealSpell.h"

@implementation FlashHealSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Flash Heal";
        self.image = [ImageFactory imageNamed:@"flash_heal"];
        self.tooltip = @"Heals a friendly target.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @0;
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.castTime = @1.5;
        self.manaCost = @( 0.0414 * caster.baseMana.floatValue );
        self.damage = @0;
        self.healing = @( [caster.spellPower floatValue] * 3.32657 );
        self.absorb = @0;
        
        self.school = HolySchool;
    }
    return self;
}

- (NSArray *)hdClasses
{
    return @[ [HDClass discPriest], [HDClass holyPriest], [HDClass shadowPriest] ];
}

@end
