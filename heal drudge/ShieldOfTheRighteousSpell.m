//
//  ShieldOfTheRighteousSpell.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Logging.h"

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
    ShieldOfTheRighteousEffect *sotr = [ShieldOfTheRighteousEffect new];
    sotr.holyPower = self.caster.currentAuxiliaryResources;
    PHLog(@"%@ has lost their aux resources due to %@ being cast",self.caster,self);
    self.caster.currentAuxiliaryResources = @0;
    [self.caster addStatusEffect:sotr source:self.caster];
    
    BastionOfGloryEffect *bog = [self _existingBastionOfGloryEffect];
    if ( bog )
        [bog addStack];
    else
    {
        bog = [BastionOfGloryEffect new];
        [self.caster addStatusEffect:bog source:self.caster];
    }
}

- (BastionOfGloryEffect *)_existingBastionOfGloryEffect
{
    __block BastionOfGloryEffect *bog = nil;
    [self.caster.statusEffects enumerateObjectsUsingBlock:^(Effect *effect, NSUInteger idx, BOOL *stop) {
        if ( [effect isKindOfClass:[BastionOfGloryEffect class]] )
        {
            bog = (BastionOfGloryEffect *)effect;
            *stop = YES;
            return;
        }
    }];
    return bog;
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
