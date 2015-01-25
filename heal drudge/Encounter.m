//
//  Encounter.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Encounter.h"

#import "EventModifier.h"

@implementation Encounter

- (void)start
{
    [self.enemies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(Entity *)obj beginEncounter:self];
    }];
    
    [self.raid.players enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(Entity *)obj beginEncounter:self];
    }];
    
    // begin update timer
    _encounterQueue = dispatch_queue_create("EncounterQueue", 0);
    _encounterTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _encounterQueue);
    dispatch_source_set_timer(_encounterTimer, DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC, 0.05 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_encounterTimer, ^{
        [self updateEncounter];
    });
    dispatch_resume(_encounterTimer);
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
    
    dispatch_source_cancel(_encounterTimer);
    //dispatch_release(_encounterTimer);
    _encounterTimer = NULL;
    //dispatch_release(_encounterQueue);
    _encounterQueue = NULL;
    
    if ( self.encounterUpdatedHandler )
        self.encounterUpdatedHandler(self);
}

- (void)handleAbility:(Ability *)ability source:(Entity *)source target:(Entity *)target periodicTick:(BOOL)periodicTick
{
    // while implementing cast bar, encounter isn't started
    if ( ! _encounterQueue )
        return;
    
    dispatch_async(_encounterQueue, ^{
        
        NSMutableArray *modifiers = [NSMutableArray new];
        if ( [source handleSpell:ability asSource:YES otherEntity:target modifiers:modifiers] )
        {
            NSLog(@"%@->%@ modified %@",source,target,ability);
        }
        
        [self _doDamage:ability source:source target:target modifiers:modifiers periodic:periodicTick];
        
        if ( target.currentHealth.integerValue <= 0 )
        {
            [target handleDeathFromAbility:ability];
            
            // source has to choose a new target
            if ( ! [(Enemy *)source targetNextThreatWithEncounter:self] )
            {
                NSLog(@"the encounter is over because there are no targets for %@",source);
                [self endEncounter];
            }
        }
        
        if ( self.encounterUpdatedHandler )
            self.encounterUpdatedHandler(self);
    });
}

- (void)handleSpell:(Spell *)spell source:(Entity *)source target:(Entity *)target periodicTick:(BOOL)periodicTick isFirstTick:(BOOL)firstTick
{
    // while implementing cast bar, encounter isn't started
    if ( ! _encounterQueue )
        return;
    
    dispatch_async(_encounterQueue, ^{
    
        NSLog(@"%@%@ %@ on %@!",source,periodicTick?@"'s channel is ticking":@"is casting",spell.name,target);
        
        NSMutableArray *modifiers = [NSMutableArray new];
        if ( [source handleSpell:spell asSource:YES otherEntity:target modifiers:modifiers] )
        {
            NSLog(@"%@->%@ modified %@",source,target,spell);
        }
        
        if ( spell.spellType != BeneficialSpell && target.isEnemy )
            [self _doDamage:spell source:source target:target modifiers:modifiers periodic:periodicTick];
        if ( spell.spellType != DetrimentalSpell && target.isPlayer )
            [self _doHealing:spell source:source target:target modifiers:modifiers periodic:periodicTick];
        
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
        
        [spell handleHitWithSource:source target:target modifiers:modifiers];
        
        if ( target.currentHealth.integerValue <= 0 )
        {
            [target handleDeathFromAbility:nil];
            
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
        
        NSInteger effectiveCost = spell.manaCost.integerValue;
        if ( spell.isChanneled )
            effectiveCost = effectiveCost / spell.channelTicks.integerValue;
        source.currentResources = @(source.currentResources.integerValue - effectiveCost);
        
        if ( self.encounterUpdatedHandler )
            self.encounterUpdatedHandler(self);
    });
}

- (void)_doDamage:(Spell *)spell source:(Entity *)source target:(Entity *)target modifiers:(NSArray *)modifiers periodic:(BOOL)periodic
{
    __block NSNumber *theDamage = periodic ? spell.periodicDamage : spell.damage;
    
    [modifiers enumerateObjectsUsingBlock:^(EventModifier *obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"considering %@ for damage of %@",obj,spell);
        if ( obj.damageIncrease )
            theDamage = @( theDamage.unsignedIntegerValue + obj.damageIncrease.unsignedIntegerValue );
        else if (obj.damageIncreasePercentage )
            theDamage = @( theDamage.doubleValue * ( 1 + obj.damageIncreasePercentage.doubleValue ) );
    }];
    
    NSInteger newAbsorb = target.currentAbsorb.doubleValue - theDamage.doubleValue;
    if ( newAbsorb < 0 )
        newAbsorb = 0;
    
    NSInteger amountAbsorbed = target.currentAbsorb.doubleValue - newAbsorb;
    NSInteger effectiveDamage = ( theDamage.doubleValue - amountAbsorbed );
    
    NSInteger newHealth = target.currentHealth.doubleValue - effectiveDamage;
    if ( newHealth < 0 )
        newHealth = 0;
    
    target.currentAbsorb = @(newAbsorb);
    target.currentHealth = @(newHealth);
    
    NSLog(@"%@ took %ld damage (%ld absorbed)",target,effectiveDamage,amountAbsorbed);
}

- (void)_doHealing:(Spell *)spell source:(Entity *)source target:(Entity *)target modifiers:(NSArray *)modifiers periodic:(BOOL)periodic
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
        if ( newHealth > ((Player *)target).health.integerValue )
            newHealth = ((Player *)target).health.integerValue;
        
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
        
        NSInteger newAbsorb = target.currentAbsorb.doubleValue + absorbValue.doubleValue;
        //if ( newAbsorb > someAbsorbCeilingLikePercentageOfHealersHealth ) TODO
        //  newAbsorb = someAbsorbCeilingLikePercentageOfHealersHealth;
        
        target.currentAbsorb = @(newAbsorb);
        
        NSLog(@"%@ received a %@ absorb",target,absorbValue);
    }
}

@end
