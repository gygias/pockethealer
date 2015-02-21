//
//  QuickPlayViewController.m
//  heal drudge
//
//  Created by david on 12/29/14.
//  Copyright (c) 2014 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "QuickPlayViewController.h"

@implementation QuickPlayViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.playViewController = [PlayViewController playViewController];
    self.playViewController.state = self.state;
    self.playViewController.dismissHandler = ^(PlayViewController *vc){
        NSLog(@"TODO: dismiss...");
    };
    [self.contentView addSubview:self.playViewController.view];
    [self.playViewController.view setNeedsUpdateConstraints];
    [self.playViewController.view setNeedsLayout];
    [self.playViewController.view layoutIfNeeded];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    [self.encounter end];
//}

@end
