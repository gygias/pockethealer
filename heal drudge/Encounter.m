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
    
    _encounterQueue = dispatch_queue_create("EncounterQueue", 0);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay + 2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.enemies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [(Entity *)obj beginEncounter:self];
        }];
        
        [self.raid.players enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [(Entity *)obj beginEncounter:self];
        }];
        
        // begin update timer
        _encounterTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _encounterQueue);
        dispatch_source_set_timer(_encounterTimer, DISPATCH_TIME_NOW, 0.033 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(_encounterTimer, ^{
            [self updateEncounter];
        });
        dispatch_resume(_encounterTimer);
    });
}

- (void)pause
{
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
    
    [self.advisor updateEncounter];
    
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
    
    //if ( _encounterQueue )
    //    _encounterQueue = NULL;
    
    if ( self.encounterUpdatedHandler )
        self.encounterUpdatedHandler(self);
}

- (void)handleSpell:(Spell *)spell periodicTick:(BOOL)periodicTick isFirstTick:(BOOL)firstTick dyingEntitiesHandler:(DyingEntitiesBlock)dyingEntitiesHandler
{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    if ( dispatch_get_current_queue() != self.encounterQueue )
        [NSException raise:@"HandleSpellNotOnEncounterQueue" format:@"We're on some other queue!"];
#pragma GCC diagnostic pop
    
    // is this ok for multitarget spells?
    NSMutableArray *modifiers = [NSMutableArray new];
    if ( [spell.caster handleSpellStart:spell modifiers:modifiers] )
    {
    }
    else if ( [spell.target handleSpellStart:spell modifiers:modifiers] )
    {
    }
    
    PHLog(spell,@"%@%@ %@ on %@!",spell.caster,periodicTick? (firstTick?@"'s channel is first-ticking":@"'s channel is ticking"):@" is casting",spell.name,spell.target);
    
    if ( spell.caster.isEnemy && self.enemyAbilityHandler )
        self.enemyAbilityHandler((Enemy *)spell.caster,(Ability *)spell);
    
    // TODO this flattens 'modifier blocks' to be executed once for all targets, even those \
    they didn't originate from below, which will probably be problematic for something
    EventModifier *netMod = [EventModifier netModifierWithSpell:spell modifiers:modifiers];
    //PHLog(spell, @"MODIFIERS %@ -> %@",modifiers,netMod);
    
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
    BOOL subHandled = YES;
    if ( ! spell.caster.isEnemy ) // XXX TODO big kludge _dispatchAbility has its own "determine targets" logic
    {
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
        else if ( spell.hitRange.doubleValue > 0 )
        {
            NSArray *subTargets = nil;
            
            if ( spell.hitRange.doubleValue >= 30 )
                subTargets = self.raid.players;
            else
            {
                Entity *originEntity = spell.hitRangeTargetable ? ( spell.caster.target ? spell.caster.target : spell.caster ) : spell.caster;
                if ( originEntity.hdClass.isRanged )
                    subTargets = self.raid.rangePlayers;
                else
                    subTargets = self.raid.meleePlayers;
                double percentCovered = spell.hitRange.doubleValue / 10.0;
                if ( percentCovered > 1 )
                    percentCovered = 1;
                NSUInteger nRemovedByRange = (NSUInteger)( ( 1 - percentCovered ) * subTargets.count );
                subTargets = [subTargets arrayByRandomlyRemovingNObjects:nRemovedByRange];
                if ( spell.maxHitTargets.integerValue && subTargets.count > spell.maxHitTargets.integerValue )
                    subTargets = [subTargets arrayByRandomlyRemovingNObjects:( subTargets.count - spell.maxHitTargets.integerValue )];
            }
            if ( subTargets.count )
                [allTargets addObjectsFromArray:subTargets];
        }
        else
            subHandled = NO;
    }
    if ( spell.caster.isEnemy && !subHandled ) // Kludge fucking gross
        [allTargets addObject:spell.target];
    else if ( !subHandled )
        [allTargets addObject:spell.caster];
    
    Entity *originalTarget = spell.target;
    [allTargets enumerateObjectsUsingBlock:^(Entity *aTarget, NSUInteger idx, BOOL *stop) {
        BOOL cheatedDeath = NO;
        if ( ! aTarget.isDead || spell.canBeCastOnDeadEntities )
        {
            if ( spell.spellType == BeneficialOrDeterimentalSpell )
            {
                if ( spell.target.isPlayer )
                    [self doHealing:spell source:spell.caster target:aTarget modifier:netMod periodic:periodicTick];
                else
                    cheatedDeath = [self doDamage:spell source:spell.caster target:aTarget modifier:netMod periodic:periodicTick];
            }
            else if ( spell.spellType == DetrimentalSpell )
                cheatedDeath = [self doDamage:spell source:spell.caster target:aTarget modifier:netMod periodic:periodicTick];
            else // ( spell.spellType == BeneficialSpell )
                [self doHealing:spell source:spell.caster target:aTarget modifier:netMod periodic:periodicTick];
        }
        
        spell.target = aTarget;
        
        if ( periodicTick )
            [spell handleTickWithModifier:netMod firstTick:firstTick];
        else
            [spell handleHitWithModifier:netMod];
        
        [netMod.blocks enumerateObjectsUsingBlock:^(EventModifierBlock block, NSUInteger idx, BOOL *stop) {
            block(spell,cheatedDeath);
        }];
        
        [self.advisor handleSpell:spell event:nil modifier:netMod];
    }];
    spell.target = originalTarget;
    
    if ( spell.grantsAuxResources )
        [spell.caster addAuxResources:spell.grantsAuxResources];
    
    if ( spell.target.currentHealth.integerValue <= 0 )
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
    
    if ( self.encounterUpdatedHandler )
        self.encounterUpdatedHandler(self);
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

- (BOOL)doDamage:(Spell *)spell source:(Entity *)source target:(Entity *)target modifier:(EventModifier *)modifier periodic:(BOOL)periodic
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
    
    [target handleIncomingDamageEvent:damageEvent modifier:modifier];
    
    __block BOOL didCheatDeath = NO;
    if ( target.currentHealth.integerValue <= 0 )
    {
        if ( modifier.cheatDeathAndApplyHealing )
        {
            PHLog(spell,@"CHEATING DEATH and healing %@ for %@",spell.target,modifier.cheatDeathAndApplyHealing);
            
            NSInteger newHealth = spell.target.currentHealth.doubleValue + modifier.cheatDeathAndApplyHealing.doubleValue;
            if ( newHealth > spell.target.health.integerValue )
                newHealth = spell.target.health.integerValue;
            
            target.currentHealth = @(newHealth);
            didCheatDeath = YES;
        }
    }
    
    return didCheatDeath;
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

- (Entity *)currentMainTank
{
    // TODO
    __block Entity *targetedEntity = nil;
    [self.enemies enumerateObjectsUsingBlock:^(Enemy *enemy, NSUInteger idx, BOOL *stop) {
        if ( enemy.target.hdClass.isTank )
        {
            targetedEntity = enemy.target;
            *stop = YES;
        }
    }];
    
    if ( ! targetedEntity )
        targetedEntity = [self.raid.tankPlayers randomObject];
    
    return targetedEntity;
}

@end
