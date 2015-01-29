//
//  Spell.m
//  heal drudge
//
//  Created by david on 12/29/14.
//  Copyright (c) 2014 Combobulated Software. All rights reserved.
//

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
            NSLog(@"initializing %@'s %@",caster,self);
        else
            return nil;
        
        self.caster = caster;
        self.level = @"low";
        self.hitSoundName = @"heal_hit";
        self.castSoundName = @"nature_cast";
    }
    return self;
}

- (BOOL)validateWithSource:(Entity *)source target:(Entity *)target message:(NSString **)message
{
    return YES;
}

- (BOOL)handleStartWithSource:(Entity *)source target:(Entity *)target modifiers:(NSMutableArray *)modifiers
{
    return NO;
}

- (void)handleTickWithSource:(Entity *)source target:(Entity *)target modifiers:(NSArray *)modifiers
{
}

- (void)handleHitWithSource:(Entity *)source target:(Entity *)target modifiers:(NSArray *)modifiers
{
}

- (void)handleEndWithSource:(Entity *)source target:(Entity *)target modifiers:(NSArray *)modifiers
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
             
             @"HealingTideTotemSpell"
             ];
}

- (BOOL)isOnCooldown
{
    return self.nextCooldownDate && [[NSDate date] timeIntervalSinceDate:self.nextCooldownDate] < 0;
}

@end
