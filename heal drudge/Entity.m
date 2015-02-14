//
//  Entity.m
//  heal drudge
//
//  Created by david on 1/22/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "Entity.h"
#import "Entity+AI.h"

#import "Encounter.h"
#import "Effect.h"
#import "Spell.h"
#import "Event.h"
#import "ItemLevelAndStatsConverter.h"

#import "GenericDamageSpell.h"
#import "GenericHealingSpell.h"
#import "GenericPhysicalAttackSpell.h"

// AI
#import "Entity+ProtPaladin.h"

@implementation Entity

@synthesize currentHealth = _currentHealth,
            currentResources = _currentResources,
            statusEffects = _statusEffects,
            periodicEffectQueue = _periodicEffectQueue,
            hdClass = _hdClass;

- (void)setHdClass:(HDClass *)hdClass
{
    _hdClass = hdClass;
}

- (void)initializeSpells
{
    self.spells = [Spell castableSpellsForCharacter:self];
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

- (BOOL)validateSpell:(Spell *)spell asSource:(BOOL)asSource otherEntity:(Entity *)otherEntity message:(NSString * __strong *)messagePtr invalidDueToCooldown:(BOOL *)invalidDueToCooldown
{
    Entity *source = asSource ? self : otherEntity;
    Entity *target = asSource ? otherEntity : self;
    
    if ( source.currentResources.integerValue < spell.manaCost.integerValue )
    {
        if ( messagePtr )
            *messagePtr = @"Not enough mana";
        return NO;
    }
    if ( source.isDead )
    {
        if ( messagePtr )
            *messagePtr = @"You are dead";
        return NO;
    }
    if ( target.isDead && ! spell.canBeCastOnDeadEntities )
    {
        if ( messagePtr )
            *messagePtr = @"Target is dead";
        return NO;
    }
    if ( spell.targeted )
    {
        if ( ( spell.spellType == DetrimentalSpell ) && target.isPlayer )
        {
            if ( messagePtr )
                *messagePtr = @"Invalid target";
            return NO;
        }
//        if ( ( spell.spellType == BeneficialSpell ) && target.isEnemy )
//        {
//            if ( messagePtr )
//                *messagePtr = @"Invalid target";
//            return NO;
//        }
    }
    if ( asSource && ( spell.auxiliaryResourceCost.doubleValue > self.currentAuxiliaryResources.doubleValue ) )
    {
        if ( messagePtr )
            *messagePtr = @"Not enough resources";
        return NO;
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
        if ( asSource && ( spell.isOnCooldown || self.isOnGlobalCooldown ) )
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

- (BOOL)handleSpellStart:(Spell *)spell modifiers:(NSMutableArray *)modifiers
{
    __block BOOL addedModifiers = NO;
    
    if ( [spell addModifiers:modifiers] )
        addedModifiers = YES;
    
    [self.statusEffects enumerateObjectsUsingBlock:^(Effect *obj, NSUInteger idx, BOOL *stop) {
        if ( [obj addModifiersWithSpell:spell modifiers:modifiers] )
            addedModifiers = YES;
    }];
    
    return addedModifiers;
}

- (void)handleSpell:(Spell *)spell modifier:(EventModifier *)modifier
{    
    [self.statusEffects enumerateObjectsUsingBlock:^(Effect *obj, NSUInteger idx, BOOL *stop) {
        [obj handleSpell:spell modifier:modifier];
    }];
    
    if ( spell.caster == self )
    {
        NSInteger effectiveCost = spell.manaCost.integerValue;
        if ( spell.isChanneled )
            effectiveCost = effectiveCost / spell.channelTicks.integerValue;
        self.currentResources = @(spell.caster.currentResources.integerValue - effectiveCost);
        
        // TODO this isn't really general, conceivably something could have a "stacked" emphasis effect, but i can't think of one
        spell.isEmphasized = NO;
        spell.emphasisStopDate = nil;
    }
}

- (void)handleIncomingDamageEvent:(Event *)damageEvent
{
    [self handleIncomingDamageEvent:damageEvent avoidable:YES];
}

- (void)handleIncomingDamageEvent:(Event *)damageEvent avoidable:(BOOL)avoidable
{
    if ( self.hitSoundName )
        [SoundManager playHitSound:self];
    
    BOOL dodged = NO;
    BOOL blocked = NO;
    BOOL parried = NO;
    
    if ( avoidable )
    {
        // apply avoidance
        NSUInteger dodgeRoll = arc4random() % 100;
        if ( dodgeRoll <= self.dodgeChance.doubleValue * 100 )
            dodged = YES;
        else
        {
            NSUInteger blockRoll = arc4random() % 100;
            if ( blockRoll <= self.blockChance.doubleValue * 100 )
                blocked = YES;
            else
            {
                // savin    23.08% (765 adds 4.72%)
                // sly      20.64% (634 adds 3.91%)
                // analog   20.35% (986 adds 6.09%)
                NSUInteger parryRoll = arc4random() % 100;
                double parryChance = .2; // TODO armory numbers inconsistent
                if ( parryRoll <= parryChance * 100 )
                    parried = YES;
            }
        }
        
        if ( dodged )
        {
            damageEvent.netDodged = damageEvent.netDamage;
            damageEvent.netDamage = @0;
        }
        else if ( blocked )
        {
            NSNumber *amountBlocked = @( damageEvent.netDamage.doubleValue * 0.3 );
            damageEvent.netDamage = @( damageEvent.netDamage.doubleValue - amountBlocked.doubleValue ); // TODO
            damageEvent.netBlocked = @( damageEvent.netBlocked.doubleValue + amountBlocked.doubleValue );
        }
        else if ( parried )
        {
            damageEvent.netParried = damageEvent.netDamage;
            damageEvent.netDamage = @0; // TODO
        }
    }
    
    if ( damageEvent.netDamage.doubleValue > 0 )
    {
        NSMutableIndexSet *consumedEffects = [NSMutableIndexSet new];
        [self.statusEffects enumerateObjectsUsingBlock:^(Effect *effect, NSUInteger idx, BOOL *stop) {
            
            if ( [damageEvent.netDamage compare:@0] == NSOrderedSame )
            {
                *stop = YES;
                return;
            }
            
            if ( effect.absorb )
            {
                if ( damageEvent.netDamage.doubleValue >= effect.absorb.doubleValue )
                {
                    PHLog(self,@"%@ damage will consumed %@'s %@",damageEvent.netDamage,self,effect);
                    [consumedEffects addIndex:idx];
                    damageEvent.netAbsorbed = @( damageEvent.netAbsorbed.doubleValue + effect.absorb.doubleValue );
                    damageEvent.netDamage = @( damageEvent.netDamage.doubleValue - effect.absorb.doubleValue );
                }
                else
                {
                    NSNumber *thisAbsorbRemaining = @( effect.absorb.doubleValue - damageEvent.netDamage.doubleValue );
                    PHLog(self,@"%@'s %@ has %@ absorb remaining after %@ damage",self,effect,thisAbsorbRemaining,damageEvent.netDamage);
                    effect.absorb = thisAbsorbRemaining;
                    damageEvent.netAbsorbed = @( damageEvent.netAbsorbed.doubleValue + damageEvent.netDamage.doubleValue );
                    damageEvent.netDamage = @0;
                }
            }
            else if ( effect.healingOnDamage )
            {
                if ( damageEvent.netDamage.doubleValue >= effect.healingOnDamage.doubleValue )
                {
                    PHLog(self,@"%@ damage will consume %@'s %@",damageEvent.netDamage,self,effect);
                    damageEvent.netDamage = @( damageEvent.netDamage.doubleValue - effect.healingOnDamage.doubleValue );
                    damageEvent.netHealedOnDamage = effect.healingOnDamage;
                    [consumedEffects addIndex:idx];
                }
                else
                {
                    if ( effect.healingOnDamageIsOneShot )
                    {
                        PHLog(self,@"%@ damage will consume %@'s ONE-SHOT %@",damageEvent.netDamage,self,effect);
                        [consumedEffects addIndex:idx];
                    }
                    else
                        effect.healingOnDamage = @( effect.healingOnDamage.doubleValue - damageEvent.netDamage.doubleValue );
                    damageEvent.netHealedOnDamage = damageEvent.netDamage;
                    damageEvent.netDamage = @0;
                }
            }
        }];
        
        #warning TODO, MAJOR TODO, this access is not safe, have crashed with index out of bounds exception
        [consumedEffects enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL *stop) {
            Effect *effect = self.statusEffects[idx];
            [self consumeStatusEffect:effect];
        }];
    }
    
    switch( self.hdClass.specID )
    {
        case HDPROTPALADIN:
            [self handleProtPallyIncomingDamageEvent:damageEvent];
            break;
        default:
            break;
    }
    
    NSInteger newHealth = self.currentHealth.doubleValue - damageEvent.netDamage.doubleValue;
    if ( newHealth < 0 )
        newHealth = 0;
    
    self.currentHealth = @(newHealth);
    
    PHLog(self,@"%@ took %@ net damage from %@ (%@%@)",self,damageEvent.netDamage,damageEvent.spell.damage?damageEvent.spell.damage:damageEvent.spell.periodicDamage,
          damageEvent.netAbsorbed.doubleValue > 0 ?[NSString stringWithFormat:@"%@ absorbed",damageEvent.netAbsorbed]:@"",
            dodged?@", dodged":
                blocked?@", blocked":
                    parried?@", parried":@"");
}

- (NSNumber *)currentAbsorb
{
    __block NSNumber *totalAbsorb = @0;
    
    [self.statusEffects enumerateObjectsUsingBlock:^(Effect *effect, NSUInteger idx, BOOL *stop) {
        
        if ( effect.absorb )
            totalAbsorb = @( totalAbsorb.doubleValue + effect.absorb.doubleValue );
    }];
    
    return totalAbsorb;
}

- (void)handleSpellEnd:(Spell *)spell modifier:(EventModifier *)modifier
{
    return;
}

- (void)addStatusEffect:(Effect *)statusEffect source:(Entity *)source
{
    if ( self.isDead )
        return;
    
    if ( ! _statusEffects )
        _statusEffects = [NSMutableArray new];
    
    // TODO this callout should not exist merely to handle an effect which can't have multiple applications to the same target
    if ( ! [statusEffect handleAdditionWithOwner:self] )
    {
        PHLog(self,@"%@ says no to addition to %@ from %@",statusEffect,self,source);
        return;
    }
    
    NSDate *thisStartDate = [NSDate date];
    statusEffect.owner = self;
    statusEffect.startDate = thisStartDate;
    statusEffect.source = source;
    [(NSMutableArray *)_statusEffects addObject:statusEffect];
    PHLog(self,@"%@ is affected by %@",self,statusEffect);
    
    if ( statusEffect.periodicTick.doubleValue > 0 )
    {
        unsigned long totalTicks = statusEffect.duration / statusEffect.periodicTick.unsignedLongValue;
        __block unsigned long thisTick = 1;
        statusEffect.periodicTickSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.encounter.encounterQueue);
        dispatch_source_set_timer(statusEffect.periodicTickSource, DISPATCH_TIME_NOW, statusEffect.periodicTick.doubleValue * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(statusEffect.periodicTickSource, ^{
            //unsigned long ticks = dispatch_source_get_data(statusEffect.periodicTickSource);
            [statusEffect handleTickWithOwner:self isInitialTick:( thisTick == 1 )];
            if ( thisTick == totalTicks )
            {
                dispatch_source_cancel(statusEffect.periodicTickSource);
                statusEffect.periodicTickSource = NULL;
                
                if ( [_statusEffects containsObject:statusEffect] )
                {
                    PHLog(self,@"%@ on %@ has timed out",statusEffect,self);
                    [(NSMutableArray *)_statusEffects removeObject:statusEffect];
                }
                else
                    PHLog(self,@"%@ on %@ was removed some other way",statusEffect,self);
            }
            
            thisTick++;
        });
        dispatch_resume(statusEffect.periodicTickSource);
        PHLog(self,@"%@ will tick %lu times every %0.2f seconds and time out in %0.2f seconds",statusEffect,totalTicks,statusEffect.periodicTick.doubleValue,statusEffect.duration);
    }
    else
    {
        PHLog(self,@"%@ will time out in %0.2f seconds",statusEffect,statusEffect.duration);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(statusEffect.duration * NSEC_PER_SEC)), self.encounter.encounterQueue, ^{
            if ( statusEffect.startDate == thisStartDate )
                [(NSMutableArray *)_statusEffects removeObject:statusEffect];
            else
                PHLog(self,@"something else seems to have removed %@'s %@",self,statusEffect);
        });
    }
}

