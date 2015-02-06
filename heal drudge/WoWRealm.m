//
//  WoWRealm.m
//  heal drudge
//
//  Created by david on 1/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "WoWRealm.h"

const NSString *WoWRealmUS = @"us";
const NSString *WoWRealmEU = @"eu";
const NSString *WoWRealmKR = @"kr";
const NSString *WoWRealmTW = @"tw";

static NSArray *sWoWRealms = nil;

@implementation WoWRealm

- (id)_initWithDictionary:(NSDictionary *)realmDict country:(const NSString *)country
{
    if ( self = [super init] )
    {
        _dictionary = realmDict;
        _country = country;
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@-%@ (%@)",_country,[self name],[self type]];
}

- (NSString *)name
{
    return [_dictionary objectForKey:@"name"];
}

- (NSString *)normalizedName
{
    return [_dictionary objectForKey:@"normalized-name"];
}

- (NSString *)type
{
    return [_dictionary objectForKey:@"type"];
}

- (NSString *)locale
{
    return [_dictionary objectForKey:@"locale"];
}

- (NSString *)battlegroup
{
    return [_dictionary objectForKey:@"battlegroup"];
}

- (const NSString *)country
{
    return _country;
}

+ (void)initialize
{
    NSString *realmsPath = [[NSBundle mainBundle] pathForResource:@"WoWRealms" ofType:@"plist"];
    NSDictionary *realmsDict = [NSDictionary dictionaryWithContentsOfFile:realmsPath];
    NSArray *locations = @[ WoWRealmUS, WoWRealmEU, WoWRealmKR, WoWRealmTW ];
    NSMutableArray *wowRealms = [NSMutableArray array];
    
    for ( const NSString *location in locations )
    {
        for ( NSDictionary *dict in [[realmsDict objectForKey:location] allObjects] )
        {
            WoWRealm *realm = [[WoWRealm alloc] _initWithDictionary:dict country:location];
            if ( realm )
                [wowRealms addObject:realm];
        }
    }
    
    sWoWRealms = [wowRealms copy];
}

+ (WoWRealm *)realmWithString:(NSString *)realmString
{
    // fast
    for ( WoWRealm *realm in sWoWRealms )
    {
        if ( [[realm normalizedName] compare:realmString options:NSCaseInsensitiveSearch] == NSOrderedSame )
            return realm;
        else if ( [[realm name] compare:realmString options:NSCaseInsensitiveSearch] == NSOrderedSame )
            return realm;

    }
    
    // slow
    NSInteger sublength = [realmString length];
    while ( sublength > 0 )
    {
        NSString *substring = [[realmString substringToIndex:sublength] lowercaseString];
        
        for ( WoWRealm *realm in sWoWRealms )
        {
            if ( [[realm normalizedName] hasPrefix:substring] )
                return realm;
            else if ( [[[realm name] lowercaseString] hasPrefix:substring] )
                return realm;
        }
        
        sublength--;
    }
    
    return nil;
}

/* {
 realms =     (
 {
 battlegroup = Vengeance;
 "connected_realms" =             (
 daggerspine,
 bonechewer,
 gurubashi,
 hakkar,
 aegwynn
 );
 locale = "en_US";
 name = Aegwynn;
 population = medium;
 queue = 0;
 slug = aegwynn;
 status = 1;
 timezone = "America/Los_Angeles";
 "tol-barad" =             {
 area = 21;
 "controlling-faction" = 1;
 next = 1421873371444;
 status = 1;
 };
 type = pvp;
 wintergrasp =             {
 area = 1;
 "controlling-faction" = 0;
 next = 1421873160303;
 status = 2;
 };
 },
...
 */

// http://blizzard.github.io/api-wow-docs/#realm-status-api
const NSString *WoWAPIRealmNameKey = @"name";
const NSString *WoWAPIRealmTypeKey = @"type";
const NSString *WoWAPIRealmNormalizedNameKey = @"slug";
const NSString *WoWAPIRealmLocaleKey = @"locale";
const NSString *WoWAPIRealmBattlegroupKey = @"battlegroup";

+ (WoWRealm *)realmWithWoWAPIDictionary:(NSDictionary *)apiDict country:(const NSString *)country
{
    NSMutableDictionary *myDict = [NSMutableDictionary dictionary];
    NSString *apiName = apiDict[WoWAPIRealmNameKey];
    if ( ! apiName )
        return nil;
    myDict[@"name"] = apiName;
    NSString *apiType = apiDict[WoWAPIRealmTypeKey];
    if ( ! apiType )
        return nil;
    myDict[@"type"] = apiType;
    NSString *apiNormalizedName = apiDict[WoWAPIRealmNormalizedNameKey];
    if ( ! apiNormalizedName )
        return nil;
    myDict[@"normalized-name"] = apiNormalizedName;
    NSString *apiLocale = apiDict[WoWAPIRealmLocaleKey];
    if ( ! apiLocale )
        return nil;
    myDict[@"locale"] = apiLocale;
    NSString *apiBattlegroup = apiDict[WoWAPIRealmBattlegroupKey];
    if ( ! apiBattlegroup )
        return nil;
    myDict[@"battlegroup"] = apiBattlegroup;
    
    return [[WoWRealm alloc] _initWithDictionary:myDict country:country];
}

+ (NSArray *)realmsAsPropertyList:(NSArray *)realms
{
    NSMutableArray *realmsPlist = [NSMutableArray array];
    for ( WoWRealm *realm in realms )
    {
        [realmsPlist addObject:[realm _propertyList]];
    }
    
    return realmsPlist;
}

- (id)_propertyList
{
    return _dictionary;
}

@end
