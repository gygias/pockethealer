//
//  Ability.m
//  pockethealer
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "Ability.h"

@implementation Ability

- (id)initWithCaster:(Entity *)caster
{
    if ( self = [super initWithCaster:caster] )
    {
        self.hitSoundName = nil;
    }
    
    return self;
}

- (NSArray *)hdClasses
{
    return @[ [HDClass enemyClass] ];
}

@end
