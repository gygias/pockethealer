//
//  EnemyFrameView.h
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <UIKit/UIKit.h>

@class Enemy;

typedef BOOL(^EnemyTouchedBlock)(Enemy *);

@interface EnemyFrameView : UIView

@property (nonatomic,retain) Enemy *enemy;
@property (nonatomic,copy) EnemyTouchedBlock enemyTouchedHandler;

@end
