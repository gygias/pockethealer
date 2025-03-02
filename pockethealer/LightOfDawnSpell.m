//
//  LightOfDawnSpell.m
//  heal drudge
//
//  Created by david on 1/29/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "LightOfDawnSpell.h"

#import "EventModifier.h"

@implementation LightOfDawnSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Holy Shock";
        self.image = [ImageFactory imageNamed:@"light_of_dawn"];
        self.tooltip = @"Consumes up to 3 Holy Power to unleash a wave of healing energy, healing 6 injured allies within 30 yards for up to [ 3 + 73.5% of Spell Power ].";
        self.triggersGCD = YES;
        self.targeted = NO;
        self.cooldown = @0;
        self.spellType = BeneficialSpell;
        self.castableRange = @40;
        self.hitRange = @30;
        self.maxHitTargets = @6;
        
        self.castTime = @1.5;
        self.manaCost = @0;
        self.damage = @0;
        self.healing = @( 3 + .735 * [caster.spellPower floatValue] );
        self.auxiliaryResourceCost = @1;
        self.auxiliaryResourceIdealCost = @3;
        self.absorb = @0;
        
        self.school = HolySchool;
        
        self.castSoundName = @"light_of_dawn_cast";
    }
    return self;
}

// this needs to be done in "hit" instead of "started", due to prot having instant cast, but not others
- (BOOL)addModifiers:(NSMutableArray *)modifiers
{
    if ( self.caster.currentAuxiliaryResources.doubleValue < 1 )
        [NSException raise:@"WordOfGloryHasNoAuxResourcesException" format:@"%@ only has %@ aux resources!",self.caster,self.caster.currentAuxiliaryResources];
    NSNumber *resourcesToConsume = self.caster.currentAuxiliaryResources;
    if ( self.caster.currentAuxiliaryResources.doubleValue >= 3 )
        resourcesToConsume = @3;
    self.caster.currentAuxiliaryResources = @( self.caster.currentAuxiliaryResources.integerValue - resourcesToConsume.integerValue );
    PHLog(self,@"%@ is consuming %@ resources casting %@",self.caster,resourcesToConsume,self);
    
    EventModifier *mod = [EventModifier new];
    mod.healingIncreasePercentage = @( resourcesToConsume.doubleValue * self.healing.doubleValue );
    [modifiers addObject:mod];
    return YES;
}

- (NSArray *)hdClasses
{
    return @[ [HDClass holyPaladin] ];
}

- (AISpellPriority)aiSpellPriority
{
    return CastWhenRaidNeedsHealing;
}

@end
