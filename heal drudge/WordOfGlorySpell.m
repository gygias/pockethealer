//
//  WordOfGlorySpell.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "WordOfGlorySpell.h"

#import "EventModifier.h"

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

- (BOOL)handleStartWithSource:(Entity *)source target:(Entity *)target modifiers:(NSMutableArray *)modifiers
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
    return YES;
}

- (NSArray *)hdClasses
{
    return @[ [HDClass holyPaladin], [HDClass protPaladin] ];
}

- (AISpellPriority)aiSpellPriority
{
    AISpellPriority priority = CastOnIdealAuxResourceAvailablePriority | CastWhenInFearOfDyingPriority | CastWhenSourceNeedsHealingPriority;
    return priority;
}

@end
