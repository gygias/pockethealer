//
//  EventTimerView.h
//  heal drudge
//
//  Created by david on 1/31/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <UIKit/UIKit.h>

#import "PlayViewBase.h"

@class Spell;

@interface EventTimerView : PlayViewBase

@property NSArray *spellEvents;

- (void)addSpellEvent:(Spell *)spell date:(NSDate *)date;

@end
