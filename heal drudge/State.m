//
//  State.m
//  heal drudge
//
//  Created by david on 1/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "State.h"

@implementation State

+ (State *)readState
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    State *state = [State new];
    state.forceGygias = [defaults boolForKey:@"forceGygias"];
    state.forceSlyeri = [defaults boolForKey:@"forceSlyeri"];
    state.forceLireal = [defaults boolForKey:@"forceLireal"];
    state.raidSize = [defaults integerForKey:@"raidSize"];
    state.difficulty = [defaults floatForKey:@"difficulty"];
    state.debugViews = [defaults boolForKey:@"debugViws"];
    return state;
}

- (void)writeState
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.forceGygias forKey:@"forceGygias"];
    [defaults setBool:self.forceSlyeri forKey:@"forceSlyeri"];
    [defaults setBool:self.forceLireal forKey:@"forceLireal"];
    [defaults setInteger:self.raidSize forKey:@"raidSize"];
    [defaults setFloat:self.difficulty forKey:@"difficulty"];
    [defaults setBool:self.debugViews forKey:@"debugViews"];
}

@end
