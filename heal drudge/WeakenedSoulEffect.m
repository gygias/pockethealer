//
//  WeakenedSoulEffect.m
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "WeakenedSoulEffect.h"

#import "PowerWordShieldSpell.h"

@implementation WeakenedSoulEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Weakened Soul";
        self.duration = 15;
        self.image = [ImageFactory imageNamed:@"weakened_soul"];
        self.drawsInFrame = YES;
        self.effectType = DetrimentalEffect;
    }
    
    return self;
}

- (BOOL)validateSpell:(Spell *)spell asEffectOfSource:(BOOL)asEffectOfSource source:(Entity *)source target:(Entity *)target message:(NSString * __strong *)message
{
    if ( ! asEffectOfSource && [spell isKindOfClass:[PowerWordShieldSpell class]] )
    {
        if ( message )
            *message = @"You can't do that right now";
        return NO;
    }
    
    return YES;
}

- (void)handleSpell:(Spell *)spell source:(Entity *)source target:(Entity *)target
{
    // if source has glyph of weakened soul
    // ...
}

@end
