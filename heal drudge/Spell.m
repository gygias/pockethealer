//
//  Spell.m
//  heal drudge
//
//  Created by david on 12/29/14.
//  Copyright (c) 2014 Combobulated Software. All rights reserved.
//

#import "Spell.h"
#import "SpellPriv.h"

#import "Player.h"

const NSString *SpellLevelLow = @"low";
const NSString *SpellLevelMedium = @"medium";
const NSString *SpellLevelHigh = @"high";

@implementation Spell

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super init] )
    {
        self.caster = caster;
        self.level = @"low";
        self.hitSoundName = @"heal_hit";
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

+ (NSArray *)castableSpellNamesForCharacter:(Player *)player
{
    NSMutableArray *castableSpells = [NSMutableArray new];
    for ( NSString *spellName in [self _spellNames] )
    {
        Class spellClass = NSClassFromString(spellName);
        Spell *spell = [[spellClass alloc] initWithCaster:player];
        if ( spell )
        {
            if ( [[spell hdClasses] containsObject:player.hdClass] )
            {
                NSLog(@"%@s can cast %@",player.hdClass,spell);
                [castableSpells addObject:spell];
            }
        }
        else
            NSLog(@"failed to initialize %@",spellName);
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
             
             @"HealingTideTotemSpell"
             ];
}

@end
