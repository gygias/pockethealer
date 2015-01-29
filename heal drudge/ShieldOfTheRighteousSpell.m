//
//  ShieldOfTheRighteousSpell.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

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

- (void)handleHitWithSource:(Entity *)source target:(Entity *)target modifiers:(NSArray *)modifiers
{
    ShieldOfTheRighteousEffect *sotr = [ShieldOfTheRighteousEffect new];
    sotr.holyPower = source.currentAuxiliaryResources;
    NSLog(@"%@ has lost their aux resources due to %@ being cast",source,self);
    source.currentAuxiliaryResources = @0;
    [source addStatusEffect:sotr source:source];
    
    BastionOfGloryEffect *bog = [self _existingBastionOfGloryEffect];
    if ( bog )
        [bog addStack];
    else
    {
        bog = [BastionOfGloryEffect new];
        [source addStatusEffect:bog source:source];
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
