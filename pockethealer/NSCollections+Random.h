//
//  NSCollections+Random.h
//  pockethealer
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import <Foundation/Foundation.h>

@interface NSArray (NSCollectionsRandom)

- (id)randomObject;
- (NSArray *)arrayByRandomlyRemovingNObjects:(NSUInteger)nObjects;

@end
