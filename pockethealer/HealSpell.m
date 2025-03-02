//
//  HealSpell.m
//  pockethealer
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "HealSpell.h"

@implementation HealSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Heal";
        self.image = [ImageFactory imageNamed:@"heal"];
        self.tooltip = @"A slow casting heal that heals a single target.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @0;
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.castTime = @2.5;
        self.manaCost = @( 0.02 * caster.baseMana.floatValue );
        self.damage = @0;
        self.healing = @( [caster.spellPower floatValue] * 3.3264 );
        self.absorb = @0;
        
        self.school = HolySchool;
    }
    return self;
}

- (NSArray *)hdClasses
{
    return @[ [HDClass discPriest], [HDClass holyPriest] ];
}

- (AISpellPriority)aiSpellPriority
{
    return CastWhenAnyoneNeedsHealing;
}

@end