- (void)consumeStatusEffect:(Effect *)effect absolute:(BOOL)absolute
{
    if ( ! absolute )
    {
        if ( effect.currentStacks.integerValue > 1 )
        {
            PHLog(self,@"consumed a stack of %@",effect);
            effect.currentStacks = @( effect.currentStacks.integerValue - 1 );
            [effect handleConsumptionWithOwner:self];
            return;
        }
    }
    
    [effect handleRemovalWithOwner:self];
    [(NSMutableArray *)_statusEffects removeObject:effect];
    PHLog(self,@"removed %@'s %@",self,effect);
}

- (void)consumeStatusEffect:(Effect *)effect
{
    [self consumeStatusEffect:effect absolute:NO];
}

- (void)consumeStatusEffectNamed:(NSString *)statusEffectName
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
        [self consumeStatusEffect:object];
}

- (Spell *)spellWithClass:(Class)spellClass
{
    __block Spell *theSpell = nil;
    [self.spells enumerateObjectsUsingBlock:^(Spell *spell, NSUInteger idx, BOOL *stop) {
        if ( [spell class] == spellClass )
        {
            theSpell = spell;
            *stop = YES;
        }
    }];
    return theSpell;
}

- (void)emphasizeSpell:(Spell *)spell duration:(NSTimeInterval)duration
{
    NSDate *stopDate = [NSDate dateWithTimeIntervalSinceNow:duration];
    spell.isEmphasized = YES;
    spell.emphasisStopDate = stopDate;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), self.encounter.encounterQueue, ^{
        if ( stopDate == spell.emphasisStopDate )
        {
            spell.isEmphasized = NO;
            spell.emphasisStopDate = nil;
        }
        else
            PHLog(self,@"Something seems to have refreshed the emphasis on %@",spell);
    });
}

