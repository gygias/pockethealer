//
//  State.h
//  heal drudge
//
//  Created by david on 1/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <Foundation/Foundation.h>

#import "Entity.h"

@interface State : NSObject

+ (State *)sharedState;

@property Entity *player;
@property NSString *playerName; // XXX
@property NSUInteger raidSize; // XXX
@property BOOL forceGygias;
@property BOOL forceSlyeri;
@property BOOL forceLireal;
@property float difficulty;
@property BOOL debugViews;
@property NSMutableDictionary *spellOrdersBySpecID;

// setup
@property BOOL saveGuildToo;

+ (State *)readState;
- (void)writeState;

@end
