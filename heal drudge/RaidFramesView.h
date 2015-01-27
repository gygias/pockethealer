//
//  RaidFramesView.h
//  heal drudge
//
//  Created by david on 1/2/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Raid.h"

@class Entity;
@class Encounter;

typedef void(^TargetedPlayerBlock)(Player *);

@interface RaidFramesView : UIView

@property (nonatomic,copy) TargetedPlayerBlock targetedPlayerBlock;

@property Entity *player; // currently only for passing it to RaidFrame
@property (strong,retain) Raid *raid;
@property NSUInteger selectedFrame;
@property Encounter *encounter; // this is only necessary for ferrying encounter to RaidFrameView for isTargeted block

@end
