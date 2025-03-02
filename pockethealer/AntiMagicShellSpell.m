//
//  AntiMagicShellSpell.m
//  pockethealer
//
//  Created by david on 2/18/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "AntiMagicShellSpell.h"

#import "AntiMagicShellEffect.h"

@implementation AntiMagicShellSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Anti-Magic Shell";
        self.image = [ImageFactory imageNamed:@"anti-magic_shell"];
        self.tooltip = @"Surrounds the Death Knight in an Anti-Magic Shell for 5 sec, absorbing 75% of all magical damage and preventing application of harmful magical effects. Damage absorbed generates Runic Power.";
        self.triggersGCD = YES;
        self.cooldown = @( 45 );
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        self.cooldownType = CooldownTypeMinor;
        
        self.castTime = @0;
        self.manaCost = @0;
        self.damage = @0;
        self.healing = @0;
        self.absorb = @0;
        
        self.school = ShadowSchool;
        
        self.castSoundName = @"anti-magic_shell_cast";
    }
    return self;
}

- (void)handleHitWithModifier:(EventModifier *)modifier
{
    AntiMagicShellEffect *ams = [AntiMagicShellEffect new];
    [self.target addStatusEffect:ams source:self];
}

- (NSArray *)hdClasses
{
    return @[ [HDClass bloodDK], [HDClass frostDK], [HDClass unholyDK] ];
}

- (AISpellPriority)aiSpellPriority
{
    AISpellPriority defaultPriority = CastBeforeLargeMagicHitPriority | CastWhenInFearOfSelfDyingPriority;
    return defaultPriority;
}

@end
