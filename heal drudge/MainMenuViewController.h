//
//  MainMenuViewController.h
//  heal drudge
//
//  Created by david on 12/29/14.
//  Copyright (c) 2014 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface MainMenuViewController : BaseViewController

- (IBAction)pressedCreateCharacter:(id)sender;
- (IBAction)pressedQuickPlayGygias:(id)sender;
- (IBAction)pressedQuickPlaySlyeri:(id)sender;
- (IBAction)pressedQuickPlayLireal:(id)sender;
- (IBAction)pressedLoadFromArmory:(id)sender;
- (IBAction)raidSizeSliderDidSomething:(id)sender;
@property IBOutlet UISlider *raidSizeSlider;
@property IBOutlet UILabel *raidSizeLabel;

@end

