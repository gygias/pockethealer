//
//  Raid.h
//  heal drudge
//
//  Created by david on 1/2/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <Foundation/Foundation.h>

@class Player;
@class Entity;

@interface Raid : NSObject

+ (Raid *)randomRaid;
+ (Raid *)randomRaidWithStandardDistribution; // 2 tanks, 1 healer per 5 players
+ (Raid *)randomRaidWithGygiasTheDiscPriestAndSlyTheProtPaladin:(Entity **)outGygias :(Entity **)outSlyeri :(Entity **)outLireal size:(NSUInteger)sizeExcludingPrincipals;

- (NSArray *)partyForEntity:(Entity *)entity includingEntity:(BOOL)includingEntity;

@property Entity *player;
@property (strong,retain) NSArray *players;
@property (nonatomic,readonly) NSArray *tankPlayers;
@property (nonatomic,readonly) NSArray *nonTankPlayers;
@property (nonatomic,readonly) NSArray *meleePlayers; // includes tanks
@property (nonatomic,readonly) NSArray *meleeDPSPlayers;
@property (nonatomic,readonly) NSArray *rangePlayers;
@property (nonatomic,readonly) NSArray *healers;
@property (nonatomic,readonly) NSArray *dpsPlayers;
@property (readonly) Entity *randomHeroCapablePlayer;

@end
