//
//  PlayerAndTargetView.h
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Entity;

@interface PlayerAndTargetView : UIView

@property Entity *player;
@property Entity *target;

@end