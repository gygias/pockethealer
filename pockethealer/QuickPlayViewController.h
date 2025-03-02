//
//  QuickPlayViewController.h
//  pockethealer
//
//  Created by david on 12/29/14.
//  Copyright (c) 2014 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <UIKit/UIKit.h>

#import "BaseViewController.h"

#import "PlayViewController.h"

@interface QuickPlayViewController : BaseViewController

@property IBOutlet UIView *contentView;
@property PlayViewController *playViewController;

@end
