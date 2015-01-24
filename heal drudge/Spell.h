//
//  Spell.h
//  heal drudge
//
//  Created by david on 12/29/14.
//  Copyright (c) 2014 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Character.h"
#import "ImageFactory.h"

@class Entity;

typedef NS_ENUM(NSInteger, DamageType) {
    HolyDamage      = 0,
    ShadowDamage    = 1,
    NatureDamage    = 2,
    FireDamage      = 3,
    FrostDamage     = 4,
    PhysicalDamage  = 5
};

@interface Spell : NSObject

// initialized with caster, but not target, so that base stats can be displayed based
// on character stats
- (id)initWithCaster:(Character *)caster;

// state
//- (void)beginCastingWithTarget:(Character *)target;
// when a spell completes casting, the magic thing will call this on each target
- (void)hitWithSource:(Entity *)source target:(Entity *)target;
//- (void)endSpell:(id)entity;

// character, not class, because glyphs can add/remove spells
+ (NSArray *)castableSpellNamesForCharacter:(Character *)character;

@property Character *caster;

// static properties
@property NSString *name;
@property UIImage *image;
@property NSString *tooltip;
@property BOOL triggersGCD;
@property BOOL targeted;
// instead of having damage(0) healing(+) denote beneficial,
// in order to model spells like holy nova which damage enemies and
// heal allies, this denotes which side of player/enemy the spell falls on
@property BOOL isBeneficial;
// range required to begin casting
@property NSNumber *castableRange;
// range of spell at the point of impact, 0 for N/A
@property NSNumber *hitRange;

@property BOOL isChanneled;
@property NSNumber *channelTime;

@property BOOL isPeriodic;
@property NSTimeInterval period;
@property NSNumber *periodicDamage;
@property DamageType periodicDamageType;
@property NSNumber *periodicHeal;
@property NSNumber *periodicAbsorb;
@property NSTimeInterval periodicDuration;
@property BOOL periodicEffectChangesTargets;

@property BOOL canBeCastOnDeadPlayers;

// this should be default
//@property BOOL affectsMainTarget;
@property BOOL affectsRandomMelee;
@property BOOL affectsRandomRange;

// semi-transient (properties affected by player stats only)
@property NSNumber *cooldown;
@property double castTime;
@property NSNumber *manaCost;
@property NSNumber *damage;
@property DamageType damageType;
@property NSNumber *healing;
@property NSNumber *absorb;

// classes which have this spell
@property NSArray *hdClasses;

// transient
@property NSDate *nextCooldownDate;
@property NSDate *lastCastStartDate;
@property NSDate *lastChannelStartDate;

@end
