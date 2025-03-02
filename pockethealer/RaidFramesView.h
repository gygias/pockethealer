//
//  RaidFramesView.h
//  pockethealer
//
//  Created by david on 1/2/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <UIKit/UIKit.h>

#import "PlayViewBase.h"

#import "Raid.h"

@class Entity;
@class Encounter;
@class RaidFrameView;

typedef void(^TargetedPlayerBlock)(Entity *);

@interface RaidFramesView : PlayViewBase
{
    CGRect _lastRect;
    BOOL _refreshCachedValues;
    NSArray *_raidFrames;
}

@property (nonatomic,copy) TargetedPlayerBlock targetedPlayerBlock;

@property Entity *player; // currently only for passing it to RaidFrame
@property (nonatomic,retain) Raid *raid;
@property NSUInteger selectedFrame;
@property Encounter *encounter; // this is only necessary for ferrying encounter to RaidFrameView for isTargeted block

// optimization?
@property RaidFrameView *playerFrame;
@property RaidFrameView *playerTargetFrame;
@property RaidFrameView *playerTargetTargetFrame;

- (CGPoint)absoluteOriginForEntity:(Entity *)e;

@end
