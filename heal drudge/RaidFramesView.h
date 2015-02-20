//
//  RaidFramesView.h
//  heal drudge
//
//  Created by david on 1/2/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <UIKit/UIKit.h>
#import "Raid.h"

@class Entity;
@class Encounter;

typedef void(^TargetedPlayerBlock)(Entity *);

@interface RaidFramesView : UIView
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

- (CGPoint)originForEntity:(Entity *)e;

@end
