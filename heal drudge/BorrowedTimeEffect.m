//
//  BorrowedTimeEffect.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "BorrowedTimeEffect.h"

#import "ImageFactory.h"

@implementation BorrowedTimeEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Borrowed Time";
        self.duration = 6;
        self.image = [ImageFactory imageNamed:@"borrowed_time"];
        self.isBeneficial = YES;
        //self.drawsInFrame = YES; i can't remember
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
