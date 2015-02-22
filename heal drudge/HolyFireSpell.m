//
//  HolyFireSpell.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "HolyFireSpell.h"

#import "EvangelismEffect.h"
#import "ArchangelEffect.h"

@implementation HolyFireSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Holy Fire";
        self.image = [ImageFactory imageNamed:@"holy_fire"];
        self.tooltip = @"Consumes the enemy in Holy flames.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @10;
        self.castableRange = @30;
        self.castTime = @0;
        self.spellType = DetrimentalSpell;
        
        self.manaCost = @( 0.01 * caster.baseMana.floatValue );
        
        // hit
        self.damage = @( 1.3761 * caster.spellPower.floatValue );
        
        // periodic
        self.isPeriodic = YES;
        self.period = 1;
        self.periodicDuration = 9;
        self.periodicDamage = @( 0.03315 * caster.spellPower.floatValue );
        
        self.school = HolySchool;
    }
    return self;
}

- (void)handleTickWithModifier:(EventModifier *)modifier firstTick:(BOOL)firstTick
{
    if ( ! firstTick ) // TODO, "handleHit" not called for periodic spells, why isn't there an associated effect?
        return;
    
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
    return @[ [HDClass discPriest], [HDClass holyPriest] ];
}

- (AISpellPriority)aiSpellPriority
{
    AISpellPriority priority = NoPriority;
    EvangelismEffect *currentEvangelism = [PriestSpell _evangelismForEntity:self.caster];
    ArchangelEffect *currentArchangel = [PriestSpell _archangelForEntity:self.caster];
    if ( currentArchangel )
    {
        if ( .5 < ( [[NSDate date] timeIntervalSinceDate:currentArchangel.startDate] / currentArchangel.duration ) )
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