- (void)handleDeathOfEntity:(Entity *)dyingEntity fromSpell:(Spell *)spell
{
    if ( dyingEntity == self )
    {
        PHLog(self,@"%@ has died",self);
        self.isDead = YES;
        
        if ( self.deathSoundName )
            [SoundManager playHitSound:self];
        
        Effect *aStatusEffect = nil;
        while ( ( aStatusEffect = [self.statusEffects lastObject] ) )
            [self consumeStatusEffect:aStatusEffect];
        
        self.castingSpell = nil;
    }
    
    if ( dyingEntity.isPlayer )
    {
        if ( dyingEntity == self )
        {
            [SoundManager playDeathSound];
            self.castingSpell = nil;
        }
        else if ( self.castingSpell && dyingEntity == self.castingSpell.target )
        {
            PHLog(self,@"%@ aborting %@ because %@ died",self,self.castingSpell,dyingEntity);
            
            [SoundManager playSpellFizzle:dyingEntity.castingSpell];
            self.castingSpell = nil;
        }
    }
}

- (void)prepareForEncounter:(Encounter *)encounter
{
    self.currentHealth = self.health;
    self.currentResources = self.power;
    self.lastHealth = self.health;
    self.encounter = encounter;
}

- (void)beginEncounter:(Encounter *)encounter
{
    //PHLog(self,@"i, %@ (%@), should begin encounter",self,self.isPlayingPlayer?@"playing player":@"automated player");
    
    if ( ! self.isPlayingPlayer && self.isPlayer )
    {
        NSNumber *gcd = [ItemLevelAndStatsConverter globalCooldownWithEntity:self hasteBuffPercentage:nil];
        NSNumber *gcdWithStagger = @( (double)(( arc4random() % (int)(gcd.doubleValue * 100000) )) / 100000 + gcd.doubleValue );
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(gcdWithStagger.doubleValue * NSEC_PER_SEC)), encounter.encounterQueue, ^{
            [self _doAutomaticStuff];
        });
    }
    
    self.lastResourceGenerationDate = [NSDate date];
    self.resourceGenerationSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, encounter.encounterQueue);
    dispatch_source_set_timer(self.resourceGenerationSource, DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC, 0.2 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.resourceGenerationSource, ^{
        NSNumber *regeneratedResources = [ItemLevelAndStatsConverter resourceGenerationWithEntity:self timeInterval:[[NSDate date] timeIntervalSinceDateMinusPauseTime:self.lastResourceGenerationDate]];
        if ( regeneratedResources.doubleValue < 0 )
            [NSException raise:@"NegativeRegeneratedResources" format:@"%@ regenerated %@ resources since the last timer fire",self,regeneratedResources];
        double newResources = self.currentResources.doubleValue + regeneratedResources.doubleValue;
        if ( newResources > self.power.doubleValue )
            self.currentResources = self.power;
        else
            self.currentResources = @( newResources );
        self.lastResourceGenerationDate = [NSDate date];
    });
    dispatch_resume(self.resourceGenerationSource);
}

