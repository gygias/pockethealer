//
//  Entity.h
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Encounter;
@class Ability;
@class Effect;
@class Spell;

// represents a thing in the world, or an 'instance' of a character
@interface Entity : NSObject

// combat state
@property Entity *target;
@property NSNumber *currentHealth;
@property NSNumber *currentAbsorb; // this should be an array of effects, not a single value
@property NSNumber *currentResources;
@property NSArray *statusEffects;
@property BOOL isDead;
@property (nonatomic,retain) dispatch_queue_t periodicEffectQueue;
@property BOOL stopped;

// instead of simply setting the property, say a holy priest
// being dealt a killing blow can trigger spirit of redemption
- (void)handleDeathFromAbility:(Ability *)ability;

- (BOOL)validateSpell:(Spell *)spell withSource:(Entity *)source message:(NSString **)messagePtr;

- (void)addStatusEffect:(Effect *)statusEffect;
- (void)removeStatusEffect:(Effect *)effect;
- (void)removeStatusEffectNamed:(NSString *)statusEffectName;

- (void)beginEncounter:(Encounter *)encounter;
- (void)updateEncounter:(Encounter *)encounter;
- (void)endEncounter:(Encounter *)encounter;

@end

