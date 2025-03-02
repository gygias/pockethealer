//
//  Guild.m
//  heal drudge
//
//  Created by david on 1/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "Guild.h"

@implementation Guild

+ (Guild *)guildWithAPIDictionary:(NSDictionary *)apiDictionary
{
    Guild *aGuild = [Guild new];
    aGuild.name = apiDictionary[@"name"];
    aGuild.battlegroup = apiDictionary[@"battlegroup"];
    aGuild.achievementPoints = apiDictionary[@"achievementPoints"];
    aGuild.members = apiDictionary[@"members"];
    aGuild.realm = [WoWRealm realmWithString:apiDictionary[@"realm"]];
    
    NSDictionary *emblemDictionary = apiDictionary[@"emblem"];
    aGuild.icon = emblemDictionary[@"icon"];
    aGuild.iconColor = emblemDictionary[@"iconColor"];
    aGuild.border = emblemDictionary[@"border"];
    aGuild.borderColor = emblemDictionary[@"borderColor"];
    aGuild.backgroundColor = emblemDictionary[@"backgroundColor"];
    aGuild.isComplete = YES;
    
    return aGuild;
}

+ (Guild *)guildWithAPIName:(NSString *)guildName apiRealm:(NSString *)apiRealm
{
    Guild *aGuild = [Guild new];
    aGuild.name = guildName;
    aGuild.realm = [WoWRealm realmWithString:apiRealm];
    aGuild.isComplete = NO;
    return aGuild;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"guild '%@' (%@)",self.name,self.realm];
}

@end
