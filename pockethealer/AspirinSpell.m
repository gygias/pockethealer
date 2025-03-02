//
//  AspirinSpell.m
//  heal drudge
//
//  Created by david on 4/1/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "AspirinSpell.h"

@implementation AspirinSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Aspirin";
        self.image = [ImageFactory imageNamed:@"g_heal"];
        self.tooltip = @"Blasts the friendly target with over-the-counter painkiller, healing them for 332% of spell power.";
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
