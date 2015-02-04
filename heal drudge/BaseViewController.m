//
//  BaseViewController.m
//  heal drudge
//
//  Created by david on 1/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Logging.h"

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

static State *sBaseViewControllerState = nil;
+ (void)initialize
{
    if ( self == [BaseViewController class] )
    {
        if ( sBaseViewControllerState )
            abort();// XXX
        sBaseViewControllerState = [State new];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (State *)state
{
    return sBaseViewControllerState;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    PHLog(@"yoyo (%@) %@ -> %@",sender,segue.sourceViewController,segue.destinationViewController);
}

@end
