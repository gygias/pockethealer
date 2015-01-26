//
//  QuickPlayViewController.h
//  heal drudge
//
//  Created by david on 12/29/14.
//  Copyright (c) 2014 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "EnemyFrameView.h"
#import "RaidFramesView.h"
#import "SpellBarView.h"
#import "CastBarView.h"
#import "PlayerAndTargetView.h"
#import "AlertTextView.h"

@interface QuickPlayViewController : BaseViewController

@property IBOutlet EnemyFrameView *enemyFrameView;
@property IBOutlet AlertTextView *alertTextView;
@property IBOutlet RaidFramesView *raidFramesView;
@property IBOutlet CastBarView *castBarView;
@property IBOutlet PlayerAndTargetView *playerAndTargetView;
@property IBOutlet SpellBarView *spellBarView;

@end