- (void)_doAutomaticStuff
{
    BOOL gcdTriggered = NO;
    
    if ( self.isDead )
        return;
    if ( self.stopped )
        return;
    
    BOOL classSwitchHandled = NO;
    switch( self.hdClass.specID )
    {
        default:
            gcdTriggered = [self castHighestPrioritySpell];
            classSwitchHandled = YES;
            break;
    }
    
    //if ( ! self.lastAutomaticAbilityDate ||
    //    [[NSDate date] timeIntervalSinceDateMinusPauseTime:self.lastAutomaticAbilityDate] )
    //PHLog(self,@"%@ is doing automated stuff",self);
    if ( ! classSwitchHandled )
    {
        if ( [self.hdClass.role isEqualToString:(NSString *)TankRole] )
        {
            gcdTriggered = [self _doAutomaticTanking];
        }
        else if ( [self.hdClass.role isEqualToString:(NSString *)DPSRole] )
        {
            gcdTriggered = [self _doAutomaticDPS];
        }
        else if ( [self.hdClass.role isEqualToString:(NSString *)HealerRole] )
        {
            gcdTriggered = [self _doAutomaticHealing];
        }
    }
    
    self.lastHealth = self.currentHealth;
    
    NSNumber *nextFireDate = gcdTriggered ? [ItemLevelAndStatsConverter globalCooldownWithEntity:self hasteBuffPercentage:nil] : @0;
    //PHLog(self,@"%@ will act again in %@ seconds",self,nextFireDate);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(nextFireDate.doubleValue * NSEC_PER_SEC)), self.encounter.encounterQueue, ^{
        [self _doAutomaticStuff];
    });
}

