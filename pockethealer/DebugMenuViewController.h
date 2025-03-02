//
//  DebugMenuViewController.h
//  pockethealer
//
//  Created by david on 12/29/14.
//  Copyright (c) 2014 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface DebugMenuViewController : BaseViewController

- (IBAction)pressedCreateCharacter:(id)sender;
- (IBAction)pressedQuickPlayGygias:(id)sender;
- (IBAction)pressedQuickPlaySlyeri:(id)sender;
- (IBAction)pressedQuickPlayLireal:(id)sender;
- (IBAction)pressedLoadFromArmory:(id)sender;
- (IBAction)raidSizeSliderDidSomething:(id)sender;
@property IBOutlet UISlider *raidSizeSlider;
@property IBOutlet UILabel *raidSizeLabel;

@property IBOutlet UISwitch *forceGygiasSwitch;
- (IBAction)touchedForceGygias:(id)sender;
@property IBOutlet UISwitch *forceSlyeriSwitch;
- (IBAction)touchedForceSlyeri:(id)sender;
@property IBOutlet UISwitch *forceLirealSwitch;
- (IBAction)touchedForceLireal:(id)sender;

@property IBOutlet UILabel *difficultyLabel;
@property IBOutlet UISlider *difficultySlider;
- (IBAction)difficultySliderDidSomething:(id)sender;

@property IBOutlet UISwitch *debugViewsSlider;
- (IBAction)debugViewsSliderDidSomething:(id)sender;

@end

