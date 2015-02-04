//
//  Spell.m
//  heal drudge
//
//  Created by david on 12/29/14.
//  Copyright (c) 2014 Combobulated Software. All rights reserved.
//

#import "Logging.h"

#import "Spell.h"
#import "SpellPriv.h"

#import "Entity.h"

const NSString *SpellLevelLow = @"low";
const NSString *SpellLevelMedium = @"medium";
const NSString *SpellLevelHigh = @"high";

@implementation Spell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super init] )
    {
        if ( [[self hdClasses] containsObject:caster.hdClass] )
            PHLog(@"initializing %@'s %@",caster,self);
        else
            return nil;
        
        self.caster = caster;
        self.level = @"low";
        self.hitSoundName = @"heal_hit";
        self.castSoundName = @"nature_cast";
    }
    return self;
}

- (BOOL)validateWithSource:(Entity *)source target:(Entity *)target message:(NSString * __strong *)message
{
    return YES;
}

- (BOOL)handleStartWithSource:(Entity *)source target:(Entity *)target modifiers:(NSMutableArray *)modifiers
{
    return NO;
}

- (void)handleTickWithSource:(Entity *)source target:(Entity *)target modifiers:(NSMutableArray *)modifiers
{
}

- (void)handleHitWithSource:(Entity *)source target:(Entity *)target modifiers:(NSMutableArray *)modifiers
{
}

- (void)handleEndWithSource:(Entity *)source target:(Entity *)target
{
}

+ (NSArray *)castableSpellsForCharacter:(Entity *)player
{
    NSMutableArray *castableSpells = [NSMutableArray new];
    for ( NSString *spellName in [self _spellNames] )
    {
        Class spellClass = NSClassFromString(spellName);
        Spell *spell = [[spellClass alloc] initWithCaster:player];
        if ( spell )
            [castableSpells addObject:spell];
    }
    
    return castableSpells;
}

+ (NSArray *)_spellNames
{
    return @[
             @"PowerWordShieldSpell",
             @"HolyFireSpell",
             @"SmiteSpell",
             @"HealSpell",
             @"FlashHealSpell",
             @"ArchangelSpell",
             @"DivineStarSpell",
             @"PrayerOfMendingSpell",
             @"PrayerOfHealingSpell",
             @"PenanceSpell",
             @"PainSuppressionSpell",
             @"PowerWordBarrierSpell",
             
             @"DivineProtectionSpell",
             @"SacredShieldSpell",
             @"CrusaderStrikeSpell",
             @"GuardianOfAncientKingsSpell",
             @"ShieldOfTheRighteousSpell",
             @"WordOfGlorySpell",
             @"AvengersShieldSpell",
             @"LayOnHandsSpell",
             @"JudgementSpell",
             @"ArdentDefenderSpell",
             
             @"HolyLightSpell",
             @"FlashOfLightSpell",
             @"HolyShockSpell",
             @"LightOfDawnSpell",
             @"DevotionAuraSpell",
             @"AvengingWrathSpell",
             @"HandOfSacrificeSpell",
             
             @"HealingTideTotemSpell"
             ];
}

- (BOOL)isOnCooldown
{
    NSDate *storedDate = self.nextCooldownDate;
    return storedDate && [[NSDate date] timeIntervalSinceDate:storedDate] <= 0;
}

@end
