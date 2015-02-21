//
//  Entity.h
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <UIKit/UIKit.h>

#import "ModelBase.h"

@class Encounter;
@class Ability;
@class Effect;
@class Spell;
@class HDClass;
@class WoWRealm;
@class Guild;
@class Event;
@class EventModifier;

typedef void(^ScheduledSpellBlock)(Spell *, NSDate *);

// represents a thing in the world, or an 'instance' of a character
@interface Entity : ModelBase

// combat state
@property Encounter *encounter;
@property Entity *target;
@property (nonatomic) HDClass *hdClass;
- (void)initializeSpells;
@property NSNumber *currentHealth;
@property (readonly) NSNumber *currentHealthPercentage;
@property (readonly) NSNumber *currentAbsorb; // synthesized from effects
@property NSNumber *currentResources;
@property (readonly) NSNumber *currentResourcePercentage;
@property NSNumber *currentAuxiliaryResources;
@property NSNumber *maxAuxiliaryResources;
@property NSString *auxResourceName;
- (void)addAuxResources:(NSNumber *)addedResources;
@property Spell *castingSpell;
@property Spell *enqueuedSpell;
@property (readonly) NSArray *statusEffects;
@property BOOL isDead;
@property BOOL isPlayer;
@property BOOL isPlayingPlayer;
@property BOOL isEnemy;
@property BOOL stopped;
@property NSArray *spells;
@property (readonly) BOOL hasAggro;
@property NSDate *lastMinorCooldownUsedDate;
@property NSDate *lastMajorCooldownUsedDate;
@property double intelligence;

@property dispatch_source_t resourceGenerationSource;
@property NSDate *lastResourceGenerationDate;

//@property dispatch_source_t automaticAbilitySource;
//@property NSDate *lastAutomaticAbilityDate;

- (Spell *)spellWithClass:(Class)spellClass;
- (void)emphasizeSpell:(Spell *)spell duration:(NSTimeInterval)duration;

// instead of simply setting the property, say a holy priest
// being dealt a killing blow can trigger spirit of redemption
- (void)handleDeathOfEntity:(Entity *)dyingEntity fromSpell:(Spell *)spell;

// called when a spell is in the process of "going off", to accumulate modifications from effects, etc.
// COMBOBULATION: spell.target is UNSET and INVALID when this method is called, see Effect.h's validateSpell:
- (BOOL)validateSpell:(Spell *)spell asSource:(BOOL)asSource otherEntity:(Entity *)otherEntity message:(NSString * __strong *)messagePtr invalidDueToCooldown:(BOOL *)invalidDueToCooldown;

- (NSNumber *)castSpell:(Spell *)spell withTarget:(Entity *)target;

// called when a spell begins casting, to accumulate modifiers from effects, etc.
- (BOOL)handleSpellStart:(Spell *)spell modifiers:(NSMutableArray *)modifiers;
- (void)handleSpell:(Spell *)spell modifier:(EventModifier *)modifier;
- (void)handleIncomingDamageEvent:(Event *)damageEvent modifier:(EventModifier *)modifier;
- (void)handleIncomingDamageEvent:(Event *)damageEvent modifier:(EventModifier *)modifier avoidable:(BOOL)avoidable;
- (void)handleSpellEnd:(Spell *)spell modifier:(EventModifier *)modifier;

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
@property NSNumber *dodgeChance;
@property NSNumber *blockChance;

// XXX
@property NSString *specName;
@property NSString *offspecName;

@property NSDate *nextGlobalCooldownDate;
@property NSTimeInterval currentGlobalCooldownDuration;

@property NSNumber *lastHealth;

@property NSString *aggroSoundName;
@property NSString *hitSoundName;
@property NSString *deathSoundName;

@property (copy) ScheduledSpellBlock scheduledSpellHandler;
@property (readonly) BOOL isOnGlobalCooldown;

- (void)_doAutomaticStuff;

@property BOOL largePhysicalHitIncoming;
@property BOOL largeMagicHitIncoming;
@property BOOL largePhysicalAOEIncoming;
@property BOOL largeMagicAOEIncoming;
@property CGPoint location;
@property CGPoint currentMoveEndPoint;
@property NSDate *currentMoveStartDate;
@property NSTimeInterval currentMoveDuration;
@property NSDate *lastCommandedMoveDate;

- (void)moveToRandomLocation:(BOOL)animated;
- (void)moveToEntity:(Entity *)entity;
- (CGPoint)interpolatedLocation;
- (void)stopCurrentMove;

@end

