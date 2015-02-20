//
//  PowerWordBarrierSpell.m
//  heal drudge
//
//  Created by david on 1/25/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "PowerWordBarrierSpell.h"
#import "PowerWordBarrierEffect.h"

@implementation PowerWordBarrierSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Power Word: Barrier";
        self.image = [ImageFactory imageNamed:@"power_word_barrier"];
        self.tooltip = @"Puts a bubble on it";
        self.triggersGCD = YES;
        // self.targetingCircle = YES;
        self.cooldown = @( 3 * 60 );
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @10;
        self.hitRangeTargetable = YES;
        self.cooldownType = CooldownTypeMajor;
        
        self.castTime = @0;
        self.manaCost = @(0.063 * caster.baseMana.floatValue);
        self.damage = @0;
        self.healing = @0;
        self.absorb = @0;
        
        self.school = HolySchool;
        
        self.castSoundName = @"power_word_shield_cast";
    }
    return self;
}

- (void)handleHitWithModifier:(EventModifier *)modifier
{
    PowerWordBarrierEffect *pwb = [PowerWordBarrierEffect new];
    [self.target addStatusEffect:pwb source:self.caster];
}

- (NSArray *)hdClasses
{
    return @[ [HDClass discPriest] ];
}

- (AISpellPriority)aiSpellPriority
{
    return CastBeforeLargeAOEPriority;
}

@end
