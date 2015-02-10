//
//  ShieldOfTheRighteousSpell.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "SpellPriv.h"

#import "ShieldOfTheRighteousSpell.h"

#import "ShieldOfTheRighteousEffect.h"
#import "BastionOfGloryEffect.h"

@implementation ShieldOfTheRighteousSpell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Shield of the Righteous";
        self.image = [ImageFactory imageNamed:@"shield_of_the_righteous"];
        self.tooltip = @"Raise your shield. Procs physical damage reduction and Bastion of Glory.";
        self.triggersGCD = YES;
        self.targeted = YES;
        self.cooldown = @1.5;
        self.spellType = DetrimentalSpell;
        self.castableRange = @40;
        self.hitRange = @0;
        
        self.castTime = @0;
        self.manaCost = @0;
        self.auxiliaryResourceCost = @3;
        self.damage = @( 1.92 * caster.attackPower.doubleValue );
        self.healing = @0;
        self.absorb = @0;
        
        self.school = HolySchool;
        
        self.hitSoundName = @"shield_of_the_righteous_hit";
    }
    return self;
}

- (void)handleHitWithModifier:(EventModifier *)modifier
{
    if ( self.caster.currentAuxiliaryResources.doubleValue < 1 )
#warning ss
        [NSException raise:@"WordOfGloryHasNoAuxResourcesException" format:@"%@ only has %@ aux resources!",self.caster,self.caster.currentAuxiliaryResources];
    NSNumber *resourcesToConsume = self.caster.currentAuxiliaryResources;
    if ( self.caster.currentAuxiliaryResources.doubleValue >= 3 )
        resourcesToConsume = @3;
    self.caster.currentAuxiliaryResources = @( self.caster.currentAuxiliaryResources.integerValue - resourcesToConsume.integerValue );
    PHLog(self,@"%@ is consuming %@ resources casting %@",self.caster,resourcesToConsume,self);
    
    ShieldOfTheRighteousEffect *sotr = [ShieldOfTheRighteousEffect new];
    sotr.holyPower = resourcesToConsume;
    [self.caster addStatusEffect:sotr source:self.caster];
    
    BastionOfGloryEffect *bog = [self _existingEffectWithClass:[BastionOfGloryEffect class]];
    if ( bog )
        [bog addStack];
    else
    {
        bog = [BastionOfGloryEffect new];
        [self.caster addStatusEffect:bog source:self.caster];
    }
}

- (NSArray *)hdClasses
{
    return @[ [HDClass protPaladin] ];
}

- (AISpellPriority)aiSpellPriority
{
    AISpellPriority defaultPriority = FillerPriotity | CastBeforeLargeHitPriority;
    return defaultPriority;
}

@end
