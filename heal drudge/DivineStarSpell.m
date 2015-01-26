//
//  DivineStarSpell.m
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "DivineStarSpell.h"

@implementation DivineStarSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Divine Star";
        self.image = [ImageFactory imageNamed:@"divine_star"];
        self.tooltip = @"Throws a ninja star of holiness.";
        self.triggersGCD = YES;
        self.cooldown = @15;
        self.spellType = BeneficialSpell;
        self.castableRange = @0;
        self.hitRange = @0;
        
        self.castTime = @0;
        self.manaCost = @( 0.02 * caster.baseMana.floatValue );
        self.damage = @0;
        self.healing = @( [caster.spellPower floatValue] * .566695 );
        self.absorb = @0;
        
        self.school = HolySchool;
    }
    return self;
}

- (NSArray *)hdClasses
{
    return @[ [HDClass discPriest] ];
}

@end
