//
//  Encounter.h
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <Foundation/Foundation.h>

#import "Entity.h"
#import "Enemy.h"
#import "Raid.h"
#import "Ability.h"
#import "Advisor.h"
#import "State.h"
#import "CombatLog.h"

typedef void(^EncounterUpdatedBlock)(Encounter *);
typedef void(^EnemyAbilityBlock)(Enemy *, Ability *);
typedef void(^DyingEntitiesBlock)(NSArray *);

typedef NS_ENUM(NSUInteger,PlayerCommand)
{
    NoCommand = 0,
    HeroCommand,
    StackInMeleeCommand,
    StackOnMeCommand,
    SpreadCommand,
    IdiotsCommand
};

@interface Encounter : NSObject
{
    dispatch_queue_t _encounterQueue;
    dispatch_source_t _encounterTimer;
}

@property Entity *player;
@property Raid *raid;
@property NSArray *enemies;
@property NSDate *startDate;
@property Advisor *advisor;
@property CombatLog *combatLog;
@property (nonatomic,copy) EncounterUpdatedBlock encounterUpdatedHandler;
@property (nonatomic,copy) EnemyAbilityBlock enemyAbilityHandler;

@property (nonatomic,readonly) dispatch_queue_t encounterQueue;

#define LOCATION_CACHE_MAX 50
@property NSMutableArray *cachedTankLocations;
@property NSMutableArray *cachedMeleeLocations;
@property NSMutableArray *cachedRangeLocations;

- (void)start;
- (void)pause;
- (void)end;

// called by entities when the a timed spell goes off
- (void)handleSpell:(Spell *)spell periodicTick:(BOOL)periodicTick isFirstTick:(BOOL)firstTick dyingEntitiesHandler:(DyingEntitiesBlock)dyingEntitiesHandler;

- (BOOL)doDamage:(Spell *)spell source:(Entity *)source target:(Entity *)target modifier:(EventModifier *)modifier periodic:(BOOL)periodic;
- (void)doHealing:(Spell *)spell source:(Entity *)source target:(Entity *)target modifier:(EventModifier *)modifier periodic:(BOOL)periodic;

- (BOOL)entityIsTargetedByEntity:(Entity *)entity;
- (Entity *)currentMainTank;

- (void)handleCommand:(PlayerCommand)command;

@end

