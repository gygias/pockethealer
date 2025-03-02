//
//  NSCollections+Random.m
//  pockethealer
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "NSCollections+Random.h"

@implementation NSArray (NSCollectionsRandom)

- (id)randomObject
{
    if ( [self count] > 0 )
        return [self objectAtIndex:arc4random() % [self count]];
    return nil;
}

- (NSArray *)arrayByRandomlyRemovingNObjects:(NSUInteger)nObjects
{
    NSMutableArray *mutableCopy = [self mutableCopy];
    while (nObjects-- > 0 && mutableCopy.count > 0 )
    {
        [mutableCopy removeObject:[mutableCopy randomObject]];
    }
    return mutableCopy;
}

@end
