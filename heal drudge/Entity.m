//
//  Entity.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Entity.h"

#import "Effect.h"
#import "Spell.h"

@implementation Entity

@synthesize currentHealth = _currentHealth,
            currentResources = _currentResources,
            statusEffects = _statusEffects,
            periodicEffectQueue = _periodicEffectQueue;

- (dispatch_queue_t)periodicEffectQueue
{
    if ( ! _periodicEffectQueue )
    {
        NSString *queueName = [NSString stringWithFormat:@"%@-PeriodicEffectQueue",self];
        _periodicEffectQueue = dispatch_queue_create([queueName UTF8String], 0);
    }
    
    return _periodicEffectQueue;
}

- (BOOL)validateSpell:(Spell *)spell withSource:(Entity *)source message:(NSString **)messagePtr
{
    if ( ! spell.isBeneficial )
    {
        if ( [NSStringFromClass([self class]) isEqualToString:@"Player"] ) // XXX
        {
            if ( messagePtr )
                *messagePtr = @"Invalid target";
            return NO;
        }
    }
    else
    {
        if ( [NSStringFromClass([self class]) isEqualToString:@"Enemy"] )
        {
            if ( messagePtr )
                *messagePtr = @"Invalid target";
            return NO;
        }
    }
    
    if ( ! [spell validateWithSource:source target:self.target message:messagePtr] )
        return NO;
    
    __block BOOL okay = YES;
    [_statusEffects enumerateObjectsUsingBlock:^(Effect *obj, NSUInteger idx, BOOL *stop) {
        
        if ( ! [obj validateSpell:spell source:self target:self.target message:messagePtr] )
        {
            okay = NO;
            *stop = YES;
        }
    }];
    return okay;
}

- (void)addStatusEffect:(Effect *)statusEffect
{
    if ( ! _statusEffects )
        _statusEffects = [NSMutableArray new];
    statusEffect.startDate = [NSDate date];
    [(NSMutableArray *)_statusEffects addObject:statusEffect];
    NSLog(@"%@ is affected by %@",self,statusEffect);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(statusEffect.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ( [_statusEffects containsObject:statusEffect] )
        {
            NSLog(@"%@ on %@ has timed out",statusEffect,self);
            [(NSMutableArray *)_statusEffects removeObject:statusEffect];
        }
        else
            NSLog(@"%@ on %@ was removed some other way",statusEffect,self);
    });
}

- (void)removeStatusEffect:(Effect *)effect
{
    [(NSMutableArray *)_statusEffects removeObject:effect];
    NSLog(@"removed %@'s %@",self,effect);
}

- (void)removeStatusEffectNamed:(NSString *)statusEffectName
{
    __block id object = nil;
    [_statusEffects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ( [NSStringFromClass([obj class]) isEqualToString:statusEffectName] )
        {
            object = obj;
            *stop = YES;
        }
    }];
    
    if ( object )
        [self removeStatusEffect:object];
}

- (void)handleDeathFromAbility:(Ability *)ability
{
    NSLog(@"%@ has died",self);
    self.isDead = YES;
}

- (void)beginEncounter:(Encounter *)encounter
{
    //NSLog(@"i, %@, should begin encounter",self);
}

- (void)updateEncounter:(Encounter *)encounter
{
    //NSLog(@"i, %@, should update encounter",self);
    
    // TODO enumerate and remove status effects
}

- (void)endEncounter:(Encounter *)encounter
{
    //NSLog(@"i, %@, should end encounter",self);
    self.stopped = YES;
}

@end
