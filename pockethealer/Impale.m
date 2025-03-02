//
//  Impale.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "SpellPriv.h"

#import "Impale.h"
#import "OpenWoundsEffect.h"

#import "Enemy.h"

@implementation Impale

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.name = @"Impale";
        self.image = [ImageFactory imageNamed:@"hunger_for_blood"];
        self.tooltip = @"Kargath skewers an enemy, inflicting 38,392 Physical damage every 1 sec. for 8 sec. If the target survives, they take increased damage from consecutive Impales.";
        //self.triggersGCD = YES;
        self.cooldown = @30; // "roughly every 30 seconds" -icyveins
        self.isPeriodic = YES;
        self.period = 1;
        self.periodicDuration = 10;
        self.periodicDamage = @( 38392 * ( .5 + ((Enemy *)caster).difficulty ) );
        //self.hitRange = @7;
        self.targeted = YES;
        
        self.canTargetTanks = YES;
        
        self.isLargePhysicalHit = YES;
        
        self.abilityLevel = DangerousAbility;
        self.spellType = DetrimentalSpell;
        self.school = PhysicalSchool;
    }
    return self;
}

- (void)handleTickWithModifier:(EventModifier *)modifier firstTick:(BOOL)firstTick
{
    OpenWoundsEffect *existingOW = (OpenWoundsEffect *)[self _existingEffectWithClass:[OpenWoundsEffect class]];
    
    if ( firstTick )
    {
        if ( existingOW )
        {
            [existingOW addStack];
            existingOW.ignoreCastsAtDate = self.lastCastStartDate;
        }
        else
        {
            OpenWoundsEffect *ow = [OpenWoundsEffect new];
            ow.ignoreCastsAtDate = self.lastCastStartDate; // TODO this is working around the fact that the effect is applied when impale goes off, but there's no way to avoid having this OW buff damage from this impale
            [self.target addStatusEffect:ow source:self];
        }
    }
}

@end
