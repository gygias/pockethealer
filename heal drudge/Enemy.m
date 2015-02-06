//
//  Enemy.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "Enemy.h"
#import "Ability.h"
#import "Encounter.h"

@implementation Enemy

+ (Enemy *)randomEnemyWithRaid:(Raid *)raid
{
    Class kargathClass = NSClassFromString(@"KargathBladefist"); // how to factory these?
    return [[kargathClass alloc] initWithRaid:raid];
}

- (id)initWithRaid:(Raid *)raid
{
    if ( self = [super init] )
    {
        self.stamina = @1;
        self.currentHealth = self.health;
        self.currentResources = @100;
        self.hdClass = [HDClass enemyClass];
        self.isEnemy = YES;
        [self _initializeAbilities];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ [%@,%@]",NSStringFromClass([self class]),self.currentHealth,self.currentResources];
}

- (NSArray *)abilities
{
    return _abilities;
}

- (NSArray *)abilityNames
{
    return nil;
}

- (NSString *)name
{
    return NSStringFromClass([self class]);
}

- (void)beginEncounter:(Encounter *)encounter
{
    [super beginEncounter:encounter];
    
    if ( self.aggroSoundName )
        [SoundManager playAggroSound:self];
    
    [_abilities enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Ability *ability = (Ability *)obj;
        //PHLog(self,@"%@: %@",ability,ability.nextFireDate);
        ability.nextFireDate = [NSDate dateWithTimeIntervalSinceNow:ability.cooldown.doubleValue];
        PHLog(self,@"set next fire date for %@: %@ based on %f",ability,ability.nextFireDate,ability.cooldown.doubleValue);
        if ( self.scheduledSpellHandler && ability.abilityLevel > NormalAbility )
            self.scheduledSpellHandler(ability,ability.nextFireDate);
    }];
    
    // choose a tank target
    [self targetNextThreatWithEncounter:encounter];
}

- (void)_initializeAbilities
{
    _abilities = [NSMutableArray new];
    for ( NSString *abilityName in [self abilityNames] )
    {
        Class abilityClass = NSClassFromString(abilityName);
        Ability *ability = [[abilityClass alloc] initWithCaster:self];
        //PHLog(self,@"initialized ability %@ with fire date %@",ability,ability.nextFireDate);
        if ( ability )
            [(NSMutableArray *)_abilities addObject:ability];
        else
            PHLogV(@"Ability %@ didn't initialize",abilityName);
    }
}

- (void)updateEncounter:(Encounter *)encounter
{
    // canned automatic thing happening
    for ( Ability *ability in [self abilities] )
    {
        //PHLog(self,@"%@ since %@ == %f",[NSDate date],ability.nextFireDate,[[NSDate date] timeIntervalSinceDate:ability.nextFireDate]);
        if ( [[NSDate date] timeIntervalSinceDate:ability.nextFireDate] >= 0 )
        {
            NSArray *targets = [self _determineTargetsForAbility:ability raid:encounter.raid];
            [targets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Entity *target = (Entity *)obj;
                [self _dispatchAbility:ability toEncounter:encounter withTarget:target];
            }];
            
            ability.nextFireDate = [NSDate distantFuture]; // XXX
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ability.periodicDuration * NSEC_PER_SEC)), self.encounter.encounterQueue, ^{
                ability.nextFireDate = [NSDate dateWithTimeIntervalSinceNow:ability.cooldown.doubleValue];
                if ( self.scheduledSpellHandler && ability.abilityLevel > NormalAbility )
                    self.scheduledSpellHandler(ability,ability.nextFireDate);
            });
        }
    }
}

- (BOOL)targetNextThreatWithEncounter:(Encounter *)encounter
{
    Entity *newTarget = [self _randomLivingPlayerInRaid:encounter.raid fromRolePreferenceList:@[ TankRole, HealerRole, DPSRole]];
    if ( ! self.target.isDead || self.target == newTarget )
        PHLogV(@"wtf");
    PHLog(self,@"%@ is changing targets from %@ to %@",self,self.target,newTarget);
    self.target = newTarget; // should encounter be doing this?
    return ( newTarget );
}

