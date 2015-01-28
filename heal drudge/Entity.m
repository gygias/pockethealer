//
//  Entity.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Entity.h"

#import "Encounter.h"
#import "Effect.h"
#import "Spell.h"
#import "ItemLevelAndStatsConverter.h"

#import "GenericDamageSpell.h"
#import "GenericHealingSpell.h"
#import "SoundManager.h"

@implementation Entity

@synthesize currentHealth = _currentHealth,
            currentResources = _currentResources,
            statusEffects = _statusEffects,
            periodicEffectQueue = _periodicEffectQueue;

- (id)init
{
    if ( self = [super init] )
    {
        self.emittingSounds = [NSMutableArray new];
    }
    return self;
}

- (dispatch_queue_t)periodicEffectQueue
{
    if ( ! _periodicEffectQueue )
    {
        NSString *queueName = [NSString stringWithFormat:@"%@-PeriodicEffectQueue",self];
        _periodicEffectQueue = dispatch_queue_create([queueName UTF8String], 0);
    }
    
    return _periodicEffectQueue;
}

- (BOOL)validateSpell:(Spell *)spell asSource:(BOOL)asSource otherEntity:(Entity *)otherEntity message:(NSString **)messagePtr invalidDueToCooldown:(BOOL *)invalidDueToCooldown
{
    Entity *source = asSource ? self : otherEntity;
    Entity *target = asSource ? otherEntity : self;
    
    if ( source.currentResources.integerValue < spell.manaCost.integerValue )
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
        
        if ( ! [obj validateSpell:spell asEffectOfSource:asSource source:source target:target message:messagePtr] )
        {
            okay = NO;
            *stop = YES;
        }
    }];
    
    [target.statusEffects enumerateObjectsUsingBlock:^(Effect *obj, NSUInteger idx, BOOL *stop) {
        if ( ! [obj validateSpell:spell asEffectOfSource:!asSource source:source target:target message:messagePtr] )
        {
            okay = NO;
            *stop = YES;
        }
    }];
    
    if ( okay )
    {
        if ( spell.nextCooldownDate || self.nextGlobalCooldownDate )
        {
            if ( messagePtr )
                *messagePtr = @"Not ready yet";
            if ( invalidDueToCooldown )
                *invalidDueToCooldown = YES;
            return NO;
        }
    }
    
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
        if ( [obj handleSpellStarted:spell asSource:asSource source:source target:target modifier:modifiers handler:^(BOOL consumesEffect) {
            // this is fucking hideous
            if ( consumesEffect )
            {
                dispatch_async(dispatch_get_current_queue(), ^{
                    [self removeStatusEffect:obj];
                });
            }
        }] )
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
        if ( [obj handleSpell:spell asSource:asSource source:source target:target modifier:modifiers handler:^(BOOL consumesEffect) {
            // this is fucking hideous
            if ( consumesEffect )
            {
                dispatch_async(dispatch_get_current_queue(), ^{
                    [self removeStatusEffect:obj];
                });
            }
        }] )
            addedModifiers = YES;
    }];
    
    return addedModifiers;
}

- (BOOL)handleSpellEnd:(Spell *)spell asSource:(BOOL)asSource otherEntity:(Entity *)otherEntity modifiers:(NSMutableArray *)modifiers
{
    return NO;
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

- (void)handleDeathOfEntity:(Entity *)dyingEntity fromAbility:(Ability *)ability
{
    if ( dyingEntity == self )
    {
        NSLog(@"%@ has died",self);
        self.isDead = YES;
        
        Effect *aStatusEffect = nil;
        while ( ( aStatusEffect = [self.statusEffects lastObject] ) )
            [self removeStatusEffect:aStatusEffect];
        
        self.castingSpell = nil;
        if ( self.automaticAbilitySource )
        {
            dispatch_source_cancel(self.automaticAbilitySource);
            self.automaticAbilitySource = NULL;
        }
    }
    
    if ( dyingEntity.isPlayer )
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
            
            float volume = self.isPlayingPlayer ? HIGH_VOLUME : LOW_VOLUME;
            [SoundManager playSpellFizzle:self.castingSpell.school volume:volume];
            self.castingSpell = nil;
        }
    }
}

- (void)prepareForEncounter:(Encounter *)encounter
{
    self.currentHealth = self.health;
    self.currentResources = self.power;
}

- (void)beginEncounter:(Encounter *)encounter
{
    NSLog(@"i, %@ (%@), should begin encounter",self,self.isPlayingPlayer?@"playing player":@"automated player");
    
    if ( ! self.isPlayingPlayer && self.isPlayer )
    {
        self.automaticAbilitySource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, encounter.encounterQueue);
        NSNumber *gcd = [ItemLevelAndStatsConverter globalCooldownWithEntity:self hasteBuffPercentage:nil];
        NSNumber *gcdWithStagger = @( ( arc4random() % (int)gcd.doubleValue * 100000 ) / 100000 + gcd.doubleValue );
        dispatch_source_set_timer(self.automaticAbilitySource, DISPATCH_TIME_NOW, gcdWithStagger.doubleValue * NSEC_PER_SEC, 0.01 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(self.automaticAbilitySource, ^{
            
            [self _doAutomaticStuffWithEncounter:encounter];
            
        });
        dispatch_resume(self.automaticAbilitySource);
    }
}

