//
//  BoneShieldSpell.m
//  heal drudge
//
//  Created by david on 2/18/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "BoneShieldSpell.h"

#import "BoneShieldEffect.h"

@implementation BoneShieldSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Bone Shield";
        self.image = [ImageFactory imageNamed:@"bone_shield"];
        self.tooltip = @"Surrounds you with a barrier of whirling bones with 6 charges that reduces all damage you take by 20%. Each damaging attack consumes a charge. Lasts 5 min or until all charges are consumed.";
        self.triggersGCD = YES;
        self.cooldown = @( 1 * 60 );
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.castTime = @0;
        self.manaCost = @0;
        self.damage = @0;
        self.healing = @0;
        self.absorb = @0;
        
        self.school = PhysicalSchool;
        
        self.castSoundName = @"bone_shield_cast";
    }
    return self;
}

- (void)handleHitWithModifier:(EventModifier *)modifier
{
    BoneShieldEffect *bs = [BoneShieldEffect new];
    [self.target addStatusEffect:bs source:self];
}

- (NSArray *)hdClasses
{
    return @[ [HDClass bloodDK] ];
}

- (AISpellPriority)aiSpellPriority
{
    AISpellPriority defaultPriority = FillerPriority | CastBeforeLargeHitPriority | CastWhenInFearOfSelfDyingPriority;
    return defaultPriority;
}

@end
