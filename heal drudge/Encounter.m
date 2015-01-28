//
//  Encounter.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Encounter.h"

#import "EventModifier.h"

#import "SoundManager.h"//XXX

@implementation Encounter

@synthesize encounterQueue = _encounterQueue;

static Encounter *sYouAreATerribleProgrammer = nil;

- (id)init
{
    if ( self = [super init] )
    {
        sYouAreATerribleProgrammer = self;
    }
    
    return self;
}

+ (Encounter *)currentEncounter
{
    return sYouAreATerribleProgrammer;
}

- (void)start
{    
    [self.enemies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(Entity *)obj prepareForEncounter:self];
    }];
    
    [self.raid.players enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(Entity *)obj prepareForEncounter:self];
    }];
    
    NSInteger delay = 1;
    [SoundManager playCountdownWithStartIndex:@(delay)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        _encounterQueue = dispatch_queue_create("EncounterQueue", 0);
        
        [self.enemies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [(Entity *)obj beginEncounter:self];
        }];
        
        [self.raid.players enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [(Entity *)obj beginEncounter:self];
        }];
        
        // begin update timer
        _encounterTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _encounterQueue);
        dispatch_source_set_timer(_encounterTimer, DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC, 0.05 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(_encounterTimer, ^{
            [self updateEncounter];
        });
        dispatch_resume(_encounterTimer);
    });
}

- (void)end
{
    [self endEncounter];
}

- (void)updateEncounter
{
    [self.enemies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(Entity *)obj updateEncounter:self];
    }];
    
    [self.raid.players enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(Entity *)obj updateEncounter:self];
    }];
    
    if ( self.encounterUpdatedHandler )
        self.encounterUpdatedHandler(self);
}

- (void)endEncounter
{
    [self.enemies enumerateObjectsUsingBlock:^(Entity *enemy, NSUInteger idx, BOOL *stop) {
        NSLog(@"end encounter => %@",enemy);
        [enemy endEncounter:self];
    }];
    [self.raid.players enumerateObjectsUsingBlock:^(Entity *player, NSUInteger idx, BOOL *stop) {
        NSLog(@"end encounter => %@",player);
        [player endEncounter:self];
    }];
    
    if ( _encounterTimer )
    {
        dispatch_source_cancel(_encounterTimer);
        //dispatch_release(_encounterTimer);
        _encounterTimer = NULL;
    }
    
    if ( _encounterQueue )
    {
        _encounterQueue = NULL;
    }
    
    if ( self.encounterUpdatedHandler )
        self.encounterUpdatedHandler(self);
}