- (void)_doAutomaticStuffWithEncounter:(Encounter *)encounter
{
    //if ( ! self.lastAutomaticAbilityDate ||
    //    [[NSDate date] timeIntervalSinceDate:self.lastAutomaticAbilityDate] )
    //NSLog(@"%@ is doing automated stuff",self);
    {
        if ( [self.hdClass.role isEqualToString:(NSString *)TankRole] )
        {
            [self _doAutomaticTankingWithEncounter:encounter];
        }
        else if ( [self.hdClass.role isEqualToString:(NSString *)DPSRole] )
        {
            [self _doAutomaticDPSWithEncounter:encounter];
        }
        else if ( [self.hdClass.role isEqualToString:(NSString *)HealerRole] )
        {
            [self _doAutomaticHealingWithEncounter:encounter];
        }
        
        self.lastAutomaticAbilityDate = [NSDate date];
    }
}

- (void)_doAutomaticTankingWithEncounter:(Encounter *)encounter
{
    NSInteger randomEnemy = arc4random() % encounter.enemies.count;
    Entity *enemy = encounter.enemies[randomEnemy];
    Spell *spell = [[GenericDamageSpell alloc] initWithCaster:self];
    self.target = enemy;
    //[encounter doDamage:spell source:self target:enemy modifiers:nil periodic:NO];
    //- (NSNumber *)castSpell:(Spell *)spell withTarget:(Entity *)target inEncounter:(Encounter *)encounter;
    [self castSpell:spell withTarget:enemy inEncounter:encounter];
}

- (void)_doAutomaticDPSWithEncounter:(Encounter *)encounter
{
    NSInteger randomEnemy = arc4random() % encounter.enemies.count;
    Entity *enemy = encounter.enemies[randomEnemy];
    Spell *spell = [[GenericDamageSpell alloc] initWithCaster:self];
    self.target = enemy;
    //[encounter doDamage:spell source:self target:enemy modifiers:nil periodic:NO];
    //- (NSNumber *)castSpell:(Spell *)spell withTarget:(Entity *)target inEncounter:(Encounter *)encounter;
    [self castSpell:spell withTarget:enemy inEncounter:encounter];
}

- (void)_doAutomaticHealingWithEncounter:(Encounter *)encounter
{
    if ( self.castingSpell )
        return;
    
    [encounter.raid.players enumerateObjectsUsingBlock:^(Entity *player, NSUInteger idx, BOOL *stop) {
        if ( player.currentHealth.doubleValue < player.health.doubleValue )
        {
            //NSNumber *averageHealing = [ItemLevelAndStatsConverter automaticHealValueWithEntity:self];
            Spell *spell = [[GenericHealingSpell alloc] initWithCaster:self];
            NSLog(@"%@ is healing %@ for %@",self,player,spell.healing);
            self.target = player;
            //[encounter doHealing:spell source:self target:player modifiers:nil periodic:NO];
            [self castSpell:spell withTarget:player inEncounter:encounter];
            //player.currentHealth = ( player.currentHealth.doubleValue + averageHealing.doubleValue > player.health.doubleValue ) ?
            //                        ( player.health ) : @( player.currentHealth.doubleValue + averageHealing.doubleValue );
        }
    }];
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
    return [NSString stringWithFormat:@"%@ [%@,%@]",self.name,self.currentHealth,self.currentResources];
}



- (NSNumber *)castSpell:(Spell *)spell withTarget:(Entity *)target inEncounter:(Encounter *)encounter
{
    __block NSNumber *effectiveCastTime = nil;
    
    if ( self.castingSpell )
    {
        NSLog(@"%@ cancelled casting %@",self,self.castingSpell);
        self.castingSpell = nil;
        self.castingSpell.lastCastStartDate = nil;
        
        float volume = self.isPlayingPlayer ? HIGH_VOLUME : LOW_VOLUME;
        [SoundManager playSpellFizzle:spell.school volume:volume];
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
        
        // TODO
        if ( self.isPlayer )
        {
            float volume = self.isPlayingPlayer ? HIGH_VOLUME : LOW_VOLUME;
            [SoundManager playSpellSound:spell.school level:spell.level volume:volume duration:effectiveCastTime.doubleValue handler:^(id sound){
                //NSLog(@"%@ started emitting %@",self,sound);
                [self.emittingSounds addObject:sound];
            }];
        }
        
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
                    self.castingSpell = nil;
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

@end
