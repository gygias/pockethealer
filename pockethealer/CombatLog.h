//
//  CombatLog.h
//  heal drudge
//
//  Created by david on 2/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <Foundation/Foundation.h>

#import "Spell.h"

@interface CombatLog : NSObject
{
    NSMutableArray *_events;
    NSMutableDictionary *_eventsBySource;
    NSMutableDictionary *_totalHealingBySource;
    NSMutableDictionary *_totalHealingTakenByTarget;
    NSMutableDictionary *_totalDamageBySource;
    NSMutableDictionary *_totalDamageTakenByTarget;
    NSMutableDictionary *_totalOverhealBySource;
    NSNumber *_totalHealingForRaid;
    NSNumber *_totalDamageForRaid;
}

- (void)addSpellEvent:(Spell *)spell target:(Entity *)target effectiveDamage:(NSNumber *)effectiveDamage effectiveHealing:(NSNumber *)effectiveHealing effectiveOverheal:(NSNumber *)effectiveOverheal;

- (NSNumber *)totalHealingForEntity:(Entity *)entity;
- (NSNumber *)totalHealingTakenForEntity:(Entity *)entity;
- (NSNumber *)totalOverhealForEntity:(Entity *)entity;
- (NSNumber *)totalDamageForEntity:(Entity *)entity;
- (NSNumber *)totalDamageTakenForEntity:(Entity *)entity;
- (NSNumber *)totalHealingForRaid;

@end
