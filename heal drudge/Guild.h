//
//  Guild.h
//  heal drudge
//
//  Created by david on 1/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ModelBase.h"
#import "WoWRealm.h"

@interface Guild : ModelBase

+ (Guild *)guildWithAPIDictionary:(NSDictionary *)apiDictionary;
+ (Guild *)guildWithAPIName:(NSString *)guildName apiRealm:(NSString *)apiRealm;

@property NSString *name;
@property NSNumber *achievementPoints;
@property NSNumber *members;
@property WoWRealm *realm;
@property NSString *battlegroup;

@property NSNumber *icon;
@property NSNumber *iconColor;
@property NSNumber *border;
@property NSNumber *borderColor;
@property NSNumber *backgroundColor;

@end
