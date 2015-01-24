//
//  EvangelismEffect.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "EvangelismEffect.h"

@implementation EvangelismEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.duration = 20;
        self.maxStacks = @5;
    }
    
    return self;
}

@end
