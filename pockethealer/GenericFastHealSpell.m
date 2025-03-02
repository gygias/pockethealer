//
//  GenericFastHealSpell.m
//  heal drudge
//
//  Created by david on 2/18/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "GenericFastHealSpell.h"

@implementation GenericFastHealSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Flash Heal";
        //self.image = [ImageFactory imageNamed:@"heal"];
        self.tooltip = @"Generic fast & inefficient healing.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @0;
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.castTime = @1.5;
        self.manaCost = @( 0.04 * caster.baseMana.floatValue );
        self.damage = @0;
        self.healing = @( [caster.spellPower floatValue] * 3.3264 );
        self.absorb = @0;
        
        self.school = HolySchool;
    }
    return self;
}

- (NSArray *)hdClasses
{
    return [HDClass allGenericHealingClassSpecs];
}

- (AISpellPriority)aiSpellPriority
{
    return CastWhenAnyoneNeedsUrgentHealing;
}

@end
