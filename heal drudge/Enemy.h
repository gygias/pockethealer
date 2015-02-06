//
//  Enemy.h
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <Foundation/Foundation.h>

#import "Entity.h"

@class Encounter;
@class Raid;

@interface Enemy : Entity
{
    NSArray *_abilities;
}

- (id)initWithRaid:(Raid *)raid;

+ (Enemy *)randomEnemyWithRaid:(Raid *)raid;
- (NSArray *)abilityNames;
- (NSArray *)abilities;

- (BOOL)targetNextThreatWithEncounter:(Encounter *)encounter;

@end