- (BOOL)_doAutomaticTanking
{
    return [self _doAutomaticDPS];
}

- (BOOL)_doAutomaticDPS
{
    NSInteger randomEnemy = arc4random() % self.encounter.enemies.count;
    Entity *enemy = self.encounter.enemies[randomEnemy];
    Class spellClass = self.hdClass.isCasterDPS ? [GenericDamageSpell class] : [GenericPhysicalAttackSpell class];
    Spell *spell = [[spellClass alloc] initWithCaster:self];
    self.target = enemy;
    PHLog(self,@"%@ is auto dpsing %@ for %@",self,enemy,spell.damage);
    //[encounter doDamage:spell source:self target:enemy modifiers:nil periodic:NO];
    //- (NSNumber *)castSpell:(Spell *)spell withTarget:(Entity *)target inEncounter:(Encounter *)encounter;
    // TODO, should be enumerating possible spells based on priorities and finding the best one
    // TODO, GCD?
    NSString *message = nil;
    if ( ! [self validateSpell:spell asSource:YES otherEntity:enemy message:&message invalidDueToCooldown:NULL] )
    {
        PHLog(self,@"%@ automatic spell cast failed: %@",self,message);
        return YES;
    }
    else if ( ! [enemy validateSpell:spell asSource:NO otherEntity:self message:&message invalidDueToCooldown:NULL] )
    {
        PHLog(self,@"%@ automatic spell cast failed: %@",self,message);
        return YES;
    }
    [self castSpell:spell withTarget:enemy];
    
    return spell.triggersGCD;
}

