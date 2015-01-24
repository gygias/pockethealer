//
//  Encounter.h
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Player.h"
#import "Enemy.h"
#import "Raid.h"
#import "Ability.h"

typedef void(^EncounterUpdatedBlock)(Encounter *);

@interface Encounter : NSObject
{
    dispatch_queue_t _encounterQueue;
    dispatch_source_t _encounterTimer;
}

@property Player *player;
@property Raid *raid;
@property NSArray *enemies;
@property NSDate *startDate;
@property (nonatomic,copy) EncounterUpdatedBlock encounterUpdatedHandler;

- (void)start;

// called by entities when the a timed spell goes off
- (void)handleAbility:(Ability *)ability source:(Entity *)source target:(Entity *)target periodicTick:(BOOL)periodicTick;
- (void)handleSpell:(Spell *)ability source:(Entity *)source target:(Entity *)target periodicTick:(BOOL)periodicTick;

@end