- (void)handleSpell:(Spell *)spell source:(Entity *)source target:(Entity *)target periodicTick:(BOOL)periodicTick periodicTickSource:(dispatch_source_t)periodicTickSource isFirstTick:(BOOL)firstTick
{
    // while implementing cast bar, encounter isn't started
    if ( ! _encounterQueue )
        return;
    
    dispatch_async(_encounterQueue, ^{
    
        NSLog(@"%@%@ %@ on %@!",source,periodicTick?@"'s channel is ticking":@" is casting",spell.name,target);
        
        if ( source.isEnemy && self.enemyAbilityHandler )
            self.enemyAbilityHandler((Enemy *)source,(Ability *)spell);
        
        NSMutableArray *modifiers = [NSMutableArray new];
        if ( [source handleSpell:spell asSource:YES otherEntity:target modifiers:modifiers] )
        {
            NSLog(@"%@->%@ modified %@",source,target,spell);
        }
        if ( [target handleSpell:spell asSource:NO otherEntity:source modifiers:modifiers] )
        {
            NSLog(@"%@->%@ modified %@",source,target,spell);
        }
        
        float volume = source.isPlayingPlayer ? HIGH_VOLUME : LOW_VOLUME;
        if ( spell.castSoundName )
            [SoundManager playSpellHit:spell.castSoundName volume:volume];
        if ( spell.hitSoundName )
            [SoundManager playSpellHit:spell.hitSoundName volume:volume];
        
        NSMutableArray *allTargets = [NSMutableArray new];
        if ( spell.isSmart )
        {
            NSArray *smartTargets = [self _smartTargetsForSpell:spell source:source target:target];
            if ( smartTargets )
                [allTargets addObjectsFromArray:smartTargets];
        }
        else if ( spell.affectsPartyOfTarget )
        {
            NSArray *partyTargets = [self.raid partyForEntity:target includingEntity:YES];
            if ( partyTargets )
                [allTargets addObjectsFromArray:partyTargets];
        }
        else
            [allTargets addObject:target];
        
        [allTargets enumerateObjectsUsingBlock:^(Entity *aTarget, NSUInteger idx, BOOL *stop) {
            if ( ! aTarget.isDead || spell.canBeCastOnDeadEntities )
            {
                if ( spell.spellType == BeneficialOrDeterimentalSpell )
                {
                    if ( target.isPlayer )
                        [self doHealing:spell source:source target:aTarget modifiers:modifiers periodic:periodicTick];
                    else
                        [self doDamage:spell source:source target:aTarget modifiers:modifiers periodic:periodicTick];                    
                }
                else if ( spell.spellType == DetrimentalSpell )
                    [self doDamage:spell source:source target:aTarget modifiers:modifiers periodic:periodicTick];
                else // ( spell.spellType == BeneficialSpell )
                    [self doHealing:spell source:source target:aTarget modifiers:modifiers periodic:periodicTick];
                
                [spell handleHitWithSource:source target:aTarget modifiers:modifiers];
            }
        }];
        
        if ( spell.cooldown.doubleValue && ( ! periodicTick || firstTick ) )
        {
            NSDate *thisNextCooldownDate = [NSDate dateWithTimeIntervalSinceNow:spell.cooldown.doubleValue];
            spell.nextCooldownDate = thisNextCooldownDate;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(spell.cooldown.doubleValue * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ( spell.nextCooldownDate == thisNextCooldownDate )
                {
                    NSLog(@"%@'s %@ has cooled down",source,spell);
                    spell.nextCooldownDate = nil;
                }
                else
                    NSLog(@"Something else seems to have reset the cooldown on %@'s %@",source,spell);
            });
        }
        
        if ( target.currentHealth.integerValue <= 0 )
        {
            if ( periodicTickSource )
                dispatch_source_cancel(periodicTickSource);
            
            [self.raid.players enumerateObjectsUsingBlock:^(Entity *obj, NSUInteger idx, BOOL *stop) {
                [obj handleDeathOfEntity:target fromSpell:spell];
            }];
            [self.enemies enumerateObjectsUsingBlock:^(Entity *obj, NSUInteger idx, BOOL *stop) {
                [obj handleDeathOfEntity:target fromSpell:spell];
            }];
            
            // source has to choose a new target
            if ( source.isEnemy && ! [(Enemy *)source targetNextThreatWithEncounter:self] )
            {
                NSLog(@"the encounter is over because there are no targets for %@",source);
                [self endEncounter];
            }
            else // TODO is there some ability by which players could kill themselves as the last one alive?
            {
                __block BOOL someEnemyIsAlive = NO;
                [self.enemies enumerateObjectsUsingBlock:^(Enemy *obj, NSUInteger idx, BOOL *stop) {
                    if ( ! obj.isDead )
                    {
                        someEnemyIsAlive = YES;
                        *stop = YES;
                    }
                }];
                if ( ! someEnemyIsAlive )
                {
                    NSLog(@"the encounter is over because all enemies are dead");
                    [self endEncounter];
                    return;
                }
            }
        }
        
        NSInteger effectiveCost = spell.manaCost.integerValue;
        if ( spell.isChanneled )
            effectiveCost = effectiveCost / spell.channelTicks.integerValue;
        source.currentResources = @(source.currentResources.integerValue - effectiveCost);
        
        if ( self.encounterUpdatedHandler )
            self.encounterUpdatedHandler(self);
    });
}

- (NSArray *)_smartTargetsForSpell:(Spell *)spell source:(Entity *)source target:(Entity *)target
{
    return @[ target ];
}

- (BOOL)entityIsTargetedByEntity:(Entity *)entity
{
    __block BOOL isTargeted = NO;
    [self.enemies enumerateObjectsUsingBlock:^(Entity *enemy, NSUInteger idx, BOOL *stop) {
        if ( enemy.target == entity )
        {
            isTargeted = YES;
            *stop = YES;
        }
    }];
    
    if ( isTargeted )
        return isTargeted;
    
//    [self.raid.players enumerateObjectsUsingBlock:^(Entity *player, NSUInteger idx, BOOL *stop) {
//        if ( player.target == entity )
//        {
//            isTargeted = YES;
//            *stop = YES;
//        }
//    }];
    
    return isTargeted;
}

