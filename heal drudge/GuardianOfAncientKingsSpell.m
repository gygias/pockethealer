//
//  GuardianOfAncientKingsSpell.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "GuardianOfAncientKingsSpell.h"

#import "GuardianOfAncientKingsEffect.h"

@implementation GuardianOfAncientKingsSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Guardian of Ancient Kings";
        self.image = [ImageFactory imageNamed:@"guardian_of_ancient_kings"];
        self.tooltip = @"Summons a Guardian of Ancient Kings to protect you for 12 sec.\n\nThe Guardian of Ancient Kings reduces damage taken by 50%.";
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
        
        self.school = HolySchool;
        
        self.hitSoundName = @"guardian_of_ancient_kings_hit";
    }
    return self;
}

- (void)handleHitWithModifier:(EventModifier *)modifier
{
    GuardianOfAncientKingsEffect *goak = [GuardianOfAncientKingsEffect new];
    [self.target addStatusEffect:goak source:self];
}

- (NSArray *)hdClasses
{
    return @[ [HDClass protPaladin] ];
}

- (AISpellPriority)aiSpellPriority
{
    AISpellPriority defaultPriority = CastBeforeLargeHitPriority | CastWhenInFearOfSelfDyingPriority;
    //if ( self.caster.hdClass.specID == HDPROTPALADIN )
    //    return defaultPriority | CastOnCooldownPriority;
    return defaultPriority;
}

@end
