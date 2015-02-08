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
    self.raidSizeSlider.value = self.state.raidSize;
    self.raidSizeLabel.text = [NSString stringWithFormat:@"%lu",(NSUInteger)self.raidSizeSlider.value];
    self.forceGygiasSwitch.on = self.state.forceGygias;
    self.forceSlyeriSwitch.on = self.state.forceSlyeri;
    self.forceLirealSwitch.on = self.state.forceLireal;
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
    self.state.forceGygias = YES;
    self.forceGygiasSwitch.on = YES;
    [self.state writeState];
}

- (IBAction)pressedQuickPlaySlyeri:(id)sender
{
    PHLogV(@"quick play sly");
    self.state.playerName = @"Slyeri";
    self.state.forceSlyeri = YES;
    self.forceSlyeriSwitch.on = YES;
    [self.state writeState];
}

- (IBAction)pressedQuickPlayLireal:(id)sender
{
    PHLogV(@"quick play lireal");
    self.state.playerName = @"Lireal";
    self.state.forceLireal = YES;
    self.forceLirealSwitch.on = YES;
    [self.state writeState];
}

- (IBAction)pressedLoadFromArmory:(id)sender
{
    PHLogV(@"load from armory");
}

- (IBAction)raidSizeSliderDidSomething:(id)sender
{
    //PHLogV(@"raid size slider did something");
    
    NSUInteger rounded = self.raidSizeSlider.value;
    [sender setValue:rounded animated:NO];
    self.raidSizeLabel.text = [NSString stringWithFormat:@"%lu",(NSUInteger)self.raidSizeSlider.value];
    
    self.state.raidSize = self.raidSizeSlider.value;
    [self.state writeState];
}

- (IBAction)touchedForceGygias:(id)sender
{
    self.state.forceGygias = ((UISwitch *)sender).on;
    [self.state writeState];
    PHLogV(@"force gygias: %@",self.state.forceGygias?@"YES!":@"NO!");
}

- (IBAction)touchedForceSlyeri:(id)sender
{
    self.state.forceSlyeri = ((UISwitch *)sender).on;
    [self.state writeState];
    PHLogV(@"force slyeri: %@",self.state.forceSlyeri?@"YES!":@"NO!");
}

- (IBAction)touchedForceLireal:(id)sender
{
    self.state.forceLireal = ((UISwitch *)sender).on;
    [self.state writeState];
    PHLogV(@"force lireal: %@",self.state.forceLireal?@"YES!":@"NO!");
}

@end
