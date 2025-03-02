//
//  HowToPlayViewController.m
//  pockethealer
//
//  Created by david on 3/8/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "HowToPlayViewController.h"

@implementation HowToPlayViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.playViewController = [PlayViewController playViewController];
    self.playViewController.isHowToPlayViewController = YES;
    self.playViewController.state = self.state;
    
    __unsafe_unretained typeof(self) weakSelf = self;
    self.playViewController.dismissHandler = ^(PlayViewController *vc){
        [weakSelf performSegueWithIdentifier:@"how-to-play-to-main-menu" sender:weakSelf];
    };
    
    [self.contentView addSubview:self.playViewController.view];
    [self.playViewController.view setNeedsUpdateConstraints];
    [self.playViewController.view setNeedsLayout];
    [self.playViewController.view layoutIfNeeded];
}

@end
