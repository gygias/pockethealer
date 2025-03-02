//
//  TemplarsVerdictSpell.m
//  heal drudge
//
//  Created by david on 2/16/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "TemplarsVerdictSpell.h"

@implementation TemplarsVerdictSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Templar's Verdict";
        self.image = [ImageFactory imageNamed:@"templars_verdict"];
        self.tooltip = @"A powerful weapon strike that deals 200% Physical damage.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @0;
        self.spellType = DetrimentalSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.auxiliaryResourceCost = @3;
        self.castTime = @0;
        self.manaCost = @(0.7 * caster.baseMana.floatValue);
        self.damage = @( 1.60 * caster.attackPower.floatValue );
        
        self.school = HolySchool;
        
        self.hitSoundName = @"templars_verdict_hit";
    }
    return self;
}

- (void)handleHitWithModifier:(EventModifier *)modifier
{
    if ( self.caster.currentAuxiliaryResources.doubleValue < 3 )
        [NSException raise:@"TVHasNoAuxResourcesException" format:@"%@ only has %@ aux resources!",self.caster,self.caster.currentAuxiliaryResources];
    NSNumber *resourcesToConsume = self.caster.currentAuxiliaryResources;
    if ( self.caster.currentAuxiliaryResources.doubleValue >= 3 )
        resourcesToConsume = @3;
    self.caster.currentAuxiliaryResources = @( self.caster.currentAuxiliaryResources.integerValue - resourcesToConsume.integerValue );
    PHLog(self,@"%@ is consuming %@ resources casting %@",self.caster,resourcesToConsume,self);
    // XXX mutable modifier?
}

- (NSArray *)hdClasses
{
    return @[ [HDClass retPaladin] ];
}

- (AISpellPriority)aiSpellPriority
{
    return ConsumeChargePriority;
}

@end
