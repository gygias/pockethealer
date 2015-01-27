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
#import "SoundManager.h"

#define HD_NAME_MIN 3
#define HD_NAME_MAX 12

@implementation Player

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
        self.castingSpell = nil;
        self.castingSpell.lastCastStartDate = nil;
        
        [SoundManager playSpellFizzle:spell.school];
    }
    
    NSLog(@"%@ started %@ %@ at %@",self,spell.isChanneled?@"channeling":@"casting",spell,target);
    
    NSMutableArray *modifiers = [NSMutableArray new];
    if ( [self handleSpellStart:spell asSource:YES otherEntity:target modifiers:modifiers] )
    {
    }
    
    __block NSNumber *hasteBuff = nil;
    [modifiers enumerateObjectsUsingBlock:^(EventModifier *obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"considering %@ for %@",obj,spell);
        if ( obj.hasteIncreasePercentage )
        {
            if ( ! hasteBuff || [obj.hasteIncreasePercentage compare:hasteBuff] == NSOrderedDescending )
                hasteBuff = obj.hasteIncreasePercentage; // oh yeah, we're not using haste at all yet
        }
    }];
    
    if ( spell.triggersGCD )
    {
        NSTimeInterval effectiveGCD = [ItemLevelAndStatsConverter globalCooldownWithEntity:self hasteBuffPercentage:hasteBuff].doubleValue;
        self.nextGlobalCooldownDate = [NSDate dateWithTimeIntervalSinceNow:effectiveGCD];
        self.currentGlobalCooldownDuration = effectiveGCD;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(effectiveGCD * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.nextGlobalCooldownDate = nil;
            self.currentGlobalCooldownDuration = 0;
        });
    }
    
    if ( spell.isChanneled || spell.castTime.doubleValue > 0 )
    {
        self.castingSpell = spell;
        self.castingSpell.target = target;
        NSDate *thisCastStartDate = [NSDate date];
        self.castingSpell.lastCastStartDate = thisCastStartDate;
        
        if ( hasteBuff )
            NSLog(@"%@'s haste is buffed by %@",self,hasteBuff);
        
        // get base cast time
        effectiveCastTime = [ItemLevelAndStatsConverter castTimeWithBaseCastTime:spell.castTime entity:self hasteBuffPercentage:hasteBuff];
        
        [SoundManager playSpellSound:spell.school level:spell.level duration:effectiveCastTime.doubleValue handler:^(id sound){
            NSLog(@"%@ started emitting %@",self,sound);
            [self.emittingSounds addObject:sound];
        }];
        
        if ( spell.isChanneled )
        {
            NSTimeInterval timeBetweenTicks = effectiveCastTime.doubleValue / spell.channelTicks.doubleValue;
            __block NSInteger ticksRemaining = spell.channelTicks.unsignedIntegerValue;
            __block BOOL firstTick = YES;
            dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
            dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, timeBetweenTicks * NSEC_PER_SEC, 0.01 * NSEC_PER_SEC);
            dispatch_source_set_event_handler(timer, ^{
                NSLog(@"%@ is channel-ticking",spell);
                
                [encounter handleSpell:spell source:self target:target periodicTick:YES periodicTickSource:timer isFirstTick:firstTick];
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
                [encounter handleSpell:self.castingSpell source:self target:target periodicTick:NO periodicTickSource:NULL isFirstTick:NO];
                self.castingSpell = nil;
                NSLog(@"%@ finished casting %@",self,spell);
            });
        }
    }
    else
    {
        NSLog(@"%@ cast %@ (instant)",self,spell);
        [encounter handleSpell:spell source:self target:target periodicTick:NO periodicTickSource:NULL isFirstTick:NO];
    }
    
    return effectiveCastTime;
}

- (void)handleDeathOfEntity:(Entity *)dyingEntity fromAbility:(Ability *)ability
{
    if ( dyingEntity == self )
    {
        [SoundManager playDeathSound];
        self.castingSpell = nil;
        
        // TODO this is not right, SoundManager should probably manage emitted sounds-per-entity
        [self.emittingSounds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"stopping %@",obj);
            [obj stop];
        }];
        [self.emittingSounds removeAllObjects];
    }
    else if ( self.castingSpell && dyingEntity == self.castingSpell.target )
    {
        NSLog(@"%@ aborting %@ because %@ died",self,self.castingSpell,dyingEntity);
        
        // TODO this is not right, SoundManager should probably manage emitted sounds-per-entity
        [self.emittingSounds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"stopping %@",obj);
            [obj stop];
        }];
        [self.emittingSounds removeAllObjects];
        
        [SoundManager playSpellFizzle:self.castingSpell.school];
        self.castingSpell = nil;
    }
    [super handleDeathOfEntity:dyingEntity fromAbility:ability];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ [%@,%@]",self.name,self.currentHealth,self.currentResources];
}

@end
