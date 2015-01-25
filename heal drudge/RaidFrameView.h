//
//  RaidFrameView.h
//  heal drudge
//
//  Created by david on 1/2/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Entity;

@interface RaidFrameView : UIView

+ (CGSize)desiredSize;

@property (strong,retain) Entity *entity;
@property BOOL selected;

@end
