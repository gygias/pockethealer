//
//  MainMenuViewController.m
//  heal drudge
//
//  Created by david on 12/29/14.
//  Copyright (c) 2014 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "MainMenuViewController.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.state.raidSize = self.raidSizeSlider.value;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressedCreateCharacter:(id)sender
{
    PHLogV(@"create character");
}

- (IBAction)pressedQuickPlayGygias:(id)sender
{
    PHLogV(@"quick play gygias");
    self.state.playerName = @"Gygias";
}

- (IBAction)pressedQuickPlaySlyeri:(id)sender
{
    PHLogV(@"quick play sly");
    self.state.playerName = @"Slyeri";
}

- (IBAction)pressedQuickPlayLireal:(id)sender
{
    PHLogV(@"quick play lireal");
    self.state.playerName = @"Lireal";
}

- (IBAction)pressedLoadFromArmory:(id)sender
{
    PHLogV(@"load from armory");
}

- (IBAction)raidSizeSliderDidSomething:(id)sender
{
    PHLogV(@"raid size slider did something");
    
    NSUInteger rounded = self.raidSizeSlider.value;
    [sender setValue:rounded animated:NO];
    self.raidSizeLabel.text = [NSString stringWithFormat:@"%lu",(NSUInteger)self.raidSizeSlider.value];
    
    self.state.raidSize = self.raidSizeSlider.value;
}

@end