- (void)_dispatchAbility:(Ability *)ability toEncounter:(Encounter *)encounter withTarget:(Entity *)target
{
    [SoundManager playSoundForAbilityLevel:ability.abilityLevel];
    
    self.castingSpell = ability;
    self.castingSpell.target = target;
    NSDate *thisCastStartDate = [NSDate date];
    self.castingSpell.lastCastStartDate = thisCastStartDate;
        
    if ( ability.isPeriodic )
    {
        __block BOOL isFirstTick = YES;
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.periodicEffectQueue);
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, ability.period * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(timer, ^{
            if ( self.isDead || self.stopped )
            {
                PHLog(self,@"stopping periodic %@ because %@ is %@",ability,self,self.isDead?@"dead":@"stopped");
                dispatch_source_cancel(timer);
                return;
            }
            
            NSArray *tickTargets = nil;
            if ( ability.periodicEffectChangesTargets )
                tickTargets = [self _determineTargetsForAbility:ability raid:encounter.raid];
            else
                tickTargets = @[target];
            [tickTargets enumerateObjectsUsingBlock:^(Entity *tickTarget, NSUInteger idx, BOOL *stop) {
                PHLog(ability,@"%@ is ticking on %@ (%@)",ability.name,tickTarget,@( tickTarget.currentHealth.doubleValue - ability.periodicDamage.doubleValue ));
                ability.target = tickTarget;
                [encounter handleSpell:ability periodicTick:YES isFirstTick:isFirstTick dyingEntitiesHandler:^(NSArray *dyingEntities) {
                    if ( [dyingEntities containsObject:self] || [dyingEntities containsObject:target] )
                    {
                        PHLog(ability,@"%@ or %@ have died during %@, so it is unscheduling",self,target,ability);
                        dispatch_source_cancel(timer);
                        return;
                    }
                }];
            }];
            
            isFirstTick = NO;
        });
        dispatch_resume(timer);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ability.periodicDuration * NSEC_PER_SEC)), self.periodicEffectQueue, ^{
            PHLog(self,@"%@ has ended",ability);
            dispatch_source_cancel(timer);
            
            ability.nextFireDate = [NSDate dateWithTimeIntervalSinceNow:ability.cooldown.doubleValue];
        });
    }
    else if ( ability.castTime.doubleValue > 0 )
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ability.castTime.doubleValue * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [encounter handleSpell:ability periodicTick:NO isFirstTick:NO dyingEntitiesHandler:NULL];
        });
    }
    else
        [encounter handleSpell:ability periodicTick:NO isFirstTick:NO dyingEntitiesHandler:NULL];
}

// this needs some work to handle multiple targets
- (NSArray *)_determineTargetsForAbility:(Ability *)ability raid:(Raid *)raid
{
    NSMutableArray *targets = [NSMutableArray new];
    
    if ( ability.affectsRandomMelee || ability.affectsRandomRange )
    {
        NSArray *orderedPlayers = nil;
        if ( ability.affectsRandomRange )
            orderedPlayers = @[ raid.rangePlayers ? raid.rangePlayers : @[], raid.meleePlayers ? raid.meleePlayers : @[] ];
        else
            orderedPlayers = @[ raid.meleePlayers ? raid.meleePlayers : @[], raid.rangePlayers ? raid.rangePlayers : @[] ];
        
        NSMutableArray *combinedPlayers = [NSMutableArray new];
        for ( NSArray *anOrderedPlayers in orderedPlayers )
        {
            [combinedPlayers addObjectsFromArray:anOrderedPlayers];
        }
        
        Entity *aRandomTarget = [self _randomLivingPlayerFrom:combinedPlayers];
        if ( aRandomTarget )
            [targets addObject:aRandomTarget];
    }
    else // default to main target
    {
        if ( self.target )
            [targets addObject:self.target];
        else
            PHLogV(@"%@ targets main target, but %@ has none!",ability,self);
    }
    
    if ( ability.hitRange )
    {
        // TODO
    }
    
    if ( [targets count] == 0 )
        return nil;
    return targets;
}

- (Entity *)_randomLivingPlayerInRaid:(Raid *)raid fromRolePreferenceList:(NSArray *)rolePreferenceList
{
    NSMutableArray *orderedPlayers = [NSMutableArray new];
    for ( NSString *role in rolePreferenceList )
    {
        if ( [role isEqualToString:(NSString *)TankRole] )
        {
            if ( raid.tankPlayers )
                [orderedPlayers addObject:raid.tankPlayers];
        }
        else if ( [role isEqualToString:(NSString *)DPSRole] )
        {
            if ( raid.dpsPlayers )
                [orderedPlayers addObject:raid.dpsPlayers];
        }
        else if ( [role isEqualToString:(NSString *)HealerRole] )
        {
            if ( raid.healers )
                [orderedPlayers addObject:raid.healers];
        }
    }
    
    Entity *randomLivingPlayer = nil;
    for ( NSArray *anOrderedPlayers in orderedPlayers )
    {
        randomLivingPlayer = [self _randomLivingPlayerFrom:anOrderedPlayers];
        if ( randomLivingPlayer )
            break;
    }
    
    return randomLivingPlayer;
}

- (Entity *)_randomLivingPlayerFrom:(NSArray *)players
{
    __block Entity *randomLivingPlayer = nil;
    
    // TODO this is racey
    NSMutableArray *livingPlayers = [NSMutableArray new];
    [players enumerateObjectsUsingBlock:^(Entity *obj, NSUInteger idx, BOOL *stop) {
        //PHLog(self,@"%@ is %@",obj,obj.isDead?@"dead":@"alive");
        if ( ! obj.isDead )
            [livingPlayers addObject:obj];
    }];
    
    if ( [livingPlayers count] == 0 )
        return randomLivingPlayer;
    
    return [livingPlayers objectAtIndex:arc4random() % [livingPlayers count]];
}

@end
