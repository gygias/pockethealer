//
//  PrayerOfMendingEffect.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PrayerOfMendingEffect.h"

#import "ImageFactory.h"

@implementation PrayerOfMendingEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Prayer of Mending";
        self.duration = 30;
        self.currentStacks = @5;
        self.image = [ImageFactory imageNamed:@"prayer_of_mending"];
        self.drawsInFrame = YES;
        self.isBeneficial = YES;
    }
    
    return self;
}

- (BOOL)validateSpell:(Spell *)spell source:(Entity *)source target:(Entity *)target message:(NSString *__autoreleasing *)message
{
    return YES;
}

- (void)handleSpell:(Spell *)spell source:(Entity *)source target:(Entity *)target
{
    // if source has glyph of weakened soul
    // ...
}

@end
