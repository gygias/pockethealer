//
//  LoadingFromArmoryViewController.h
//  heal drudge
//
//  Created by david on 1/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface LoadingFromArmoryViewController : BaseViewController

@property IBOutlet UIProgressView *progressBar;
@property IBOutlet UILabel *upperProgressLabel;
@property IBOutlet UILabel *lowerProgressLabel;
@property IBOutlet UIButton *doneButton;

@end
