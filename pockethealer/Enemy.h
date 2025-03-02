//
//  Enemy.h
//  pockethealer
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <Foundation/Foundation.h>

#import "Entity.h"
#import "EntityPriv.h"

@class Encounter;
@class Raid;

@interface Enemy : Entity
{
    NSArray *_abilities;
}

@property float difficulty;
@property CGSize roomSize;

- (id)initWithRaid:(Raid *)raid difficulty:(float)difficulty;

+ (Enemy *)randomEnemyWithRaid:(Raid *)raid difficulty:(float)difficulty;
- (NSArray *)abilityNames;
- (NSArray *)abilities;

- (UIBezierPath *)roomPathWithRect:(CGRect)rect;
- (UIBezierPath *)tankAreaWithRect:(CGRect)rect;
- (UIBezierPath *)meleeAreaWithRect:(CGRect)rect;
- (UIBezierPath *)rangeAreaWithRect:(CGRect)rect;

- (BOOL)targetNextThreatWithEncounter:(Encounter *)encounter;

@end
