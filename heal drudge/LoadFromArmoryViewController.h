//
//  LoadFromArmoryViewController.h
//  heal drudge
//
//  Created by david on 1/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface LoadFromArmoryViewController : BaseViewController

@property (nonatomic,retain) IBOutlet UITextField *realmField;
@property (nonatomic,retain) IBOutlet UITextField *nameField;
@property (nonatomic,retain) IBOutlet UIButton *loadButton;

@property (nonatomic,retain) IBOutlet UIImageView *thumbnailView;
@property (nonatomic,retain) IBOutlet UIImageView *specView;
@property (nonatomic,retain) IBOutlet UILabel *nameLabel;
@property (nonatomic,retain) IBOutlet UILabel *specLabel;
@property (nonatomic,retain) IBOutlet UILabel *guildLabel;
@property (nonatomic,retain) IBOutlet UILabel *ilvlLabel;

@property (nonatomic,retain) IBOutlet UIButton *continueButton;

- (IBAction)pressedLoad:(id)sender;
- (IBAction)pressedContinue:(id)sender;
- (IBAction)resignTheGoddamnedKeyboard:(id)sender;

@end
