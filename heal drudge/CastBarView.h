//
//  CastBarView.h
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Spell;

@interface CastBarView : UIView

@property Spell *castingSpell;
@property NSNumber *effectiveCastTime;

@end
