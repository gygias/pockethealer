//
//  Enemy.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Enemy.h"
#import "Ability.h"
#import "Encounter.h"
#import "NSCollections+Random.h"

#import "SoundManager.h" // might want to have a 'ui event manager' that would wrap this and the inevitable thing that puts stuff on the screen

@implementation Enemy

+ (Enemy *)randomEnemy
{
    Class kargathClass = NSClassFromString(@"KargathBladefist"); // how to factory these?
    return [kargathClass new];
}

- (id)init
{
    if ( self = [super init] )
    {
        [self _initializeAbilities];
        self.health = @1;
        self.currentHealth = self.health;
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
    [_abilities enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Ability *ability = (Ability *)obj;
        //NSLog(@"%@: %@",ability,ability.nextFireDate);
        ability.nextFireDate = [NSDate dateWithTimeIntervalSinceNow:ability.cooldown.doubleValue];
        NSLog(@"set next fire date for %@: %@ based on %f",ability,ability.nextFireDate,ability.cooldown.doubleValue);
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
        Ability *ability = [abilityClass new];
        //NSLog(@"initialized ability %@ with fire date %@",ability,ability.nextFireDate);
        if ( ability )
            [(NSMutableArray *)_abilities addObject:ability];
        else
            NSLog(@"Ability %@ didn't initialize",abilityName);
    }
}

- (void)updateEncounter:(Encounter *)encounter
{
    // canned automatic thing happening
    for ( Ability *ability in [self abilities] )
    {
        //NSLog(@"%@ since %@ == %f",[NSDate date],ability.nextFireDate,[[NSDate date] timeIntervalSinceDate:ability.nextFireDate]);
        if ( [[NSDate date] timeIntervalSinceDate:ability.nextFireDate] >= 0 )
        {
            NSArray *targets = [self _determineTargetsForAbility:ability raid:encounter.raid];
            [targets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Entity *target = (Entity *)obj;
                [self _dispatchAbility:ability toEncounter:encounter withTarget:target];
            }];
            
            if ( ! ability.isPeriodic )
                ability.nextFireDate = [NSDate dateWithTimeIntervalSinceNow:ability.cooldown.doubleValue];
            else
                ability.nextFireDate = [NSDate distantFuture];
        }
    }
}

- (BOOL)targetNextThreatWithEncounter:(Encounter *)encounter
{
    Entity *newTarget = [self _randomLivingPlayerInRaid:encounter.raid fromRolePreferenceList:@[ TankRole, HealerRole, DPSRole]];
    if ( ! self.target.isDead || self.target == newTarget )
        NSLog(@"wtf");
    NSLog(@"%@ is changing targets from %@ to %@",self,self.target,newTarget);
    self.target = newTarget; // should encounter be doing this?
    return ( newTarget );
}

- (void)_dispatchAbility:(Ability *)ability toEncounter:(Encounter *)encounter withTarget:(Entity *)target
{
    [SoundManager playSoundForAbilityLevel:ability.abilityLevel];
    
    if ( ability.isPeriodic )
    {
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.periodicEffectQueue);
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, ability.period * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(timer, ^{
            if ( self.isDead || self.stopped )
            {
                NSLog(@"stopping periodic %@ because %@ is %@",ability,self,self.isDead?@"dead":@"stopped");
                dispatch_source_cancel(timer);
                return;
            }
            
            NSArray *tickTargets = nil;
            if ( ability.periodicEffectChangesTargets )
                tickTargets = [self _determineTargetsForAbility:ability raid:encounter.raid];
            else
                tickTargets = @[target];
            [tickTargets enumerateObjectsUsingBlock:^(Entity *tickTarget, NSUInteger idx, BOOL *stop) {
                NSLog(@"%@ is ticking on %@ (%@)",ability.name,tickTarget,@( tickTarget.currentHealth.doubleValue - ability.periodicDamage.doubleValue ));
                [encounter handleAbility:ability source:self target:tickTarget periodicTick:YES];
            }];
        });
        dispatch_resume(timer);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ability.periodicDuration * NSEC_PER_SEC)), self.periodicEffectQueue, ^{
            NSLog(@"%@ has ended",ability);
            dispatch_source_cancel(timer);
            
            ability.nextFireDate = [NSDate dateWithTimeIntervalSinceNow:ability.cooldown.doubleValue];
        });
    }
    else
        [encounter handleAbility:ability source:self target:target periodicTick:NO];
}

// this needs some work to handle multiple targets
- (NSArray *)_determineTargetsForAbility:(Ability *)ability raid:(Raid *)raid
{
    NSMutableArray *targets = [NSMutableArray new];
    
    if ( ability.affectsRandomMelee || ability.affectsRandomRange )
    {
        NSArray *orderedPlayers = nil;
        if ( ability.affectsRandomRange )
            orderedPlayers = @[ raid.rangePlayers, raid.meleePlayers ];
        else
            orderedPlayers = @[ raid.meleePlayers, raid.rangePlayers ];
        
        for ( NSArray *anOrderedPlayers in orderedPlayers )
        {
            Entity *aRandomTarget = [self _randomLivingPlayerFrom:anOrderedPlayers];
            if ( aRandomTarget )
            {
                [targets addObject:aRandomTarget];
                break;
            }
        }
    }
    else // default to main target
    {
        if ( self.target )
            [targets addObject:self.target];
        else
            NSLog(@"%@ targets main target, but %@ has none!",ability,self);
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
    [players enumerateObjectsUsingBlock:^(Entity *obj, NSUInteger idx, BOOL *stop) {
        //NSLog(@"%@ is %@",obj,obj.isDead?@"dead":@"alive");
        if ( ! obj.isDead )
        {
            randomLivingPlayer = obj;
            *stop = YES;
        }
    }];
    
    return randomLivingPlayer;
}

@end
