//
//  Effect.m
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Effect.h"

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

- (BOOL)validateSpell:(Spell *)spell source:(Entity *)source target:(Entity *)target message:(NSString *__autoreleasing *)message
{
    return YES;
}

- (BOOL)handleSpellStarted:(Spell *)spell source:(Entity *)source target:(Entity *)target modifier:(NSMutableArray *)modifiers
{
    return NO;
}

- (BOOL)handleSpell:(Spell *)spell source:(Entity *)source target:(Entity *)target modifier:(NSMutableArray *)modifiers
{
    return NO;
}

- (void)addStack
{
    if ( self.currentStacks.integerValue < self.maxStacks.integerValue )
        self.currentStacks = @(self.currentStacks.integerValue + 1);
    self.startDate = [NSDate date];
    NSLog(@"%@ has gained a stack -> %@",self,self.currentStacks);
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
