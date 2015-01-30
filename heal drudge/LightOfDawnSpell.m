//
//  LightOfDawnSpell.m
//  heal drudge
//
//  Created by david on 1/29/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

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
- (void)handleHitWithSource:(Entity *)source target:(Entity *)target modifiers:(NSMutableArray *)modifiers
{
    if ( source.currentAuxiliaryResources.doubleValue < 1 )
#warning ss
        [NSException raise:@"WordOfGloryHasNoAuxResourcesException" format:@"%@ only has %@ aux resources!",source,source.currentAuxiliaryResources];
    NSNumber *resourcesToConsume = source.currentAuxiliaryResources;
    if ( source.currentAuxiliaryResources.doubleValue >= 3 )
        resourcesToConsume = @3;
    source.currentAuxiliaryResources = @( source.currentAuxiliaryResources.integerValue - resourcesToConsume.integerValue );
    NSLog(@"%@ is consuming %@ resources casting %@",source,resourcesToConsume,self);
    
    EventModifier *mod = [EventModifier new];
    mod.healingIncreasePercentage = @( resourcesToConsume.doubleValue * self.healing.doubleValue );
    [modifiers addObject:mod];
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
