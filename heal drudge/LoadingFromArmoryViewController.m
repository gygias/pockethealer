//
//  LoadingFromArmoryViewController.m
//  heal drudge
//
//  Created by david on 1/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "LoadingFromArmoryViewController.h"

#import "WoWAPIRequest.h"

@interface LoadingFromArmoryViewController ()

@end

@implementation LoadingFromArmoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.progressBar setProgress:0.0 animated:NO]; // little jony needs an indeterminate progress bar?
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self doTheStuff];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doTheStuff
{
    if ( self.state.saveGuildToo )
    {
        WoWAPIRequest *guildListRequest = [WoWAPIRequest new];
        guildListRequest.realm = self.state.character.realm;
        guildListRequest.isGuildMemberListRequest = YES;
        guildListRequest.guildName = self.state.character.guild.name;
        
        [guildListRequest sendRequestWithCompletionHandler:^(BOOL success, id result) {
            if ( ! success )
            {
                NSLog(@"guild list request failed");
                [self _admitFailure];
            }
            
            NSLog(@"result: %@",result);
            
            if ( ! [result isKindOfClass:[NSDictionary class]] )
            {
                NSLog(@"guild list result is not of expected type");
                [self _admitFailure];
            }
            
            NSDictionary *resultDict = (NSDictionary *)result;
            
            NSInteger idx = 0, outOf = [resultDict[@"members"] count];
            
            NSString *upperMessage = [NSString stringWithFormat:@"loading %ld guildies…",outOf];
            [self _updateProgress:-1 total:-1 upper:upperMessage lower:nil];
            
            for ( NSDictionary *guildieAPIDict in resultDict[@"members"] )
            {
                Character *tempCharacter = [WoWAPIRequest characterWithAPIGuildMemberDict:guildieAPIDict fetchingImage:NO];
                WoWAPIRequest *guildieInfoRequest = [WoWAPIRequest new];
                guildieInfoRequest.realm = tempCharacter.realm;
                guildieInfoRequest.isCharacterInfoRequest = YES;
                guildieInfoRequest.characterName = tempCharacter.name;
                
                [guildieInfoRequest sendRequestWithCompletionHandler:^(BOOL success, id result) {
                    if ( ! success )
                    {
                        NSLog(@"guildie info request failed");
                        [self _admitPartialFailure];
                    }
                    
                    if ( ! [result isKindOfClass:[NSDictionary class]] )
                    {
                        NSLog(@"guildie info result is not of expected type: %@",result);
                        [self _admitPartialFailure];
                    }
                    
                    NSLog(@"guildie %@ request: %lu key/values",tempCharacter.name,[result count]);
                }];
                
                idx++;
                [self _updateProgress:idx total:outOf upper:nil lower:tempCharacter.name];
            }
            
            [self _updateProgress:1 total:1 upper:@"" lower:@"done!"];
            [self.doneButton setEnabled:YES];
        }];
    }
}

- (void)_admitFailure
{
    // nah
}

- (void)_admitPartialFailure
{
    // nah
}

- (void)_updateProgress:(NSInteger)idx total:(NSInteger)outOf upper:(NSString *)upper lower:(NSString *)lower
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( idx >= 0 && outOf > 0 )
        {
            float progress = (float)idx / (float)outOf;
            [self.progressBar setProgress:progress animated:YES];
        }
        if ( upper )
            self.upperProgressLabel.text = upper;
        if ( lower )
            self.lowerProgressLabel.text = lower;
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