- (BOOL)_doAutomaticHealing
{
    if ( self.castingSpell )
        return YES;
    
    __block Spell *spellToCast = nil;
    [self.encounter.raid.players enumerateObjectsUsingBlock:^(Entity *player, NSUInteger idx, BOOL *stop) {
        if ( player.currentHealth.doubleValue < player.health.doubleValue )
        {
            //NSNumber *averageHealing = [ItemLevelAndStatsConverter automaticHealValueWithEntity:self];
            Spell *spell = [[GenericHealingSpell alloc] initWithCaster:self];
            
            NSArray *tankPlayers = self.encounter.raid.tankPlayers;
            __block Entity *mostDamagedTank = nil;
            __block double mostDamagedTankHealthPercentage = 1;
            [tankPlayers enumerateObjectsUsingBlock:^(Entity *tankPlayer, NSUInteger idx, BOOL *stop) {
                if ( tankPlayer.isDead )
                    return;
                double thisTankHealthPercentage = tankPlayer.currentHealthPercentage.doubleValue;
                if ( thisTankHealthPercentage < mostDamagedTankHealthPercentage )
                {
                    mostDamagedTank = tankPlayer;
                    mostDamagedTankHealthPercentage = thisTankHealthPercentage;
                }
            }];
            
            __block Entity *mostDamagedNonTank = nil;
            __block double mostDamagedNonTankHealthPercentage = 1;
            NSArray *nonTankPlayers = [self.encounter.raid nonTankPlayers];
            [nonTankPlayers enumerateObjectsUsingBlock:^(Entity *nonTankPlayer, NSUInteger idx, BOOL *stop) {
                if ( nonTankPlayer.isDead )
                    return;
                double thisNonTankHealthPercentage = nonTankPlayer.currentHealthPercentage.doubleValue;
                if ( thisNonTankHealthPercentage < mostDamagedNonTankHealthPercentage )
                {
                    mostDamagedNonTank = nonTankPlayer;
                    mostDamagedNonTankHealthPercentage = thisNonTankHealthPercentage;
                }
            }];
            
            Entity *entityToHeal = nil;
            double preferTankHealthPercentageThreshold = 1 - mostDamagedTankHealthPercentage;
            if ( mostDamagedTank )
            {
                if ( mostDamagedNonTankHealthPercentage < mostDamagedTankHealthPercentage
                    && ( (mostDamagedTankHealthPercentage - mostDamagedNonTankHealthPercentage ) > preferTankHealthPercentageThreshold ) )
                    entityToHeal = mostDamagedNonTank;
                else
                    entityToHeal = mostDamagedTank;
            }
            else if ( mostDamagedNonTank )
                entityToHeal = mostDamagedNonTank;
            
            self.target = entityToHeal;
            
            NSString *message = nil;
            if ( ! [self validateSpell:spell asSource:YES otherEntity:player message:&message invalidDueToCooldown:NULL] )
            {
                PHLog(self,@"%@ automatic spell cast failed: %@",self,message);
                return;
            }
            if ( ! [self.target validateSpell:spell asSource:NO otherEntity:self message:&message invalidDueToCooldown:NULL] )
            {
                PHLog(self,@"%@ automatic spell cast failed: %@",self,message);
                return;
            }
            
            spellToCast = spell;
            *stop = YES;
            //player.currentHealth = ( player.currentHealth.doubleValue + averageHealing.doubleValue > player.health.doubleValue ) ?
            //                        ( player.health ) : @( player.currentHealth.doubleValue + averageHealing.doubleValue );
        }
    }];
    
    if ( spellToCast )
        [self castSpell:spellToCast withTarget:self.target];
    
    return spellToCast.triggersGCD;
}

