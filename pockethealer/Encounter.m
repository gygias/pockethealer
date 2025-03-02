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

- (id)init
{
    if ( self = [super init] )
    {
        self.cachedTankLocations = [NSMutableArray new];
        self.cachedRangeLocations = [NSMutableArray new];
        self.cachedMeleeLocations = [NSMutableArray new];
        self.combatLog = [CombatLog new];
    }
    
    return self;
}

- (void)start
{
    _encounterQueue = dispatch_queue_create("EncounterQueue", 0);
    
    [self.enemies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(Entity *)obj prepareForEncounter:self];
    }];
    
    [self.raid.players enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(Entity *)obj prepareForEncounter:self];
    }];
    
    if ( self.encounterUpdatedHandler )
        self.encounterUpdatedHandler(self);
    
    [self _registerEntityUpdates];
    
    NSInteger delay = 1;
    [SoundManager playCountdownWithStartIndex:@(delay)];    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay + 2 * NSEC_PER_SEC)), self.encounterQueue, ^{
        
        [self.enemies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [(Entity *)obj beginEncounter:self];
        }];
        
        [self.raid.players enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [(Entity *)obj beginEncounter:self];
        }];
        
        // begin update timer
//        _encounterTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _encounterQueue);
//        dispatch_source_set_timer(_encounterTimer, DISPATCH_TIME_NOW, REAL_TIME_DRAWING_INTERVAL * NSEC_PER_SEC, REAL_TIME_DRAWING_LEEWAY * NSEC_PER_SEC);
//        dispatch_source_set_event_handler(_encounterTimer, ^{
//            //[self updateEncounter];
//        });
//        dispatch_resume(_encounterTimer);
    });
}

- (void)pause
{
    [NSDate pause];
    if ( _encounterTimer )
        dispatch_suspend(_encounterTimer);
    if ( _encounterQueue )
        dispatch_suspend(_encounterQueue);
}

- (BOOL)isPaused
{
    return [NSDate isPaused];
}

- (void)unpause
{
    [NSDate unpause];
    if ( _encounterTimer )
        dispatch_resume(_encounterTimer);
    if ( _encounterQueue )
        dispatch_resume(_encounterQueue);
}

- (void)end
{
    [self endEncounter];
}

- (void)updateEncounter
{
    [[self _allEntities] enumerateObjectsUsingBlock:^(Entity *playerOrEnemy, NSUInteger idx, BOOL *stop) {
        [playerOrEnemy updateEncounter:self];
    }];
    
#warning now that updates are event based, this should be timer based
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
    
    [self _deregisterEntityUpdates];
}

- (NSArray *)_allEntities
{
    NSMutableArray *allEntities = [NSMutableArray new];
    if ( self.raid.players.count )
        [allEntities addObjectsFromArray:self.raid.players];
    if ( self.enemies.count )
        [allEntities addObjectsFromArray:self.enemies];
    return allEntities;
}

- (void)_registerEntityUpdates
{
    [[self _allEntities] enumerateObjectsUsingBlock:^(Entity *playerOrEnemy, NSUInteger idx, BOOL *stop) {
        playerOrEnemy.entityMovedHandler = ^(Entity *entity){
            //NSLog(@"entity moved: %@",entity);
            if ( self.encounterUpdatedEntityPositionsHandler )
                self.encounterUpdatedEntityPositionsHandler(self,entity);
        };
        playerOrEnemy.entityUpdatedHandler = ^(Entity *entity){
            if ( self.encounterUpdatedHandler )
                self.encounterUpdatedHandler(self);
        };
    }];
}

