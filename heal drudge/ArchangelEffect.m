//
//  ArchangelEffect.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "ArchangelEffect.h"

@implementation ArchangelEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.duration = 18;
        self.maxStacks = @5;
        self.stacksAreInvisible = YES;
    }
    
    return self;
}

@end
