//
//  RaidFramesView.h
//  heal drudge
//
//  Created by david on 1/2/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Raid.h"

typedef void(^TargetedPlayerBlock)(Player *);

@interface RaidFramesView : UIView

@property (nonatomic,copy) TargetedPlayerBlock targetedPlayerBlock;

@property (strong,retain) Raid *raid;
@property NSUInteger selectedFrame;

@end
