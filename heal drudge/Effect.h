//
//  Effect.h
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventModifier.h"

@class Spell;
@class Entity;

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

typedef void(^EffectEventHandler)(BOOL);

@interface Effect : NSObject

@property EffectSchool school;
@property EffectType effectType;
@property NSString *name;
@property NSString *tooltip;
@property Entity *source; // e.g., priests may reduce weakened soul duration with glyphs
@property NSNumber *maxStacks;
@property NSNumber *currentStacks;
@property BOOL stacksAreInvisible;
@property NSDate *startDate;
@property NSTimeInterval duration;
@property UIImage *image;
@property BOOL drawsInFrame;
@property BOOL isBeneficial;
@property BOOL isEmphasized; // e.g. boss's main big debuff on players

- (void)addStack;
- (void)addStacks:(NSUInteger)nStacks;
- (void)removeStack;
- (BOOL)validateSpell:(Spell *)spell asEffectOfSource:(BOOL)asSource source:(Entity *)source target:(Entity *)target message:(NSString **)message;
- (BOOL)handleSpellStarted:(Spell *)spell asSource:(BOOL)asSource source:(Entity *)source target:(Entity *)target modifier:(NSMutableArray *)modifiers handler:(EffectEventHandler)handler;
- (BOOL)handleSpell:(Spell *)spell asSource:(BOOL)asSource source:(Entity *)source target:(Entity *)target modifier:(NSMutableArray *)modifiers handler:(EffectEventHandler)handler;

@end
