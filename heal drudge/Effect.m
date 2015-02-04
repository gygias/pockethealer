//
//  Effect.m
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Logging.h"

#import "Effect.h"

#import "Encounter.h"
#import "SoundManager.h"

@implementation Effect

- (id)init
{
    if ( self = [super init] )
    {
        self.maxStacks = @1;
        self.currentStacks = @1;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@[%@]",NSStringFromClass([self class]),self.currentStacks];
}

- (BOOL)validateSpell:(Spell *)spell asEffectOfSource:(BOOL)asEffectOfSource source:(Entity *)source target:(Entity *)target message:(NSString * __strong *)message
{
    return YES;
}

- (BOOL)handleSpellStarted:(Spell *)spell asSource:(BOOL)asSource source:(Entity *)source target:(Entity *)target modifier:(NSMutableArray *)modifiers handler:(EffectEventHandler)handler
{
    if ( handler )
        handler(NO);
    return NO;
}

- (BOOL)handleSpell:(Spell *)spell asSource:(BOOL)asSource source:(Entity *)source target:(Entity *)target modifier:(NSMutableArray *)modifiers handler:(EffectEventHandler)handler
{
    if ( handler )
        handler(NO);
    return NO;
}

- (void)handleTickWithOwner:(Entity *)owner isInitialTick:(BOOL)isInitialTick
{
}

- (BOOL)handleAdditionWithOwner:(Entity *)owner
{
    [SoundManager playEffectHit:self];
    return YES;
}

- (void)handleConsumptionWithOwner:(Entity *)owner
{
    
}

- (void)handleRemovalWithOwner:(Entity *)owner
{
    
}

- (void)addStack
{
    if ( self.currentStacks.integerValue < self.maxStacks.integerValue )
        self.currentStacks = @(self.currentStacks.integerValue + 1);
    self.startDate = [NSDate date];
    PHLog(@"%@ has gained a stack -> %@",self,self.currentStacks);
}

- (void)removeStack
{
    if ( self.currentStacks > 0 )
        self.currentStacks = @(self.currentStacks.integerValue - 1);
}

- (void)addStacks:(NSUInteger)nStacks
{
    while ( nStacks-- > 0 )
        [self addStack];
}

+ (NSArray *)_effectNames
{
    return @[ @"WeakenedSoulEffect",
              @"ArchangelEffect",
              @"EvangelismEffect",
              @"PrayerOfMendingEffect",
              @"DivineAegisEffect",
              @"PowerWordShieldEffect",
              @"BorrowedTimeEffect"
              ];
}

@end
