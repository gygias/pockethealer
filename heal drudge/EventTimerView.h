//
//  EventTimerView.h
//  heal drudge
//
//  Created by david on 1/31/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Spell;

@interface EventTimerView : UIView

@property NSArray *spellEvents;

- (void)addSpellEvent:(Spell *)spell date:(NSDate *)date;

@end
