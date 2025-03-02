//
//  PowerWordShieldSpell.m
//  pockethealer
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "PowerWordShieldSpell.h"
#import "PowerWordShieldEffect.h"
#import "WeakenedSoulEffect.h"
#import "BorrowedTimeEffect.h"
#import "Entity.h"

@implementation PowerWordShieldSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Power Word: Shield";
        self.image = [ImageFactory imageNamed:@"power_word_shield"];
        self.tooltip = @"Shields a friendly target";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = [caster.hdClass isEqual:[HDClass discPriest]] ? @0 : @6;
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.castTime = @0;
        self.manaCost = @(0.024 * caster.baseMana.floatValue);
        self.damage = @0;
        self.healing = @0;
        self.absorb = @(( ( ( [caster.spellPower floatValue] * 5 ) + 2 ) * 1 ));
        
        self.school = HolySchool;
        
        self.hitSoundName = @"power_word_shield_hit";
    }
    return self;
}

- (void)handleHitWithModifier:(EventModifier *)modifier
{
    // borrowed time
    BorrowedTimeEffect *bt = [BorrowedTimeEffect new];
    [self.caster addStatusEffect:bt source:self];
    
    // weakened soul
    WeakenedSoulEffect *weakenedSoul = [WeakenedSoulEffect new];
    [self.target addStatusEffect:weakenedSoul source:self];
    
    // power word shield
    PowerWordShieldEffect *pws = [PowerWordShieldEffect new];
    pws.absorb = @( self.absorb.doubleValue * ( 1 + modifier.healingIncreasePercentage.doubleValue ) );
    [self.target addStatusEffect:pws source:self];
}

- (NSArray *)hdClasses
{
    return @[ [HDClass discPriest], [HDClass holyPriest], [HDClass shadowPriest] ];
}

- (AISpellPriority)aiSpellPriority
{
    return CastWhenAnyoneNeedsHealing | CastWhenAnyoneNeedsUrgentHealing | PrecastOnMainTankPriority;
}

@end
