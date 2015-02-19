//
//  HolyLightSpell.m
//  heal drudge
//
//  Created by david on 1/29/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "HolyLightSpell.h"

@implementation HolyLightSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Holy Light";
        self.image = [ImageFactory imageNamed:@"divine_light"];
        self.tooltip = @"Heals a friendly target for [ 1 + 300% of Spell Power ].";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @0;
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.castTime = @2.5;
        self.manaCost = @( .2 * caster.baseMana.floatValue );
        self.damage = @0;
        self.healing = @( [caster.spellPower floatValue] * 3.0 );
        self.absorb = @0;
        
        self.school = HolySchool;
        
        self.hitSoundName = @"holy_light_hit";
    }
    return self;
}

- (NSArray *)hdClasses
{
    return @[ [HDClass holyPaladin] ];
}

- (AISpellPriority)aiSpellPriority
{
    return CastWhenAnyoneNeedsHealing;
            // these situations are for flash heal
            //| CastWhenInFearOfOtherPlayerDyingPriority
            //| CastWhenInFearOfDyingPriority;
}

@end
