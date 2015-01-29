//
//  LayOnHandsSpell.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "LayOnHandsSpell.h"

#import "ForbearanceEffect.h"

@implementation LayOnHandsSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Word of Glory";
        self.image = [ImageFactory imageNamed:@"word_of_glory"];
        self.tooltip = @"Consumes up to 3 Holy Power to heal a friendly target for up to (264.591% of Spell power)..";
        self.triggersGCD = NO;
        self.targeted = YES;
        self.cooldown = @( 10 * 60 );
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.castTime = @0;
        self.manaCost = @0;
        self.damage = @0;
        self.healing = caster.health;
        self.absorb = @0;
        
        self.school = HolySchool;
        
        self.hitSoundName = @"lay_on_hands_hit";
    }
    return self;
}

- (void)handleHitWithSource:(Entity *)source target:(Entity *)target modifiers:(NSArray *)modifiers
{
    ForbearanceEffect *f = [ForbearanceEffect new];
    [target addStatusEffect:f source:source];
}

- (NSArray *)hdClasses
{
    return @[ [HDClass holyPaladin], [HDClass protPaladin], [HDClass retPaladin] ];
}

- (AISpellPriority)aiSpellPriority
{
    return CastWhenInFearOfDyingPriority | CastWhenInFearOfOtherPlayerDyingPriority;
}

@end
