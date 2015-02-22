//
//  CombatLog.m
//  heal drudge
//
//  Created by david on 2/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "CombatLog.h"

#import "Entity.h"

@interface CombatLogItem : NSObject
@property Spell *spell;
@property Entity *target;
@property NSNumber *effectiveDamage;
@property NSNumber *effectiveHealing;
@end

@implementation CombatLogItem
@end

@implementation CombatLog

- (id)init
{
    if ( self = [super init] )
    {
        _events = [NSMutableArray new];
        _eventsBySource = [NSMutableDictionary new];
        _totalHealingBySource = [NSMutableDictionary new];
        _totalHealingTakenByTarget = [NSMutableDictionary new];
        _totalDamageBySource = [NSMutableDictionary new];
        _totalOverhealBySource = [NSMutableDictionary new];
    }
    return self;
}

- (void)addSpellEvent:(Spell *)spell target:(Entity *)target effectiveDamage:(NSNumber *)effectiveDamage effectiveHealing:(NSNumber *)effectiveHealing effectiveOverheal:(NSNumber *)effectiveOverheal
{
//#define SAVE_EVENTS
#ifdef SAVE_EVENTS
    CombatLogItem *logItem = [CombatLogItem new];
    logItem.spell = spell;
    logItem.target = target;
    logItem.effectiveDamage = effectiveDamage;
    logItem.effectiveHealing = effectiveHealing;
    [_events addObject:logItem];
    
    NSMutableArray *eventsForSource = [_eventsBySource objectForKey:spell.caster.name]; // XXX todo
    if ( ! eventsForSource ) eventsForSource = [NSMutableArray new];
    [eventsForSource addObject:logItem];
    [_eventsBySource setObject:eventsForSource forKey:spell.caster.name]; // XXX
#endif
    
    if ( effectiveHealing.doubleValue )
    {
        NSNumber *totalHealing = [_totalHealingBySource objectForKey:spell.caster.name];
        totalHealing = @( totalHealing.doubleValue + effectiveHealing.doubleValue );
        [_totalHealingBySource setObject:totalHealing forKey:spell.caster.name];
        
        NSNumber *totalHealingTaken = [_totalHealingTakenByTarget objectForKey:target.name];
        totalHealingTaken = @( totalHealingTaken.doubleValue + effectiveHealing.doubleValue );
        [_totalHealingTakenByTarget setObject:totalHealingTaken forKey:target.name];
        
        if ( spell.caster.isPlayer )
            _totalHealingForRaid = @( _totalHealingForRaid.doubleValue + effectiveHealing.doubleValue );
    }
    
    if ( effectiveOverheal.doubleValue )
    {
        NSNumber *totalOverheal = [_totalOverhealBySource objectForKey:spell.caster.name];
        totalOverheal = @( totalOverheal.doubleValue + effectiveOverheal.doubleValue );
        [_totalOverhealBySource setObject:totalOverheal forKey:spell.caster.name];
    }
    
    if ( effectiveDamage.doubleValue )
    {
        NSNumber *totalDamage = [_totalDamageBySource objectForKey:spell.caster.name];
        totalDamage = @( totalDamage.doubleValue + effectiveDamage.doubleValue );
        [_totalDamageBySource setObject:totalDamage forKey:spell.caster.name];
        
        if ( spell.caster.isPlayer )
            _totalDamageForRaid = @( _totalDamageForRaid.doubleValue + effectiveDamage.doubleValue );
    }
}

- (NSNumber *)totalHealingForEntity:(Entity *)entity
{
    return [_totalHealingBySource objectForKey:entity.name];
}

- (NSNumber *)totalOverhealForEntity:(Entity *)entity
{
    return [_totalOverhealBySource objectForKey:entity.name];
}

- (NSNumber *)totalHealingTakenForEntity:(Entity *)entity
{
    return [_totalHealingTakenByTarget objectForKey:entity.name];
}

- (NSNumber *)totalDamageForEntity:(Entity *)entity
{
    return [_totalDamageBySource objectForKey:entity.name];
}

- (NSNumber *)totalHealingForRaid
{
    return _totalHealingForRaid;
}

- (NSNumber *)totalDamageForRaid
{
    return _totalDamageForRaid;
}

@end
