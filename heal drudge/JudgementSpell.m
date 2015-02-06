//
//  JudgementSpell.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "JudgementSpell.h"

@implementation JudgementSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Judgement";
        self.image = [ImageFactory imageNamed:@"judgement"];
        self.tooltip = @"Causes (48% of Spell power + 58% of Attack power) Holy damage.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @6;
        self.spellType = DetrimentalSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.castTime = @0;
        self.manaCost = @(0.05 * caster.baseMana.floatValue);
        self.damage = @( 0.48 * caster.spellPower.doubleValue + 0.58 * caster.attackPower.doubleValue );
        
        self.school = HolySchool;
        
        self.castSoundName = @"holy_cast";
        self.hitSoundName = @"judgement_hit";
    }
    return self;
}

- (void)handleHitWithModifier:(EventModifier *)modifier
{
    if ( self.caster.hdClass.specID != HDHOLYPALADIN )
    {
        [self.caster addAuxResources:@1];
    }
}

- (NSArray *)hdClasses
{
    return @[ [HDClass holyPaladin], [HDClass protPaladin], [HDClass retPaladin] ];
}

- (AISpellPriority)aiSpellPriority
{
    AISpellPriority defaultPriority = FillerPriotity;
    return defaultPriority;
}

@end
