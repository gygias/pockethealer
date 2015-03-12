//
//  Advisor.h
//  heal drudge
//
//  Created by david on 2/7/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Encounter;
@class Spell;
@class Event;
@class EventModifier;
@class SpeechBubbleViewController;
@class PlayViewController;

typedef void (^AdvisorViewCallback)(id,SpeechBubbleViewController *);

typedef NS_ENUM(NSInteger,AdvisorMode)
{
    NoAdvisor = 0,
    HowToPlayAdvisorManual = 1,
    HowToPlayAdvisorAuto = 2,
    ClassAdvisor = 3
};

typedef NS_ENUM(NSInteger,AdvisorUIExplanationState)
{
    UIExplanationStateNone = 0,
    UIExplanationStart,
    UIExplanationEnemyAwaitingTouch,
    UIExplanationEnemyTouched,
    UIExplanationRaidFramesAwaitingTouch,
    UIExplanationRaidFramesTouched,
    UIExplanationPlayerAndTargetAwaitingPlayer,
    UIExplanationPlayerAndTargetPlayer,
    UIExplanationPlayerAndTargetAwaitingTarget,
    UIExplanationPlayerAndTargetTarget,
    UIExplanationPlayerAndTargetAwaitingTargetTarget,
    UIExplanationPlayerAndTargetTargetTarget,
    UIExplanationSpellBarAwaitingCastTimeSpell,
    UIExplanationSpellBarDidCastCastTimeSpell,
    UIExplanationCastBar,
    UIExplanationMiniMap,
    UIExplanationMeter,
    UIExplanationCommandButton,
    UIExplanationEnd = UIExplanationMeter
};

@interface Advisor : NSObject

@property (copy) AdvisorViewCallback callback;
@property Encounter *encounter;
@property PlayViewController *playView;

- (void)updateEncounter;
- (void)handleSpellStart:(Spell *)spell modifiers:(NSArray *)modifiers;
- (void)handleSpell:(Spell *)spell event:(Event *)event modifier:(EventModifier *)modifier;

@property AdvisorMode mode;

// how to play
@property BOOL didExplainUI;
@property BOOL isExplainingUI;
@property BOOL awaitingCastTimeSpell;
typedef BOOL (^AdvanceExplanationBlock)();
@property (copy) AdvanceExplanationBlock advanceExplanationBlock;
@property AdvisorUIExplanationState currentExplanationState;

@property BOOL didExplainTank;

@property BOOL didExplainArchangel;
//@property BOOL didExplainEmphasis;
@property BOOL didExplainOOM;
@property BOOL didExplainNeedsHealing;

@end
