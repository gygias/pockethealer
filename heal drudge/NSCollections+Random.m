//
//  NSCollections+Random.m
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "NSCollections+Random.h"

@implementation NSArray (NSCollectionsRandom)

- (id)randomObject
{
    if ( [self count] > 0 )
        return [self objectAtIndex:arc4random() % [self count]];
    return nil;
}

@end
