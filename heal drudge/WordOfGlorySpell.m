//
//  WordOfGlorySpell.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

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
        self.cooldown = @0;
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

// this needs to be done in "hit" instead of "started", due to prot having instant cast, but not others
- (BOOL)addModifiers:(NSMutableArray *)modifiers
{
    if ( self.caster.currentAuxiliaryResources.doubleValue < 1 )
#warning ss
        [NSException raise:@"WordOfGloryHasNoAuxResourcesException" format:@"%@ only has %@ aux resources!",self.caster,self.caster.currentAuxiliaryResources];
    NSNumber *resourcesToConsume = self.caster.currentAuxiliaryResources;
    if ( self.caster.currentAuxiliaryResources.doubleValue >= 3 )
        resourcesToConsume = @3;
    self.caster.currentAuxiliaryResources = @( self.caster.currentAuxiliaryResources.integerValue - resourcesToConsume.integerValue );
    PHLog(self,@"%@ is consuming %@ resources casting %@",self.caster,resourcesToConsume,self);
    
    EventModifier *mod = [EventModifier new];
    mod.healingIncrease = @( resourcesToConsume.doubleValue * self.healing.doubleValue );
    [modifiers addObject:mod];
    
    return YES;
}

- (NSArray *)hdClasses
{
    return @[ [HDClass holyPaladin], [HDClass protPaladin] ];
}

- (AISpellPriority)aiSpellPriority
{
    AISpellPriority priority = CastWhenSomeoneNeedsHealingPriority |
                                CastWhenTankNeedsHealingPriority |
                                CastOnIdealAuxResourceAvailablePriority |
                                CastWhenInFearOfDyingPriority;
    return priority;
}

@end
