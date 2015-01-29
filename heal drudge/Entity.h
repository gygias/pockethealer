//
//  Entity.h
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ModelBase.h"

@class Encounter;
@class Ability;
@class Effect;
@class Spell;
@class HDClass;
@class WoWRealm;
@class Guild;

// represents a thing in the world, or an 'instance' of a character
@interface Entity : ModelBase

// combat state
@property Encounter *encounter;
@property Entity *target;
@property (nonatomic) HDClass *hdClass;
- (void)initializeSpells;
@property NSNumber *currentHealth;
@property (readonly) NSNumber *currentAbsorb; // synthesized from effects
@property NSNumber *currentResources;
@property NSNumber *currentAuxiliaryResources;
@property NSNumber *maxAuxiliaryResources;
@property Spell *castingSpell;
@property (readonly) NSArray *statusEffects;
@property BOOL isDead;
@property BOOL isPlayer;
@property BOOL isPlayingPlayer;
@property BOOL isEnemy;
@property (nonatomic,retain) dispatch_queue_t periodicEffectQueue;
@property BOOL stopped;
@property NSArray *spells;

@property NSMutableArray *emittingSounds;

@property dispatch_source_t resourceGenerationSource;
@property NSDate *lastResourceGenerationDate;

//@property dispatch_source_t automaticAbilitySource;
//@property NSDate *lastAutomaticAbilityDate;

// instead of simply setting the property, say a holy priest
// being dealt a killing blow can trigger spirit of redemption
- (void)handleDeathOfEntity:(Entity *)dyingEntity fromSpell:(Spell *)spell;

// called when a spell is in the process of "going off", to accumulate modifications from effects, etc.
- (BOOL)validateSpell:(Spell *)spell asSource:(BOOL)asSource otherEntity:(Entity *)otherEntity message:(NSString **)messagePtr invalidDueToCooldown:(BOOL *)invalidDueToCooldown;

- (NSNumber *)castSpell:(Spell *)spell withTarget:(Entity *)target;

// called when a spell begins casting, to accumulate modifiers from effects, etc.
- (BOOL)handleSpellStart:(Spell *)spell asSource:(BOOL)asSource otherEntity:(Entity *)otherEntity modifiers:(NSMutableArray *)modifiers;
- (BOOL)handleSpell:(Spell *)spell asSource:(BOOL)asSource otherEntity:(Entity *)otherEntity modifiers:(NSMutableArray *)modifiers;
- (void)handleIncomingDamage:(NSNumber *)incomingDamage;
- (BOOL)handleSpellEnd:(Spell *)spell asSource:(BOOL)asSource otherEntity:(Entity *)otherEntity modifiers:(NSMutableArray *)modifiers;

//- (NSNumber *)handleIncomingDamage:(NSNumber *)damage;

// now takes source as a reminder that it's a required property in this
// ios style of +new, set all the properties..
- (void)addStatusEffect:(Effect *)statusEffect source:(Entity *)source;
- (void)consumeStatusEffect:(Effect *)effect absolute:(BOOL)absolute;
- (void)consumeStatusEffect:(Effect *)effect;
- (void)consumeStatusEffectNamed:(NSString *)statusEffectName;

- (void)prepareForEncounter:(Encounter *)encounter;
- (void)beginEncounter:(Encounter *)encounter;
- (void)updateEncounter:(Encounter *)encounter;
- (void)endEncounter:(Encounter *)encounter;

// character


// kvc stuff
+ (NSArray *)primaryStatKeys;
+ (NSArray *)secondaryStatKeys;
+ (NSArray *)tertiaryStatKeys;

- (NSNumber *)primaryStat;

@property NSString *name;
@property NSString *titleAndName;
@property WoWRealm *realm;
@property UIImage *image;
@property Guild *guild;
@property NSNumber *level;
@property NSNumber *race;
@property NSNumber *gender;
@property NSNumber *achievementPoints;
@property NSNumber *averageItemLevel;
@property NSNumber *averageItemLevelEquipped;
@property NSNumber *honorableKills;
@property NSNumber *guildRank;

// synthesized
@property (nonatomic,readonly) NSNumber *health;
@property (nonatomic,readonly) NSNumber *baseMana; // ??
@property (nonatomic,readonly) NSNumber *spellPower; // ??
@property (nonatomic,readonly) NSNumber *attackPower; // ??

// stats
@property NSNumber *stamina;
@property NSNumber *power; // "resource"
// primary
@property NSNumber *strength;
@property NSNumber *agility;
@property NSNumber *intellect;
// secondary
@property NSNumber *spirit;
@property NSNumber *critRating;
@property NSNumber *hasteRating;
@property NSNumber *masteryRating;
// tertiary
@property NSNumber *versatilityRating;
@property NSNumber *multistrikeRating;
@property NSNumber *leechRating;
// avoidance
@property NSNumber *armor;
@property NSNumber *parryRating;
@property NSNumber *dodgeRating;
@property NSNumber *blockRating;

// XXX
@property NSString *specName;
@property NSString *offspecName;

@property NSDate *nextGlobalCooldownDate;
@property NSTimeInterval currentGlobalCooldownDuration;

@property NSNumber *lastHealth;

@end

