//
//  WeakenedSoulEffect.m
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "WeakenedSoulEffect.h"

#import "PowerWordShieldSpell.h"

@implementation WeakenedSoulEffect

@synthesize source = _source;

- (id)init
{
    if ( self = [super init] )
    {
        self.duration = 15;
    }
    
    return self;
}

- (void)setSource:(Entity *)source
{
    //if ( source.hasWeakenedSoulGlyph )
    // self.duration = 13;
    _source = source;
}

- (BOOL)validateSpell:(Spell *)spell source:(Entity *)source target:(Entity *)target message:(NSString *__autoreleasing *)message
{
    if ( [spell isKindOfClass:[PowerWordShieldSpell class]] )
    {
        if ( message )
            *message = @"You can't do that right now";
        return NO;
    }
    
    return YES;
}

@end
