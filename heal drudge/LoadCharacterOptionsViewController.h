//
//  LoadCharacterOptionsViewController.h
//  heal drudge
//
//  Created by david on 1/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface LoadCharacterOptionsViewController : BaseViewController

@property (nonatomic,retain) IBOutlet UIImageView *thumbnailView;
@property (nonatomic,retain) IBOutlet UIImageView *specView;
@property (nonatomic,retain) IBOutlet UILabel *nameLabel;
@property (nonatomic,retain) IBOutlet UILabel *specLabel;
@property (nonatomic,retain) IBOutlet UILabel *guildLabel;
@property (nonatomic,retain) IBOutlet UILabel *ilvlLabel;

@property (nonatomic,retain) IBOutlet UISwitch *guildTooSwitch;
@property (nonatomic,retain) IBOutlet UIView *guildTooOptionsView;
@property (nonatomic,retain) IBOutlet UISlider *minGuildiLvlSlider;
@property (nonatomic,retain) IBOutlet UILabel *minGuildiLvlLabel;

- (IBAction)pressedGuildTooButton:(id)sender;
- (IBAction)pressedSaveButton:(id)sender;

@end
