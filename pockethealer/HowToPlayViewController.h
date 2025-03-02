//
//  HowToPlayViewController.h
//  heal drudge
//
//  Created by david on 3/8/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"
#import "PlayViewController.h"

@class PlayViewController;

@interface HowToPlayViewController : BaseViewController

@property IBOutlet UIView *contentView;
@property PlayViewController *playViewController;

@end