- (void)_deregisterEntityUpdates
{
    [[self _allEntities] enumerateObjectsUsingBlock:^(Entity *playerOrEnemy, NSUInteger idx, BOOL *stop) {
        playerOrEnemy.entityMovedHandler = NULL;
        playerOrEnemy.entityUpdatedHandler = NULL;
    }];
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
    
    if ( ! periodicTick || firstTick )
    {
        if ( spell.castSoundName )
            [SoundManager playSpellHit:spell];
        if ( spell.hitSoundName )
            [SoundManager playSpellHit:spell];
    }
    
    NSMutableArray *allTargets = [NSMutableArray new];

    __block Entity *aoeOriginEntity = nil;
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
        aoeOriginEntity = spell.targeted ? ( spell.target ? spell.target : spell.caster ) : spell.caster;
        BOOL hitPlayers = spell.caster.isEnemy ? ( spell.spellType != BeneficialEffect ) : ( spell.spellType != DetrimentalEffect );
        BOOL hitEnemies = spell.caster.isEnemy ? ( spell.spellType != DetrimentalEffect ) : ( spell.spellType != BeneficialEffect );
        NSArray *subTargets = [aoeOriginEntity entitiesInRange:spell.hitRange.doubleValue players:hitPlayers enemies:hitEnemies includingSelf:hitPlayers];
        if ( subTargets.count )
            [allTargets addObjectsFromArray:subTargets];
        if ( spell.maxHitTargets.integerValue && subTargets.count > spell.maxHitTargets.integerValue )
            subTargets = [subTargets arrayByRandomlyRemovingNObjects:( subTargets.count - spell.maxHitTargets.integerValue )];
        PHLog(spell.caster,@"targets of aoe spell %@: %@",spell,subTargets);
    }
    else if ( spell.targeted )
        [allTargets addObject:spell.target];
    else
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
        
        if ( aTarget != aoeOriginEntity && aTarget != originalTarget )
        {
            aTarget.lastMultitargetHitSpell = spell;
            aTarget.lastMultitargetHitDate = [NSDate date];
        }
    }];
    spell.target = originalTarget;
    
    Entity *assignHitEntity = ( aoeOriginEntity ? aoeOriginEntity : spell.target );
    assignHitEntity.lastHitSpell = spell;
    assignHitEntity.lastHitDate = [NSDate date];
    
    
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
    
    //if ( self.encounterUpdatedHandler )
    //    self.encounterUpdatedHandler(self);
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
        NSNumber *overheal = nil;
        if ( newHealth > target.health.integerValue )
        {
            overheal = @(newHealth - target.health.integerValue);
            newHealth = target.health.integerValue;
        }
        
        target.currentHealth = @(newHealth);
        
        if ( source.isPlayingPlayer )
        {
            target.lastHealAmount = healingValue;
            target.lastHealDate = [NSDate date];
        }
        
        [self.combatLog addSpellEvent:spell target:target effectiveDamage:nil effectiveHealing:healingValue effectiveOverheal:overheal];
        
        PHLog(spell,@"%@ was healed for %@",target,healingValue);
    }
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

- (void)handleCommand:(PlayerCommand)command
{
    switch (command) {
        case HeroCommand:
            [self _handleHeroCommand];
            break;
        case StackOnMeCommand:
            [self _handleStackOnMeCommand];
            break;
        case StackInMeleeCommand:
            [self _handleStackInMeleeCommand];
            break;
        case IdiotsCommand:
            [self _handleIdiotsCommand];
            break;
        case SpreadCommand:
            [self _handleSpreadCommand];
            break;
        default:
            break;
    }
}

- (void)_handleHeroCommand
{
    Entity *heroableEntity = self.raid.randomHeroCapablePlayer;
    
    if ( ! heroableEntity )
    {
        NSLog(@"can't hero");
        return;
    }
    
    NSLog(@"TODO: %@: implement hero!",heroableEntity);
}

- (void)_handleStackOnMeCommand
{
    [self.raid.rangePlayers enumerateObjectsUsingBlock:^(Entity *rangePlayer, NSUInteger idx, BOOL *stop) {
        [rangePlayer stopCurrentMove];
        [rangePlayer moveToEntity:self.player];
    }];
}

- (void)_handleStackInMeleeCommand
{
    Entity *someTank = self.raid.tankPlayers.randomObject;
    NSLog(@"stacking on %@",someTank);
    [self.raid.nonTankPlayers enumerateObjectsUsingBlock:^(Entity *nonTankPlayer, NSUInteger idx, BOOL *stop) {
        [nonTankPlayer stopCurrentMove];
        [nonTankPlayer moveToEntity:someTank];
    }];
}

- (void)_handleIdiotsCommand
{
    NSLog(@"IDIOTS!");
}

- (void)_handleSpreadCommand
{
    [self.raid.nonTankPlayers enumerateObjectsUsingBlock:^(Entity *nonTankPlayer, NSUInteger idx, BOOL *stop) {
        [nonTankPlayer stopCurrentMove];
        [nonTankPlayer moveToRandomLocation:YES commanded:YES];
    }];
}

- (void)beginOrContinueUpdatesUntil:(NSDate *)endDate
{
    NSTimeInterval untilEnd = -[[NSDate date] timeIntervalSinceDate:endDate];
    if ( untilEnd <= 0 )
    {
        NSLog(@"something calling -beginOrContinueUpdatesUntil: is confused");
        return;
    }
    
    NSComparisonResult lastComparedToThis = NSOrderedSame;
    // if we are running updates and the parameter end date is before our current update end date
    if ( self.lastUpdateEndDate && ( lastComparedToThis = [self.lastUpdateEndDate compare:endDate] ) != NSOrderedAscending )
        return;
    
    BOOL beginTimer = ( self.lastUpdateEndDate == nil );
    self.lastUpdateEndDate = endDate;
    
    if ( beginTimer )
    {
        NSLog(@"starting updates");
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.encounterQueue);
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, REAL_TIME_DRAWING_INTERVAL * NSEC_PER_SEC, REAL_TIME_DRAWING_LEEWAY * NSEC_PER_SEC);
        dispatch_source_set_event_handler(timer, ^{
            if ( ! self.lastUpdateEndDate || [[NSDate date] timeIntervalSinceDate:self.lastUpdateEndDate] >= 0 )
            {
                NSLog(@"stopping updates");
                dispatch_source_cancel(timer);
                self.lastUpdateEndDate = nil;
                return;
            }
            [self updateEncounter];
        });
        dispatch_resume(timer);
    }
}

@end
