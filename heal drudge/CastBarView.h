//
//  CastBarView.h
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Spell;
@class Entity;

@interface CastBarView : UIView

@property Entity *castingEntity;
@property NSNumber *effectiveCastTime;

@end
