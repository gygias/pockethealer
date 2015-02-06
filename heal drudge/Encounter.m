//
//  Encounter.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "Encounter.h"
#import "Event.h"
#import "EventModifier.h"
#import "ItemLevelAndStatsConverter.h"

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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay + 2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        _encounterQueue = dispatch_queue_create("EncounterQueue", 0);
        
        [self.enemies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [(Entity *)obj beginEncounter:self];
        }];
        
        [self.raid.players enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [(Entity *)obj beginEncounter:self];
        }];
        
        // begin update timer
        _encounterTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _encounterQueue);
        dispatch_source_set_timer(_encounterTimer, DISPATCH_TIME_NOW, 0.005 * NSEC_PER_SEC, 0.05 * NSEC_PER_SEC);
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
    [self.enemies enumerateObjectsUsingBlock:^(Entity *enemy, NSUInteger idx, BOOL *stop) {
        [enemy updateEncounter:self];
    }];
    
    [self.raid.players enumerateObjectsUsingBlock:^(Entity *player, NSUInteger idx, BOOL *stop) {
        [player updateEncounter:self];
    }];
    
    if ( self.encounterUpdatedHandler )
        self.encounterUpdatedHandler(self);
}

- (void)endEncounter
{
    if ( _encounterTimer )
    {
        dispatch_source_cancel(_encounterTimer);
        //dispatch_release(_encounterTimer);
        _encounterTimer = NULL;
    }
    
    [self.enemies enumerateObjectsUsingBlock:^(Entity *enemy, NSUInteger idx, BOOL *stop) {
        [enemy endEncounter:self];
    }];
    [self.raid.players enumerateObjectsUsingBlock:^(Entity *player, NSUInteger idx, BOOL *stop) {
        [player endEncounter:self];
    }];
    
    if ( _encounterQueue )
        _encounterQueue = NULL;
    
    if ( self.encounterUpdatedHandler )
        self.encounterUpdatedHandler(self);
}

