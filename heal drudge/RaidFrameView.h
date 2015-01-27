//
//  RaidFrameView.h
//  heal drudge
//
//  Created by david on 1/2/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Entity;
@class Encounter;

@interface RaidFrameView : UIView

+ (CGSize)desiredSize;

typedef BOOL(^EntityIsTargetedBlock)(Entity * entity);

@property (nonatomic,copy) EntityIsTargetedBlock entityIsTargetedHandler;

@property (strong,retain) Entity *player;
@property (strong,retain) Entity *entity;
@property BOOL selected;
@property Encounter *encounter;

@end
