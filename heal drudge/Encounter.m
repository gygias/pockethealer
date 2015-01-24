//
//  Encounter.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Encounter.h"

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
        
        [self _doDamage:ability source:source target:target periodic:periodicTick];
        
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

- (void)handleSpell:(Spell *)spell source:(Entity *)source target:(Entity *)target periodicTick:(BOOL)periodicTick
{
    // while implementing cast bar, encounter isn't started
    if ( ! _encounterQueue )
        return;
    
    dispatch_async(_encounterQueue, ^{
    
        NSLog(@"%@ has cast %@ on %@!",source,spell.name,target);
        [self _doDamage:spell source:source target:target periodic:periodicTick];
        [self _doHealing:spell source:source target:target periodic:periodicTick];
        spell.nextCooldownDate = [NSDate dateWithTimeIntervalSinceNow:spell.cooldown.doubleValue];
        
        [spell hitWithSource:source target:target];
        
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
        
        if ( self.encounterUpdatedHandler )
            self.encounterUpdatedHandler(self);
    });
}

- (void)_doDamage:(Spell *)spell source:(Entity *)source target:(Entity *)target periodic:(BOOL)periodic
{
    NSNumber *theDamage = periodic ? spell.periodicDamage : spell.damage;
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

- (void)_doHealing:(Spell *)spell source:(Entity *)source target:(Entity *)target periodic:(BOOL)periodic
{
    NSNumber *healingValue = periodic ? spell.periodicHeal : spell.healing;
    if ( healingValue.doubleValue > 0 )
    {
        NSInteger newHealth = target.currentHealth.doubleValue + healingValue.doubleValue;
        if ( newHealth > ((Player *)target).character.health.integerValue )
            newHealth = ((Player *)target).character.health.integerValue;
        
        target.currentHealth = @(newHealth);
        
        NSLog(@"%@ was healed for %@",target,healingValue);
    }
    
    NSNumber *absorbValue = periodic ? spell.periodicAbsorb : spell.absorb;
    if ( absorbValue.doubleValue > 0 )
    {
        NSInteger newAbsorb = target.currentAbsorb.doubleValue + absorbValue.doubleValue;
        //if ( newAbsorb > someAbsorbCeilingLikePercentageOfHealersHealth ) TODO
        //  newAbsorb = someAbsorbCeilingLikePercentageOfHealersHealth;
        
        target.currentAbsorb = @(newAbsorb);
        
        NSLog(@"%@ received a %@ absorb",target,absorbValue);
    }
}

@end
