//
//  FlashOfLightSpell.m
//  heal drudge
//
//  Created by david on 1/29/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "FlashOfLightSpell.h"

@implementation FlashOfLightSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Flash of Light";
        self.image = [ImageFactory imageNamed:@"flash_heal"];
        self.tooltip = @"Heals a friendly target for [ 1 + 300% of Spell Power ].";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @0;
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.castTime = @1.5;
        self.manaCost = @( .103125 * caster.baseMana.floatValue );
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
    return FillerPriotity
            // this situation is for holy light
            //| CastWhenSomeoneNeedsHealingPriority
            | CastWhenInFearOfOtherPlayerDyingPriority
            | CastWhenInFearOfDyingPriority;
}

@end
