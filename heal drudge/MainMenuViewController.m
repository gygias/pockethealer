//
//  MainMenuViewController.m
//  heal drudge
//
//  Created by david on 12/29/14.
//  Copyright (c) 2014 Combobulated Software. All rights reserved.
//

#import "MainMenuViewController.h"

@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressedCreateCharacter:(id)sender
{
    NSLog(@"create character");
}

- (IBAction)pressedQuickPlayGygias:(id)sender
{
    NSLog(@"quick play gygias");
    self.state.playerName = @"Gygias";
}

- (IBAction)pressedQuickPlaySlyeri:(id)sender
{
    NSLog(@"quick play sly");
    self.state.playerName = @"Slyeri";
}

- (IBAction)pressedLoadFromArmory:(id)sender
{
    NSLog(@"load from armory");
}

@end
