//
//  BorrowedTimeEffect.m
//  pockethealer
//
//  Created by david on 1/24/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

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
        self.drawsInFrame = YES;
    }
    
    return self;
}

- (BOOL)addModifiersWithSpell:(Spell *)spell modifiers:(NSMutableArray *)modifiers
{
    // borrowed time doesn't seem to be consumed in WoD
    //if ( handler )
    //    handler(YES);
    if ( spell.caster != self.source )
        return NO;
    return [self _applyHasteBuff:modifiers];
}

- (BOOL)handleSpell:(Spell *)spell asSource:(BOOL)asSource source:(Entity *)source target:(Entity *)target modifier:(NSMutableArray *)modifiers
{
    if ( ! asSource )
        return NO;
    return [self _applyHasteBuff:modifiers];
}

- (BOOL)_applyHasteBuff:(NSMutableArray *)modifiers
{
    EventModifier *mod = [EventModifier new];
    mod.hasteIncreasePercentage = @0.4;
    [modifiers addObject:mod];
    return NO;
    
    // need to handle haste increase / instant cast for cast-time spells,
    // AND a way for modifier to consume this effect IFF the cast actually goes off
}

@end
