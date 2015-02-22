//
//  Effect.h
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <UIKit/UIKit.h>
#import "EventModifier.h"

@class Spell;
@class Entity;
@class Encounter;

typedef NS_ENUM(NSInteger, EffectSchool) {
    StandardEffect      = 0,
    MagicEffect         = 1,
    CurseEffect         = 2,
    PoisonEffect        = 3,
    DiseaseEffect       = 4
};

typedef NS_ENUM(NSInteger, EffectType) {
    BeneficialEffect = 0,
    DetrimentalEffect = 1,
    BeneficialOrDetrimentalEffect
};

typedef void(^EffectTimeoutBlock)();

@interface Effect : NSObject

@property EffectSchool school;
@property EffectType effectType;
@property NSString *name;
@property NSString *tooltip;
@property Entity *owner;
@property Entity *source; // e.g., priests may reduce weakened soul duration with glyphs
@property Spell *sourceSpell;
@property (nonatomic,copy) EffectTimeoutBlock timeoutHandler;
@property NSNumber *maxStacks;
@property NSNumber *currentStacks;
@property NSNumber *tauntAtStacks;
@property BOOL stacksAreInvisible;
@property NSDate *startDate;
@property NSTimeInterval duration;
@property UIImage *image;
@property BOOL drawsInFrame;
@property BOOL isBeneficial;
@property BOOL isEmphasized; // e.g. boss's main big debuff on players
@property NSString *hitSoundName;

@property NSNumber *healingOnDamage;
@property BOOL healingOnDamageIsOneShot;
@property NSNumber *absorb;

// sacred shield...
@property NSNumber *periodicTick;
@property BOOL canAffectOneTargetSimultaneously;
@property dispatch_source_t periodicTickSource;

- (void)addStack;
- (void)addStacks:(NSUInteger)nStacks;
- (void)removeStack;

// other spells
// COMBOBULATION: spell.target is UNSET or INVALID when this method is called, use the target
// AFAIK source is always spell.caster and is redundant, but hesitant to remove it yet.
- (BOOL)validateSpell:(Spell *)spell asEffectOfSource:(BOOL)asEffectOfSource source:(Entity *)source target:(Entity *)target message:(NSString * __strong *)message;
- (BOOL)addModifiersWithSpell:(Spell *)spell modifiers:(NSMutableArray *)modifiers;
- (void)handleSpell:(Spell *)spell modifier:(EventModifier *)modifier;

// our own periodic tick
- (void)handleTick:(BOOL)isInitialTick;

- (BOOL)validateOwner:(Entity *)owner;
- (void)handleStart;
- (void)handleConsumptionWithOwner:(Entity *)owner;
- (void)handleRemovalWithOwner:(Entity *)owner;

@end
