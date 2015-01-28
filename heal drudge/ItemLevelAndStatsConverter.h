//
//  ItemLevelAndStatsConverter.h
//  heal drudge
//
//  Created by david on 1/2/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Entity,HDClass;

@interface ItemLevelAndStatsConverter : NSObject

+ (void)assignStatsToEntity:(Entity *)entity basedOnAverageEquippedItemLevel:(NSNumber *)ilvl;

+ (NSNumber *)spellPowerFromIntellect:(NSNumber *)intellect;
+ (NSNumber *)healthFromStamina:(NSNumber *)stamina;
+ (NSNumber *)critBonusFromIntellect:(NSNumber *)intellect;
+ (NSNumber *)attackPowerBonusFromAgility:(NSNumber *)agility andStrength:(NSNumber *)strength;
+ (NSNumber *)critBonusFromAgility:(NSNumber *)agility;
+ (NSNumber *)maxPowerForClass:(HDClass *)hdClass;
+ (NSNumber *)castTimeWithBaseCastTime:(NSNumber *)baseCastTime entity:(Entity *)entity hasteBuffPercentage:(NSNumber *)hasteBuffPercentage;
+ (NSNumber *)globalCooldownWithEntity:(Entity *)entity hasteBuffPercentage:(NSNumber *)hasteBuffPercentage;
+ (NSNumber *)resourceGenerationWithEntity:(Entity *)entity timeInterval:(NSTimeInterval)timeInterval;

+ (NSNumber *)automaticHealValueWithEntity:(Entity *)entity;

@end
