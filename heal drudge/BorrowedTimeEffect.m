//
//  BorrowedTimeEffect.m
//  heal drudge
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "BorrowedTimeEffect.h"

#import "ImageFactory.h"
#import "EventModifier.h"

@implementation BorrowedTimeEffect

- (id)init
{
    if ( self = [super init] )
    {
        self.name = @"Borrowed Time";
        self.duration = 6;
        self.image = [ImageFactory imageNamed:@"borrowed_time"];
        self.effectType = BeneficialEffect;
        //self.drawsInFrame = YES; i can't remember
    }
    
    return self;
}

- (BOOL)validateSpell:(Spell *)spell source:(Entity *)source target:(Entity *)target message:(NSString *__autoreleasing *)message
{
    return YES;
}

- (BOOL)handleSpellStarted:(Spell *)spell source:(Entity *)source target:(Entity *)target modifier:(NSMutableArray *)modifiers
{
    return [self _applyHasteBuff:modifiers];
}

- (BOOL)handleSpell:(Spell *)spell source:(Entity *)source target:(Entity *)target modifier:(NSMutableArray *)modifiers
{
    return [self _applyHasteBuff:modifiers];
}

- (BOOL)_applyHasteBuff:(NSMutableArray *)modifiers
{
    EventModifier *mod = [EventModifier new];
    mod.hasteIncreasePercentage = @0.4;
    [modifiers addObject:mod];
    return YES;
    
    // need to handle haste increase / instant cast for cast-time spells,
    // AND a way for modifier to consume this effect IFF the cast actually goes off
}

@end
