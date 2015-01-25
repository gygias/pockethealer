//
//  Player.m
//  heal drudge
//
//  Created by david on 1/2/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Player.h"
#import "ItemLevelAndStatsConverter.h"
#import "Spell.h"
#import "Encounter.h"
#import "Effect.h"

#define HD_NAME_MIN 3
#define HD_NAME_MAX 12

@implementation Player

@synthesize castingSpell = _castingSpell;

- (id)init
{
    if ( self = [super init] )
    {
        self.isPlayer = YES;
    }
    return self;
}

- (NSNumber *)castSpell:(Spell *)spell withTarget:(Entity *)target inEncounter:(Encounter *)encounter
{
    __block NSNumber *effectiveCastTime = nil;
    
    if ( self.castingSpell )
    {
        NSLog(@"%@ cancelled casting %@",self,self.castingSpell);
        _castingSpell = nil;
        _castingSpell.lastCastStartDate = nil;
    }
    
    if ( spell.isChanneled || spell.castTime.doubleValue > 0 )
    {
        NSLog(@"%@ started %@ %@",self,spell.isChanneled?@"channeling":@"casting",spell);
        
        NSMutableArray *modifiers = [NSMutableArray new];
        if ( [self handleSpellStart:spell asSource:YES otherEntity:target modifiers:modifiers] )
        {
        }
        
        _castingSpell = spell;
        NSDate *thisCastStartDate = [NSDate date];
        self.castingSpell.lastCastStartDate = thisCastStartDate;
        
        __block NSNumber *hasteBuff = nil;
        
        [modifiers enumerateObjectsUsingBlock:^(EventModifier *obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"considering %@ for %@",obj,spell);
            if ( obj.hasteIncreasePercentage )
            {
                if ( ! hasteBuff || [obj.hasteIncreasePercentage compare:hasteBuff] == NSOrderedDescending )
                    hasteBuff = obj.hasteIncreasePercentage; // oh yeah, we're not using haste at all yet
            }
        }];
        
        if ( hasteBuff )
            NSLog(@"%@'s haste is buffed by %@",self,hasteBuff);
        
        NSTimeInterval effectiveGCD = [ItemLevelAndStatsConverter globalCooldownWithEntity:self hasteBuffPercentage:hasteBuff].doubleValue;
        self.nextGlobalCooldownDate = [NSDate dateWithTimeIntervalSinceNow:effectiveGCD];
        self.currentGlobalCooldownDuration = effectiveGCD;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(effectiveGCD * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.nextGlobalCooldownDate = nil;
            self.currentGlobalCooldownDuration = 0;
        });
        
        // get base cast time
        effectiveCastTime = [ItemLevelAndStatsConverter castTimeWithBaseCastTime:spell.castTime entity:self hasteBuffPercentage:hasteBuff];
        
        if ( spell.isChanneled )
        {
            NSTimeInterval timeBetweenTicks = effectiveCastTime.doubleValue / spell.channelTicks.doubleValue;
            __block NSInteger ticksRemaining = spell.channelTicks.unsignedIntegerValue;
            __block BOOL firstTick = YES;
            dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
            dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, timeBetweenTicks * NSEC_PER_SEC, 0.01 * NSEC_PER_SEC);
            dispatch_source_set_event_handler(timer, ^{
                NSLog(@"%@ is channel-ticking",spell);
                [encounter handleSpell:spell source:self target:target periodicTick:YES isFirstTick:firstTick];
                firstTick = NO;
                if ( --ticksRemaining <= 0 )
                {
                    NSLog(@"%@ has finished channeling",spell);
                    dispatch_source_cancel(timer);
                }
            });
            dispatch_resume(timer);
        }
        else
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(effectiveCastTime.doubleValue * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // blah
                if ( thisCastStartDate != self.castingSpell.lastCastStartDate )
                {
                    NSLog(@"%@ was aborted because it is no longer the current spell at dispatch time",spell);
                    return;
                }
                [encounter handleSpell:self.castingSpell source:self target:target periodicTick:NO isFirstTick:NO];
                _castingSpell = nil;
                NSLog(@"%@ finished casting %@",self,spell);
            });
        }
    }
    else
    {
        NSLog(@"%@ cast %@ (instant)",self,spell);
        [encounter handleSpell:spell source:self target:target periodicTick:NO isFirstTick:NO];
    }
    
    return effectiveCastTime;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ [%@,%@]",self.name,self.currentHealth,self.currentResources];
}

@end
