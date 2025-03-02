//
//  WoWAPIRequest.h
//  heal drudge
//
//  Created by david on 1/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <Foundation/Foundation.h>
#import "WoWRealm.h"
#import "Entity.h"

@interface WoWAPIRequest : NSURLConnection

@property WoWRealm *realm;

@property BOOL isRealmStatusRequest;
@property const NSString *realmStatusCountry;

@property BOOL isGuildMemberListRequest;
@property NSString *guildName;

@property BOOL isCharacterInfoRequest;
@property NSString *characterName;

@property BOOL isCharacterThumbnailRequest;
@property NSString *characterThumbnailURLSuffix;

- (void)sendRequestWithCompletionHandler:(void (^)(BOOL, id))handler;

+ (NSArray *)realmsFromRealmStatusResponse:(id)response country:(const NSString *)country;
//+ (NSArray *)characterNamesFromGuildListResponse:(id)response;
+ (NSUInteger)averageItemLevelFromCharacterItemsResponse:(id)response;

// "members" of a guild list request have a layer of upper indirection including the guild rank, as opposed
// to dictionaries returned from individual character queries
+ (Entity *)entityWithAPIGuildMemberDict:(NSDictionary *)apiGuildMemberDict fetchingImage:(BOOL)fetchImage;
+ (Entity *)entityWithAPICharacterDict:(NSDictionary *)apiCharacterDict fetchingImage:(BOOL)fetchImage;

+ (const NSString *)roleFromAPIRoleString:(NSString *)apiRoleString;

@end