- (void)updateEncounter:(Encounter *)encounter
{
    //PHLog(self,@"i, %@, should update encounter",self);
    
    // TODO enumerate and remove status effects
}

- (void)endEncounter:(Encounter *)encounter
{
    //PHLog(self,@"i, %@, should end encounter",self);
    self.stopped = YES;
    self.castingSpell = nil;
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
    return [NSString stringWithFormat:@"%@ [%@,%@] (%@)",self.name,self.currentHealth,self.currentResources,self.hdClass];
}

- (NSNumber *)castSpell:(Spell *)spell withTarget:(Entity *)target
{
    if ( self.castingSpell )
    {
        // enqueue cast if within 'lead time'
        if ( self.castingSpell.lastCastEffectiveCastTime > 0 )
        {
            NSTimeInterval timeSinceCast = [[NSDate date] timeIntervalSinceDateMinusPauseTime:self.castingSpell.lastCastStartDate];
            double percentCast = timeSinceCast / self.castingSpell.lastCastEffectiveCastTime;
            if ( percentCast >= 0.66 )
            {
                if ( self.isPlayingPlayer )
                {
                    self.enqueuedSpell = spell;
                    self.enqueuedSpell.target = target;
                    PHLog(self,@"player enqueued %@->%@",spell,target);
                    [SoundManager playSpellQueueSound];
                }
                return nil;
            }
        }
        else
        {
            PHLog(self,@"%@ cancelled casting %@",self,self.castingSpell);
            self.castingSpell = nil;
            self.castingSpell.lastCastStartDate = nil;
            
            [SoundManager playSpellFizzle:spell];
        }
    }
    
    NSMutableArray *modifiers = [NSMutableArray new];
    if ( [self handleSpellStart:spell modifiers:modifiers] )
    {
    }
    else if ( [target handleSpellStart:spell modifiers:modifiers] )
    {
    }
    
    __block NSNumber *hasteBuff = nil;
    [modifiers enumerateObjectsUsingBlock:^(EventModifier *obj, NSUInteger idx, BOOL *stop) {
        PHLog(self,@"considering %@ for %@",obj,spell);
        if ( obj.hasteIncreasePercentage )
        {
            if ( ! hasteBuff || [obj.hasteIncreasePercentage compare:hasteBuff] == NSOrderedDescending )
                hasteBuff = obj.hasteIncreasePercentage; // oh yeah, we're not using haste at all yet
        }
    }];
            
    self.castingSpell = spell;
    self.castingSpell.target = target;
    NSDate *thisCastStartDate = [NSDate date];
    self.castingSpell.lastCastStartDate = thisCastStartDate;
    // get base cast time
    NSNumber *effectiveCastTime = [ItemLevelAndStatsConverter castTimeWithBaseCastTime:spell.castTime entity:self hasteBuffPercentage:hasteBuff];
    self.castingSpell.lastCastEffectiveCastTime = effectiveCastTime.doubleValue;
    
    PHLog(self,@"%@ started %@ %@ at %@",self,spell.isChanneled?@"channeling":@"casting",spell,target);
    
    if ( spell.triggersGCD )
    {
        NSTimeInterval effectiveGCD = [ItemLevelAndStatsConverter globalCooldownWithEntity:self hasteBuffPercentage:hasteBuff].doubleValue;
        self.nextGlobalCooldownDate = [NSDate dateWithTimeIntervalSinceNow:effectiveGCD];
        self.currentGlobalCooldownDuration = effectiveGCD;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(effectiveGCD * NSEC_PER_SEC)), self.encounter.encounterQueue, ^{
            self.nextGlobalCooldownDate = nil;
            self.currentGlobalCooldownDuration = 0;
        });
    }
    
    if ( spell.isChanneled || spell.castTime.doubleValue > 0 )
    {
        if ( hasteBuff )
            PHLog(self,@"%@'s haste is buffed by %@",self,hasteBuff);
        
        // TODO
        if ( self.isPlayer )
            [SoundManager playSpellSound:spell duration:effectiveCastTime.doubleValue];
        
        if ( spell.isChanneled )
        {
            NSTimeInterval timeBetweenTicks = effectiveCastTime.doubleValue / spell.channelTicks.doubleValue;
            __block NSInteger ticksRemaining = spell.channelTicks.unsignedIntegerValue;
            __block BOOL firstTick = YES;
            dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.encounter.encounterQueue);
            dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, timeBetweenTicks * NSEC_PER_SEC), timeBetweenTicks * NSEC_PER_SEC, 0.01 * NSEC_PER_SEC);
            dispatch_source_set_event_handler(timer, ^{
                
                [self.encounter handleSpell:spell periodicTick:YES isFirstTick:firstTick dyingEntitiesHandler:^(NSArray *dyingEntities) {
                    if ( [dyingEntities containsObject:self] || [dyingEntities containsObject:target] )
                    {
                        PHLog(spell,@"%@ or %@ have died during %@, so it is unscheduling",self,target,spell);
                        dispatch_source_cancel(timer);
                        return;
                    }
                }];
                firstTick = NO;
                if ( --ticksRemaining <= 0 )
                {
                    PHLog(self,@"%@ has finished channeling",spell);
                    dispatch_source_cancel(timer);
                    self.castingSpell = nil;
                }
            });
            dispatch_resume(timer);
        }
        else
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(effectiveCastTime.doubleValue * NSEC_PER_SEC)), self.encounter.encounterQueue, ^{
                // blah
                if ( thisCastStartDate != self.castingSpell.lastCastStartDate )
                {
                    PHLog(self,@"%@ was aborted because it is no longer the current spell at dispatch time",spell);
                    return;
                }
                [self.encounter handleSpell:self.castingSpell periodicTick:NO isFirstTick:NO dyingEntitiesHandler:NULL];
                self.castingSpell = nil;
                PHLog(self,@"%@ finished casting %@",self,spell);
                
                if ( self.enqueuedSpell )
                {
                    Spell *dequeuedSpell = self.enqueuedSpell;
                    self.enqueuedSpell = nil;
                    [self castSpell:dequeuedSpell withTarget:dequeuedSpell.target];
                }
            });
        }
    }
    else
    {
        PHLog(self,@"%@ cast %@ (instant)",self,spell);
        [self.encounter handleSpell:spell periodicTick:NO isFirstTick:NO dyingEntitiesHandler:NULL];
        self.castingSpell = nil;
    }
    
    return effectiveCastTime;
}

- (void)addAuxResources:(NSNumber *)addedResources
{
    if ( self.currentAuxiliaryResources.integerValue + addedResources.integerValue <= self.maxAuxiliaryResources.integerValue )
    {
        self.currentAuxiliaryResources = @( self.currentAuxiliaryResources.integerValue + addedResources.integerValue );
        PHLog(self,@"%@ has gained an aux resource (%@)",self,self.currentAuxiliaryResources);
    }
    else
    {
        self.currentAuxiliaryResources = self.maxAuxiliaryResources;
        PHLog(self,@"%@ is at full aux resources",self);
    }
}

- (BOOL)isOnGlobalCooldown
{
    NSDate *storedDate = self.nextGlobalCooldownDate;
    return storedDate && [[NSDate date] timeIntervalSinceDateMinusPauseTime:storedDate] <= 0;
}

- (NSNumber *)currentHealthPercentage
{
    return @( self.currentHealth.doubleValue / self.health.doubleValue );
}

@end
