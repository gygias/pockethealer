//
//  Advisor.h
//  pockethealer
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
    UIExplanationEnd
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
typedef BOOL (^AdvanceExplanationBlock)(void);
#define AUTO_ADVANCE_DELAY 6.0
@property (copy) AdvanceExplanationBlock advanceExplanationBlock;
@property (copy) NSDate *lastAdvanceExplanationDate;
@property AdvisorUIExplanationState currentExplanationState;

@property BOOL didExplainTank;

@property BOOL didExplainArchangel;
//@property BOOL didExplainEmphasis;
@property BOOL didExplainOOM;
@property BOOL didExplainNeedsHealing;

@end
