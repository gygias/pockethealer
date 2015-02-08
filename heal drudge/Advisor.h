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

typedef void (^AdvisorViewCallback)(Entity *,SpeechBubbleViewController *);

@interface Advisor : NSObject

@property (copy) AdvisorViewCallback callback;
@property Encounter *encounter;

- (void)updateEncounter;
- (void)handleSpell:(Spell *)spell event:(Event *)event modifier:(EventModifier *)modifier;

@property BOOL didExplainTank;
@property BOOL didExplainArchangel;

@end
