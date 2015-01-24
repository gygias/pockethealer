//
//  CreateHealerViewController.h
//  heal drudge
//
//  Created by david on 12/29/14.
//  Copyright (c) 2014 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface CreateHealerViewController : BaseViewController

@property(nonatomic,retain) IBOutlet UITextField *nameField;
@property(nonatomic,retain) IBOutlet UISegmentedControl *classSelector;
@property(nonatomic,retain) IBOutlet UISlider *ilvlSlider;
@property(nonatomic,retain) IBOutlet UILabel *ilvlValueLabel;
@property(nonatomic,retain) IBOutlet UISegmentedControl *preferredSecondaryOneSelector;
@property(nonatomic,retain) IBOutlet UISegmentedControl *preferredSecondaryTwoSelector;
@property(nonatomic,retain) IBOutlet UIButton *createButton;

- (IBAction)nameFieldDidSomething:(id)sender;
- (IBAction)classSelectorDidSomething:(id)sender;
- (IBAction)ilvlSliderDidSomething:(id)sender;
- (IBAction)preferredSecondaryOneSelectorDidSomething:(id)sender;
- (IBAction)preferredSecondaryTwoSelectorDidSomething:(id)sender;

- (IBAction)createButtonTapped:(id)sender;

@end
