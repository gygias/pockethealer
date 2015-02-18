//
//  IceboundFortitudeSpell.m
//  heal drudge
//
//  Created by david on 2/18/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "IceboundFortitudeSpell.h"

#import "IceboundFortitudeEffect.h"

@implementation IceboundFortitudeSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Icebound Fortitude";
        self.image = [ImageFactory imageNamed:@"icebound_fortitude"];
        self.tooltip = @"The Death Knight freezes his blood to become immune to Stun effects and reduce all damage taken by 20% for 8 sec.";
        self.triggersGCD = YES;
        self.cooldown = @( 3 * 60 );
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.castTime = @0;
        self.manaCost = @0;
        self.damage = @0;
        self.healing = @0;
        self.absorb = @0;
        
        self.school = PhysicalSchool;
        
        self.castSoundName = @"icebound_fortitude_cast";
    }
    return self;
}

- (void)handleHitWithModifier:(EventModifier *)modifier
{
    IceboundFortitudeEffect *ibf = [IceboundFortitudeEffect new];
    [self.target addStatusEffect:ibf source:self.caster];
}

- (NSArray *)hdClasses
{
    return @[ [HDClass bloodDK] ];
}

- (AISpellPriority)aiSpellPriority
{
    AISpellPriority defaultPriority = CastBeforeLargeHitPriority | CastWhenInFearOfSelfDyingPriority;
    return defaultPriority;
}

@end
