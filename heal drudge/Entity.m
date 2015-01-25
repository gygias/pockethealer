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
#import "ItemLevelAndStatsConverter.h"

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

- (BOOL)validateSpell:(Spell *)spell asSource:(BOOL)asSource otherEntity:(Entity *)otherEntity message:(NSString **)messagePtr
{
    Entity *source = asSource ? self : otherEntity;
    Entity *target = asSource ? otherEntity : self;
    
    if ( spell.nextCooldownDate )
    {
        if ( messagePtr )
            *messagePtr = @"Not ready yet";
        return NO;
    }
    else if ( source.currentResources.integerValue < spell.manaCost.integerValue )
    {
        if ( messagePtr )
            *messagePtr = @"Not enough mana";
        return NO;
    }
    else if ( source.isDead )
    {
        if ( messagePtr )
            *messagePtr = @"You are dead";
        return NO;
    }
    else if ( target.isDead && ! spell.canBeCastOnDeadEntities )
    {
        if ( messagePtr )
            *messagePtr = @"Target is dead";
        return NO;
    }
    else if ( spell.spellType == DetrimentalSpell )
    {
        if ( target.isPlayer )
        {
            if ( messagePtr )
                *messagePtr = @"Invalid target";
            return NO;
        }
    }
    else if ( spell.spellType == BeneficialSpell )
    {
        if ( target.isEnemy )
        {
            if ( messagePtr )
                *messagePtr = @"Invalid target";
            return NO;
        }
    }
        
    if ( ! [spell validateWithSource:source target:self message:messagePtr] )
        return NO;
    
    __block BOOL okay = YES;
    [_statusEffects enumerateObjectsUsingBlock:^(Effect *obj, NSUInteger idx, BOOL *stop) {
        
        if ( ! [obj validateSpell:spell source:source target:self message:messagePtr] )
        {
            okay = NO;
            *stop = YES;
        }
    }];
    
    return okay;
}

- (BOOL)handleSpellStart:(Spell *)spell asSource:(BOOL)asSource otherEntity:(Entity *)otherEntity modifiers:(NSMutableArray *)modifiers
{
    __block BOOL addedModifiers = NO;
    
    Entity *source = asSource ? self : otherEntity;
    Entity *target = asSource ? otherEntity : self;
    if ( [spell handleStartWithSource:source target:target modifiers:modifiers] )
        addedModifiers = YES;
    
    [self.statusEffects enumerateObjectsUsingBlock:^(Effect *obj, NSUInteger idx, BOOL *stop) {
        if ( [obj handleSpellStarted:spell source:source target:target modifier:modifiers] )
            addedModifiers = YES;
    }];
    
    return addedModifiers;
}

- (BOOL)handleSpell:(Spell *)spell asSource:(BOOL)asSource otherEntity:(Entity *)otherEntity modifiers:(NSMutableArray *)modifiers
{
    __block BOOL addedModifiers = NO;
    
    Entity *source = asSource ? self : otherEntity;
    Entity *target = asSource ? otherEntity : self;
    
    [self.statusEffects enumerateObjectsUsingBlock:^(Effect *obj, NSUInteger idx, BOOL *stop) {
        if ( [obj handleSpell:spell source:source target:target modifier:modifiers] )
            addedModifiers = YES;
    }];
    
    return addedModifiers;
}

- (void)addStatusEffect:(Effect *)statusEffect source:(Entity *)source
{
    if ( ! _statusEffects )
        _statusEffects = [NSMutableArray new];
    statusEffect.startDate = [NSDate date];
    statusEffect.source = source;
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
    self.currentHealth = self.health;
    self.currentResources = self.power;
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

// character


@synthesize image; // no fucking idea XXX

+ (NSArray *)primaryStatKeys
{
    return @[ @"intellect", @"strength", @"agility" ];
}

+ (NSArray *)secondaryStatKeys
{
    return @[ @"critRating", @"hasteRating", @"masteryRating" ];
}

+ (NSArray *)tertiaryStatKeys
{
    return @[ @"versatilityRating", @"multistrikeRating", @"leechRating" ];
}

- (NSNumber *)health
{
    return [ItemLevelAndStatsConverter healthFromStamina:self.stamina];
}

- (NSNumber *)baseMana
{
    return self.power;
}

- (NSNumber *)spellPower
{
    return [ItemLevelAndStatsConverter spellPowerFromIntellect:self.intellect];
}

- (NSNumber *)attackPower
{
    return [ItemLevelAndStatsConverter attackPowerBonusFromAgility:self.agility andStrength:self.strength];
}

- (NSNumber *)primaryStat
{
    return [self valueForKey:self.hdClass.primaryStatKey];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%@)",self.name,self.hdClass];
    //return [NSString stringWithFormat:@"%@ (%@)\n\t%@ health %@ power %@ int %@ agil %@ str %@ crit %@ haste %@ mastery",self.name,self.hdClass,self.health,self.power,self.intellect,self.agility,self.strength,self.critRating,self.hasteRating,self.masteryRating];
}

@end
