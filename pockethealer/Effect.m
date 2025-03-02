//
//  Effect.m
//  heal drudge
//
//  Created by david on 1/23/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "Effect.h"
#import "Encounter.h"

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

- (BOOL)addModifiersWithSpell:(Spell *)spell modifiers:(NSMutableArray *)modifiers
{
    return NO;
}

- (void)handleSpell:(Spell *)spell modifier:(EventModifier *)modifier
{
}

- (void)handleTick:(BOOL)isInitialTick
{
}

- (BOOL)validateOwner:(Entity *)owner
{
    return YES;
}

- (void)handleStart
{
    if ( self.periodicTick.doubleValue > 0 )
    {
        [self schedulePeriodic];
    }
    else
    {
        [self refreshTimeout];
    }
}

- (void)schedulePeriodic
{
    self.startDate = [NSDate date];
    unsigned long totalTicks = self.duration / self.periodicTick.unsignedLongValue;
    __block unsigned long thisTick = 1;
    self.periodicTickSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.owner.encounter.encounterQueue);
    dispatch_source_set_timer(self.periodicTickSource, DISPATCH_TIME_NOW, self.periodicTick.doubleValue * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.periodicTickSource, ^{
        //unsigned long ticks = dispatch_source_get_data(statusEffect.periodicTickSource);
        [self handleTick:( thisTick == 1 )];
        if ( thisTick == totalTicks )
        {
            dispatch_source_cancel(self.periodicTickSource);
            self.periodicTickSource = NULL;
            self.timeoutHandler();
        }
        
        thisTick++;
    });
    dispatch_resume(self.periodicTickSource);
    PHLog(self,@"%@ will tick %lu times every %0.2f seconds and time out in %0.2f seconds",self,totalTicks,self.periodicTick.doubleValue,self.duration);
}

- (void)refreshTimeout
{
    PHLog(self,@"%@ will time out in %0.2f seconds",self,self.duration);
    NSDate *thisStartDate = [NSDate date];
    self.startDate = thisStartDate;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.duration * NSEC_PER_SEC)), self.owner.encounter.encounterQueue, ^{
        if ( thisStartDate == self.startDate )
            self.timeoutHandler();
    });
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
    [self refreshTimeout];
    PHLog(self.source,@"%@ has gained a stack -> %@",self,self.currentStacks);
}

- (void)removeStack
{
    if ( self.currentStacks > 0 )
        self.currentStacks = @(self.currentStacks.integerValue - 1);
}

- (void)addStacks:(NSUInteger)nStacks
{
    while( nStacks-- > 0 )
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
