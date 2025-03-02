//
//  Spell.h
//  heal drudge
//
//  Created by david on 12/29/14.
//  Copyright (c) 2014 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <UIKit/UIKit.h>

#import "Entity.h"
#import "ImageFactory.h"

@class Entity;

extern const NSString *SpellLevelLow;
extern const NSString *SpellLevelMedium;
extern const NSString *SpellLevelHigh;

typedef NS_OPTIONS(NSInteger, SpellSchool) {
    AnySchool       = 0,
    PhysicalSchool  = 1 << 0,
    HolySchool      = 1 << 1,
    ShadowSchool    = 1 << 2,
    NatureSchool    = 1 << 3,
    FireSchool      = 1 << 4,
    FrostSchool     = 1 << 5,
    MagicSchool     = HolySchool | ShadowSchool | NatureSchool | FireSchool | FrostSchool
};

typedef NS_ENUM(NSInteger, SpellType) {
    BeneficialSpell = 0,
    DetrimentalSpell = 1,
    BeneficialOrDeterimentalSpell
};

// "someone"/"anyone"
typedef NS_OPTIONS(NSInteger, AISpellPriority) {
    NoPriority = 0,
    FillerPriority                                          = 1 << 0,
    
    CastWhenSomeoneNotToppedOffPriority                     = 1 << 1,
    CastWhenNotToppedOffPriority                            = 1 << 2,
    CastWhenTankNotToppedOffPriority                        = 1 << 3,
    CastWhenAnyoneNotToppedOff                              = CastWhenSomeoneNotToppedOffPriority | CastWhenNotToppedOffPriority | CastWhenTankNotToppedOffPriority,
    
    ChargePriority                                          = 1 << 4, // e.g. smite, crusader strike
    ConsumeChargePriority                                   = 1 << 5, // e.g. evangelism
    PrecastOnMainTankPriority                               = 1 << 6,
    
    CastWhenSomeoneNeedsHealingPriority                     = 1 << 7,
    CastWhenINeedHealingPriority                            = 1 << 8,
    CastWhenTankNeedsHealingPriority                        = 1 << 9,
    CastWhenAnyoneNeedsHealing                              = CastWhenSomeoneNeedsHealingPriority | CastWhenINeedHealingPriority | CastWhenTankNeedsHealingPriority,
    
    CastWhenPartyNeedsHealing                               = 1 << 10,
    CastOnIdealAuxResourceAvailablePriority                 = 1 << 11,
    CastWhenDamageDoneIncreasedPriority                     = 1 << 12, // during hero
    CastWhenRaidNeedsHealing                                = 1 << 13,
    
    CastWhenSomeoneNeedsUrgentHealingPriority               = 1 << 14,
    CastWhenINeedUrgentHealingPriority                      = 1 << 15,
    CastWhenTankNeedsUrgentHealingPriority                  = 1 << 16,
    CastWhenAnyoneNeedsUrgentHealing                        = CastWhenSomeoneNeedsUrgentHealingPriority | CastWhenINeedUrgentHealingPriority | CastWhenTankNeedsUrgentHealingPriority,
    
    CastWhenRaidUrgentlyNeedsHealing                        = 1 << 17,
    
    CastBeforeSomeoneTakesLargePhysicalHit                  = 1 << 18,
    CastBeforeSomeoneTakesLargeMagicHit                     = 1 << 19,
    CastBeforeSomeoneTakesLargeHit                          = CastBeforeSomeoneTakesLargePhysicalHit | CastBeforeSomeoneTakesLargeMagicHit,
    CastBeforeLargePhysicalHitPriority                      = 1 << 20,
    CastBeforeLargeMagicHitPriority                         = 1 << 21,
    CastBeforeLargeHitPriority                              = CastBeforeLargePhysicalHitPriority | CastBeforeLargeMagicHitPriority,
    CastBeforeTankTakesLargePhysicalHit                     = 1 << 22,
    CastBeforeTankTakesLargeMagicHit                        = 1 << 23,
    CastBeforeTankTakesLargeHit                             = CastBeforeTankTakesLargePhysicalHit | CastBeforeTankTakesLargeMagicHit,
    CastBeforeAnyoneTakesLargePhysicalHit                   = CastBeforeTankTakesLargePhysicalHit | CastBeforeLargePhysicalHitPriority | CastBeforeSomeoneTakesLargePhysicalHit,
    CastBeforeAnyoneTakesLargeMagicHit                      = CastBeforeTankTakesLargeMagicHit | CastBeforeLargeMagicHitPriority | CastBeforeSomeoneTakesLargeMagicHit,
    CastBeforeAnyoneTakesLargeHit                           = CastBeforeTankTakesLargeHit | CastBeforeLargeHitPriority | CastBeforeSomeoneTakesLargeHit,
    CastBeforeLargePhysicalAOEPriority                      = 1 << 24,
    CastBeforeLargeMagicAOEPriority                         = CastBeforeLargePhysicalAOEPriority,
    CastBeforeLargeAOEPriority                              = CastBeforeLargePhysicalAOEPriority | CastBeforeLargeMagicAOEPriority,
    
    CastWhenOtherTankNeedsTauntOff                          = 1 << 25,
    
    CastWhenInFearOfDPSDyingPriority                        = 1 << 26,
    CastWhenInFearOfHealerDyingPriority                     = 1 << 27,
    CastWhenInFearOfTankDyingPriority                       = 1 << 28,
    CastWhenInFearOfSelfDyingPriority                       = 1 << 29,
    CastWhenInFearOfAnyoneDyingPriority                     = CastWhenInFearOfDPSDyingPriority | CastWhenInFearOfHealerDyingPriority | CastWhenInFearOfTankDyingPriority | CastWhenInFearOfSelfDyingPriority
};

