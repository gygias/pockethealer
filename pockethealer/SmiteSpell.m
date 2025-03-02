//
//  SmiteSpell.m
//  pockethealer
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "SmiteSpell.h"

#import "Entity.h"
#import "EvangelismEffect.h"
#import "ArchangelEffect.h"

@implementation SmiteSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Smite";
        self.image = [ImageFactory imageNamed:@"smite"];
        self.tooltip = @"Smite an enemy.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @0;
        self.castableRange = @30;
        self.castTime = @1.5;
        self.spellType = DetrimentalSpell;
        
        self.manaCost = @( 0.015 * caster.baseMana.floatValue );
        
        // hit
        self.damage = @( 0.92448 * caster.spellPower.floatValue );
        
        self.school = HolySchool;
    }
    return self;
}

- (void)handleHitWithModifier:(EventModifier *)modifier
{    
    EvangelismEffect *currentEvangelism = [PriestSpell _evangelismForEntity:self.caster];
    if ( ! currentEvangelism )
    {
        currentEvangelism = [EvangelismEffect new];
        [self.caster addStatusEffect:currentEvangelism source:self];
    }
    else
        [currentEvangelism addStack];
}

- (NSArray *)hdClasses
{
    return @[ [HDClass discPriest], [HDClass holyPriest], [HDClass shadowPriest] ];
}

- (AISpellPriority)aiSpellPriority
{
    AISpellPriority priority = NoPriority;
    EvangelismEffect *currentEvangelism = [PriestSpell _evangelismForEntity:self.caster];
    ArchangelEffect *currentArchangel = [PriestSpell _archangelForEntity:self.caster];
    if ( currentArchangel )
    {
        if ( .5 < ( [[NSDate date] timeIntervalSinceDateMinusPauseTime:currentArchangel.startDate] / currentArchangel.duration ) )
            priority |= ChargePriority;
    }
    else if ( currentEvangelism )
    {
        if ( currentEvangelism.currentStacks.integerValue >= 5 )
            ;
        else
            priority |= ChargePriority;
    }
    else
        priority |= ChargePriority;
    
    return priority;
}

@end
