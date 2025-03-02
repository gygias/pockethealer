//
//  DancingRuneWeaponSpell.m
//  pockethealer
//
//  Created by david on 2/18/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "DancingRuneWeaponSpell.h"

#import "DancingRuneWeaponEffect.h"

@implementation DancingRuneWeaponSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Dancing Rune Weapon";
        self.image = [ImageFactory imageNamed:@"dancing_rune_weapon"];
        self.tooltip = @"Summons a second rune weapon for 8 sec that mirrors its master's attacks and bolsters its master's defenses, granting an additional 20% parry chance.";
        self.triggersGCD = YES;
        self.cooldown = @( 1.5 * 60 );
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
        
        self.castSoundName = @"dancing_rune_weapon_cast";
    }
    return self;
}

- (void)handleHitWithModifier:(EventModifier *)modifier
{
    DancingRuneWeaponEffect *drw = [DancingRuneWeaponEffect new];
    [self.target addStatusEffect:drw source:self];
}

- (NSArray *)hdClasses
{
    return @[ [HDClass bloodDK] ];
}

- (AISpellPriority)aiSpellPriority
{
    AISpellPriority defaultPriority = CastBeforeLargePhysicalHitPriority | CastWhenInFearOfSelfDyingPriority;
    return defaultPriority;
}

@end
