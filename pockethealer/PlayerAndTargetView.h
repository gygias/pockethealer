//
//  PlayerAndTargetView.h
//  pockethealer
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <UIKit/UIKit.h>

@class Entity, RaidFramesView, RaidFrameView;

typedef void(^EntityTouchedBlock)(Entity *);

@interface PlayerAndTargetView : UIView
{
    CGRect _lastDrawnRect;
}

@property (nonatomic,copy) EntityTouchedBlock entityTouchedHandler;
@property (readonly) CGPoint playerOrigin;

@property Entity *player;
@property Entity *target;
@property RaidFramesView *raidFramesView;
@property RaidFrameView *lastTargetTargetFrame;
@property RaidFrameView *lastTargetFrame;

@property (readonly) CGPoint centerOfPlayer;
@property (readonly) CGPoint centerOfTarget;
@property (readonly) CGPoint centerOfTargetTarget;

@end
