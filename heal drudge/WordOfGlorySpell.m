//
//  WordOfGlorySpell.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "WordOfGlorySpell.h"

@implementation WordOfGlorySpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Word of Glory";
        self.image = [ImageFactory imageNamed:@"word_of_glory"];
        self.tooltip = @"Consumes up to 3 Holy Power to heal a friendly target for up to (264.591% of Spell power)..";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @1;
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.castTime = @( caster.hdClass.specID == HDPROTPALADIN ? 0 : 1.5 );
        self.manaCost = @0;
        self.auxiliaryResourceCost = @1;
        self.auxiliaryResourceIdealCost = @3;
        self.damage = @0;
        self.healing = @( 2.64591 * caster.spellPower.doubleValue );
        self.absorb = @0;
        
        self.school = HolySchool;
        
        self.hitSoundName = @"renew_hit"; // TODO
    }
    return self;
}

- (NSArray *)hdClasses
{
    return @[ [HDClass holyPaladin], [HDClass protPaladin] ];
}

- (AISpellPriority)aiSpellPriority
{
    return CastOnIdealAuxResourceAvailablePriority | CastWhenInFearOfDyingPriority;
}

@end
