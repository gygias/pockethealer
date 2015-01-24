//
//  Enemy.h
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Entity.h"

@class Encounter;

@interface Enemy : Entity
{
    NSArray *_abilities;
}

@property (readonly) NSString *name;
@property NSNumber *health;

+ (Enemy *)randomEnemy;
- (NSArray *)abilityNames;
- (NSArray *)abilities;

- (BOOL)targetNextThreatWithEncounter:(Encounter *)encounter;

@end