- (void)doDamage:(Spell *)spell source:(Entity *)source target:(Entity *)target modifiers:(NSArray *)modifiers periodic:(BOOL)periodic
{
    __block NSNumber *rawDamage = periodic ? spell.periodicDamage : spell.damage;
    
    // deliberately applying all damage increases before decreases, TODO no idea if this is right
    __block EventModifier *greatestDamageTakenDecreaseModifier = nil;
    [modifiers enumerateObjectsUsingBlock:^(EventModifier *obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"considering %@ for damage of %@",obj,spell);
        if ( obj.damageIncrease )
            rawDamage = @( rawDamage.unsignedIntegerValue + obj.damageIncrease.unsignedIntegerValue );
        else if (obj.damageIncreasePercentage )
            rawDamage = @( rawDamage.doubleValue * ( 1 + obj.damageIncreasePercentage.doubleValue ) );
        if ( obj.damageTakenDecreasePercentage )
        {
            if ( ! greatestDamageTakenDecreaseModifier ||
                [greatestDamageTakenDecreaseModifier.damageTakenDecreasePercentage compare:obj.damageTakenDecreasePercentage] == NSOrderedAscending )
                greatestDamageTakenDecreaseModifier = obj;
        }
    }];
    
    // apply damage taken increases
    NSNumber *effectiveDamage = rawDamage;
    if ( greatestDamageTakenDecreaseModifier )
    {
        effectiveDamage = @( effectiveDamage.doubleValue * ( 1 - greatestDamageTakenDecreaseModifier.damageTakenDecreasePercentage.doubleValue ) );
        NSLog(@"applying %@ to %@, %@ -> %@",greatestDamageTakenDecreaseModifier,spell,rawDamage,effectiveDamage);
    }
    
    [target handleIncomingDamage:effectiveDamage];
//    NSInteger newAbsorb = target.currentAbsorb.doubleValue - effectiveDamage.doubleValue;
//    if ( newAbsorb < 0 )
//        newAbsorb = 0;
//    
//    NSInteger amountAbsorbed = target.currentAbsorb.doubleValue - newAbsorb;
//    NSInteger effectiveDamageMinusAbsorbs = ( effectiveDamage.doubleValue - amountAbsorbed );
}

- (void)doHealing:(Spell *)spell source:(Entity *)source target:(Entity *)target modifiers:(NSArray *)modifiers periodic:(BOOL)periodic
{
    __block NSNumber *healingValue = periodic ? spell.periodicHeal : spell.healing;
    
    if ( healingValue.doubleValue > 0 )
    {
        [modifiers enumerateObjectsUsingBlock:^(EventModifier *obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"considering %@ for healing of %@",obj,spell);
            if ( obj.healingIncrease )
                healingValue = @( healingValue.unsignedIntegerValue + obj.healingIncrease.unsignedIntegerValue );
            else if ( obj.healingIncreasePercentage )
                healingValue = @( healingValue.doubleValue * ( 1 + obj.healingIncreasePercentage.doubleValue ) );
        }];
        
        NSInteger newHealth = target.currentHealth.doubleValue + healingValue.doubleValue;
        if ( newHealth > target.health.integerValue )
            newHealth = target.health.integerValue;
        
        target.currentHealth = @(newHealth);
        
        NSLog(@"%@ was healed for %@",target,healingValue);
    }
    
    __block NSNumber *absorbValue = periodic ? spell.periodicAbsorb : spell.absorb;
    
    if ( absorbValue.doubleValue > 0 )
    {
        [modifiers enumerateObjectsUsingBlock:^(EventModifier *obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"considering %@ for absorb of %@",obj,spell);
            if ( obj.healingIncrease )
                absorbValue = @( absorbValue.unsignedIntegerValue + obj.healingIncrease.unsignedIntegerValue );
            else if ( obj.healingIncreasePercentage )
                absorbValue = @( absorbValue.doubleValue * ( 1 + obj.healingIncreasePercentage.doubleValue ) );
        }];
        
//        NSInteger newAbsorb = target.currentAbsorb.doubleValue + absorbValue.doubleValue;
//        //if ( newAbsorb > someAbsorbCeilingLikePercentageOfHealersHealth ) TODO
//        //  newAbsorb = someAbsorbCeilingLikePercentageOfHealersHealth;
//        
//        target.currentAbsorb = @(newAbsorb);
        
        NSLog(@"%@ received a %@ absorb",target,absorbValue);
    }
}

@end
