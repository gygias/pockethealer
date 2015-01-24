//
//  Character.h
//  heal drudge
//
//  Created by david on 1/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ModelBase.h"
#import "WoWRealm.h"
#import "HDClass.h"
#import "Guild.h"

@interface Character : ModelBase

// kvc stuff
+ (NSArray *)primaryStatKeys;
+ (NSArray *)secondaryStatKeys;
+ (NSArray *)tertiaryStatKeys;

- (NSNumber *)primaryStat;

@property NSString *name;
@property NSString *titleAndName;
@property WoWRealm *realm;
@property HDClass *hdClass;
@property UIImage *image;
@property Guild *guild;
@property NSNumber *level;
@property NSNumber *race;
@property NSNumber *gender;
@property NSNumber *achievementPoints;
@property NSNumber *averageItemLevel;
@property NSNumber *averageItemLevelEquipped;
@property NSNumber *honorableKills;
@property NSNumber *guildRank;

// synthesized
@property (nonatomic,readonly) NSNumber *health;
@property (nonatomic,readonly) NSNumber *baseMana; // ??
@property (nonatomic,readonly) NSNumber *spellPower; // ??
@property (nonatomic,readonly) NSNumber *attackPower; // ??

// stats
@property NSNumber *stamina;
@property NSNumber *power; // "resource"
// primary
@property NSNumber *strength;
@property NSNumber *agility;
@property NSNumber *intellect;
// secondary
@property NSNumber *critRating;
@property NSNumber *hasteRating;
@property NSNumber *masteryRating;
// tertiary
@property NSNumber *versatilityRating;
@property NSNumber *multistrikeRating;
@property NSNumber *leechRating;
// avoidance
@property NSNumber *armor;
@property NSNumber *parryRating;
@property NSNumber *dodgeRating;
@property NSNumber *blockRating;

// XXX
@property NSString *specName;
@property NSString *offspecName;
@property const NSString *role;

@end