- (void)handleSpell:(Spell *)spell periodicTick:(BOOL)periodicTick isFirstTick:(BOOL)firstTick modifiers:(NSArray *)modifiers dyingEntitiesHandler:(DyingEntitiesBlock)dyingEntitiesHandler
{
    // while implementing cast bar, encounter isn't started
    if ( ! _encounterQueue )
        return;
    
    // this was moved outside the dispatch_async to fix automated LoH (first spell w/o triggering gcd)
    // from causing an infinite loop, since the code which would set the next cooldown wouldn't
    // run until after that code had returned
    if ( spell.cooldown.doubleValue && ( ! periodicTick || firstTick ) )
    {
        NSDate *thisNextCooldownDate = [NSDate dateWithTimeIntervalSinceNow:spell.cooldown.doubleValue];
        spell.nextCooldownDate = thisNextCooldownDate;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(spell.cooldown.doubleValue * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ( spell.nextCooldownDate == thisNextCooldownDate )
            {
                PHLog(spell,@"%@'s %@ has cooled down",spell.caster,spell);
                spell.nextCooldownDate = nil;
            }
            else
                PHLog(spell,@"Something else seems to have reset the cooldown on %@'s %@",spell.caster,spell);
        });
    }
    
    dispatch_async(_encounterQueue, ^{
    
        PHLog(spell,@"%@%@ %@ on %@!",spell.caster,periodicTick?@"'s channel is ticking":@" is casting",spell.name,spell.target);
        
        if ( spell.caster.isEnemy && self.enemyAbilityHandler )
            self.enemyAbilityHandler((Enemy *)spell.caster,(Ability *)spell);
        
#warning WARNING
        EventModifier *netMod = [EventModifier netModifierWithSpell:spell modifiers:modifiers];
        
        // apply standard crit chance
        if ( ! netMod.crit )
        {
            NSNumber *critChance = [ItemLevelAndStatsConverter critChanceWithEntity:spell.caster];
            NSUInteger critChance10000 = critChance.doubleValue * 10000.0;
            // .05 -> 10000.05
            NSUInteger critRoll = arc4random() % 10000;
            BOOL standardCrit = ( critRoll <= critChance10000 );
            if ( standardCrit )
            {
                PHLog(spell,@"%@ gained a standard crit",spell);
                netMod.crit = YES;
            }
        }
        
        [spell.caster handleSpell:spell modifier:netMod];
        [spell.target handleSpell:spell modifier:netMod];
        
        if ( spell.castSoundName )
            [SoundManager playSpellHit:spell];
        if ( spell.hitSoundName )
            [SoundManager playSpellHit:spell];
        
        NSMutableArray *allTargets = [NSMutableArray new];
        if ( spell.isSmart )
        {
            NSArray *smartTargets = [self _smartTargetsForSpell:spell source:spell.caster target:spell.target];
            if ( smartTargets )
                [allTargets addObjectsFromArray:smartTargets];
        }
        else if ( spell.affectsPartyOfTarget )
        {
            NSArray *partyTargets = [self.raid partyForEntity:spell.target includingEntity:YES];
            if ( partyTargets )
                [allTargets addObjectsFromArray:partyTargets];
        }
        else if ( spell.targeted )
            [allTargets addObject:spell.target];
        else
            [allTargets addObject:spell.caster];
        
        Entity *originalTarget = spell.target;
        [allTargets enumerateObjectsUsingBlock:^(Entity *aTarget, NSUInteger idx, BOOL *stop) {
            if ( ! aTarget.isDead || spell.canBeCastOnDeadEntities )
            {
                if ( spell.spellType == BeneficialOrDeterimentalSpell )
                {
                    if ( spell.target.isPlayer )
                        [self doHealing:spell source:spell.caster target:aTarget modifier:netMod periodic:periodicTick];
                    else
                        [self doDamage:spell source:spell.caster target:aTarget modifier:netMod periodic:periodicTick];
                }
                else if ( spell.spellType == DetrimentalSpell )
                    [self doDamage:spell source:spell.caster target:aTarget modifier:netMod periodic:periodicTick];
                else // ( spell.spellType == BeneficialSpell )
                    [self doHealing:spell source:spell.caster target:aTarget modifier:netMod periodic:periodicTick];
            }
            
            spell.target = aTarget;
            [spell handleHitWithModifier:netMod];
        }];
        spell.target = originalTarget;
        
        [netMod.blocks enumerateObjectsUsingBlock:^(EventModifierBlock block, NSUInteger idx, BOOL *stop) {
            block();
        }];
        
        if ( spell.grantsAuxResources )
            [spell.caster addAuxResources:spell.grantsAuxResources];
        
        if ( spell.target.currentHealth.integerValue <= 0 )
        {
            __block EventModifier *cheatDeathModifier = nil;
            [modifiers enumerateObjectsUsingBlock:^(EventModifier *obj, NSUInteger idx, BOOL *stop) {
                if ( obj.cheatDeathAndApplyHealing.doubleValue > 0 )
                {
                    cheatDeathModifier = obj;
                    *stop = YES;
                    return;
                }
            }];
            
            if ( cheatDeathModifier )
            {
                PHLog(spell,@"CHEATING DEATH and healing %@ for %@",spell.target,cheatDeathModifier.cheatDeathAndApplyHealing);
                
                NSInteger newHealth = spell.target.currentHealth.doubleValue + cheatDeathModifier.cheatDeathAndApplyHealing.doubleValue;
                if ( newHealth > spell.target.health.integerValue )
                    newHealth = spell.target.health.integerValue;
                
                spell.target.currentHealth = @(newHealth);
            }
            else
            {
                [self.raid.players enumerateObjectsUsingBlock:^(Entity *obj, NSUInteger idx, BOOL *stop) {
                    [obj handleDeathOfEntity:spell.target fromSpell:spell];
                }];
                [self.enemies enumerateObjectsUsingBlock:^(Entity *obj, NSUInteger idx, BOOL *stop) {
                    [obj handleDeathOfEntity:spell.target fromSpell:spell];
                }];
                
                if ( dyingEntitiesHandler )
                    dyingEntitiesHandler( @[ spell.target ] );
                
                // source has to choose a new target
                if ( spell.caster.isEnemy && ! [(Enemy *)spell.caster targetNextThreatWithEncounter:self] )
                {
                    PHLog(spell,@"the encounter is over because there are no targets for %@",spell.caster);
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
                        PHLog(spell,@"the encounter is over because all enemies are dead");
                        [self endEncounter];
                        return;
                    }
                }
            }
        }
        
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

- (void)doDamage:(Spell *)spell source:(Entity *)source target:(Entity *)target modifier:(EventModifier *)modifier periodic:(BOOL)periodic
{
    Event *damageEvent = [Event new];
    damageEvent.spell = spell;
    damageEvent.netDamage = periodic ? spell.periodicDamage : spell.damage;
    
    // deliberately applying all damage increases before decreases, TODO no idea if this is right
    PHLog(spell,@"considering %@ for damage of %@",modifier,spell);
    if ( modifier.damageIncrease )
    {
        damageEvent.netDamage = @( damageEvent.netDamage.unsignedIntegerValue + modifier.damageIncrease.unsignedIntegerValue );
        damageEvent.netAffected = @( damageEvent.netAffected.unsignedIntegerValue + modifier.damageIncrease.unsignedIntegerValue );
    }
    if ( modifier.damageIncreasePercentage )
    {
        NSNumber *previousNetDamage = damageEvent.netDamage;
        damageEvent.netDamage = @( damageEvent.netDamage.doubleValue * ( 1 + modifier.damageIncreasePercentage.doubleValue ) );
        damageEvent.netAffected = @( previousNetDamage.doubleValue - previousNetDamage.doubleValue );
    }
    if ( modifier.damageTakenDecreasePercentage ) // todo inconsistent, some probably stack while others don't
    {
        NSNumber *previousNetDamage = damageEvent.netDamage;
        damageEvent.netDamage = @( damageEvent.netDamage.doubleValue * ( 1 - modifier.damageTakenDecreasePercentage.doubleValue ) );
        damageEvent.netAffected = @( previousNetDamage.doubleValue - damageEvent.netDamage.doubleValue );
    }
    if ( modifier.damageTakenDecrease ) // todo, should this be applied before percentages?
    {
        NSNumber *previousNetDamage = damageEvent.netDamage;
        if ( modifier.damageTakenDecrease.doubleValue >= damageEvent.netDamage.doubleValue )
        {
            damageEvent.netDamage = @0;
            damageEvent.netAffected = @( modifier.damageTakenDecrease.doubleValue - previousNetDamage.doubleValue );
        }
        else
        {
            damageEvent.netDamage = @( damageEvent.netDamage.doubleValue - modifier.damageTakenDecrease.doubleValue );
            damageEvent.netAffected = @( previousNetDamage.doubleValue - damageEvent.netDamage.doubleValue );
        }
    }
    
    [target handleIncomingDamageEvent:damageEvent];
}

- (void)doHealing:(Spell *)spell source:(Entity *)source target:(Entity *)target modifier:(EventModifier *)modifier periodic:(BOOL)periodic
{
    NSNumber *healingValue = periodic ? spell.periodicHeal : spell.healing;
    
    if ( healingValue.doubleValue > 0 )
    {
        PHLog(spell,@"considering %@ for healing of %@",modifier,spell);
        if ( modifier.healingIncrease )
            healingValue = @( healingValue.unsignedIntegerValue + modifier.healingIncrease.unsignedIntegerValue );
        else if ( modifier.healingIncreasePercentage )
            healingValue = @( healingValue.doubleValue * ( 1 + modifier.healingIncreasePercentage.doubleValue ) );
        
        NSInteger newHealth = target.currentHealth.doubleValue + healingValue.doubleValue;
        if ( newHealth > target.health.integerValue )
            newHealth = target.health.integerValue;
        
        target.currentHealth = @(newHealth);
        
        PHLog(spell,@"%@ was healed for %@",target,healingValue);
    }
    
    // TODO how can modifiers buff absorbs as constituent effects?
//    NSNumber *absorbValue = periodic ? spell.periodicAbsorb : spell.absorb;
//    
//    if ( absorbValue.doubleValue > 0 )
//    {
//        PHLog(spell,@"considering %@ for absorb of %@",obj,spell);
//        if ( modifier.healingIncrease )
//            absorbValue = @( absorbValue.unsignedIntegerValue + modifier.healingIncrease.unsignedIntegerValue );
//        else if ( modifier.healingIncreasePercentage )
//            absorbValue = @( absorbValue.doubleValue * ( 1 + modifier.healingIncreasePercentage.doubleValue ) );
//        
////        NSInteger newAbsorb = target.currentAbsorb.doubleValue + absorbValue.doubleValue;
////        //if ( newAbsorb > someAbsorbCeilingLikePercentageOfHealersHealth ) TODO
////        //  newAbsorb = someAbsorbCeilingLikePercentageOfHealersHealth;
////        
////        target.currentAbsorb = @(newAbsorb);
//        
//        PHLog(spell,@"%@ received a %@ absorb",target,absorbValue);
//    }
}

@end