typedef NS_ENUM(NSInteger, CooldownType) {
    CooldownTypeNone = 0,
    CooldownTypeMinor = 1,
    CooldownTypeMajor = 2
};

#define AI_MAJOR_COOLDOWN_COOLDOWN ( self.hdClass.isTank ? 10.0 : 60.0 )
#define AI_MINOR_COOLDOWN_COOLDOWN ( self.hdClass.isTank ? 5.0 : 20.0 )

@interface Spell : NSObject

+ (void)prewarmSpellClasses;

// initialized with caster, but not target, so that base stats can be displayed based
// on character stats
- (id)initWithCaster:(Entity *)caster;

- (BOOL)validateWithSource:(Entity *)source target:(Entity *)target message:(NSString * __strong *)message;

// state
//- (void)beginCastingWithTarget:(Character *)target;
// when a spell completes casting, the magic thing will call this on each target
- (BOOL)addModifiers:(NSMutableArray *)modifiers;
- (void)handleTickWithModifier:(EventModifier *)modifier firstTick:(BOOL)firstTick;
- (void)handleHitWithModifier:(EventModifier *)modifier;
- (void)handleEndWithModifier:(EventModifier *)modifier;

//- (void)endSpell:(id)entity;

// character, not class, because glyphs can add/remove spells
+ (NSArray *)castableSpellsForCharacter:(Entity *)player orderedByNames:(NSArray *)orderedByNames;

@property Entity *caster;
@property (nonatomic,retain) Entity *target;
@property BOOL inTransientStateExplosionMode; // see explanation in Effect/Entity validateSpell: definition

// static properties
@property NSString *name;
@property UIImage *image;
@property NSString *tooltip;
@property BOOL triggersGCD;
@property BOOL targeted;
@property BOOL cannotSelfTarget;
// instead of having damage(0) healing(+) denote beneficial,
// in order to model spells like holy nova which damage enemies and
// heal allies, this denotes which side of player/enemy the spell falls on
@property SpellType spellType;
// range required to begin casting
@property NSNumber *castableRange;
// range of spell at the point of impact, 0 for N/A
@property NSNumber *hitRange;
@property NSNumber *maxHitTargets; // e.g. holy nova "up to 5 targets within 12 yards"
@property CooldownType cooldownType;
@property NSNumber *grantsAuxResources;
@property BOOL isEmphasized; // draw glowing
@property NSDate *emphasisStopDate;

@property BOOL isChanneled;
@property NSNumber *channelTicks;

@property BOOL isPeriodic;
@property NSTimeInterval period;
@property NSNumber *periodicDamage;
@property NSNumber *periodicHeal;
@property NSNumber *periodicAbsorb;
@property NSTimeInterval periodicDuration;
@property BOOL periodicEffectChangesTargets;

// multi-target
@property BOOL affectsPartyOfTarget; // e.g. prayer of healing
@property BOOL isSmart; // can't think of a 'smart damage' spell off the top of my head, so for now this is probably simply 'smart heal'

@property BOOL canBeCastOnDeadEntities;

// sound emitted by caster
@property NSString *castSoundName;
// sound emitted by target
@property NSString *hitSoundName;

// this should be default
//@property BOOL affectsMainTarget;
@property BOOL affectsRandomMelee;
@property BOOL affectsRandomRange;

// semi-transient (properties affected by player stats only)
@property NSNumber *cooldown;
@property NSNumber *castTime;
@property NSNumber *manaCost;
@property NSNumber *auxiliaryResourceCost;
@property NSNumber *auxiliaryResourceIdealCost;
@property NSNumber *damage;
@property SpellSchool school;
@property NSString *level;
@property NSNumber *healing;
@property NSNumber *absorb;

// classes which have this spell
@property NSArray *hdClasses;

// ai
@property AISpellPriority aiSpellPriority;

// transient
@property (readonly) BOOL isOnCooldown;
@property NSDate *nextCooldownDate;
@property NSDate *lastCastStartDate;
@property NSDate *lastChannelStartDate;
@property NSTimeInterval lastCastEffectiveCastTime;

// is it spell or is it ability?
@property BOOL isLargePhysicalHit;
@property BOOL isLargeMagicHit;
@property BOOL isLargePhysicalAOE;
@property BOOL isLargeMagicAOE;

@end
