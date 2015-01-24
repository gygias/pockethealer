//
//  WoWRealm.h
//  heal drudge
//
//  Created by david on 1/21/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSString *WoWRealmUS;
extern const NSString *WoWRealmEU;
extern const NSString *WoWRealmKR;
extern const NSString *WoWRealmTW;

@interface WoWRealm : NSObject
{
    NSDictionary *_dictionary;
    const NSString *_country;
}

+ (WoWRealm *)realmWithString:(NSString *)realmString;
+ (WoWRealm *)realmWithWoWAPIDictionary:(NSDictionary *)apiDict country:(const NSString *)country;
+ (NSArray *)realmsAsPropertyList:(NSArray *)realms;

- (const NSString *)name;
- (NSString *)normalizedName;
- (NSString *)type;
- (NSString *)country;

@end
