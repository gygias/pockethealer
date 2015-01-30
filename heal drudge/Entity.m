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
#import "Event.h"
#import "ItemLevelAndStatsConverter.h"

#import "GenericDamageSpell.h"
#import "GenericHealingSpell.h"
#import "GenericPhysicalAttackSpell.h"
#import "SoundManager.h"

// AI
#import "Entity+ProtPaladin.h"

@implementation Entity

@synthesize currentHealth = _currentHealth,
            currentResources = _currentResources,
            statusEffects = _statusEffects,
            periodicEffectQueue = _periodicEffectQueue,
            hdClass = _hdClass;

- (id)init
{
    if ( self = [super init] )
    {
        self.emittingSounds = [NSMutableArray new];
    }
    return self;
}

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
                    [self consumeStatusEffect:obj];
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
                    [self consumeStatusEffect:obj];
                });
            }
        }] )
            addedModifiers = YES;
    }];
    
    if ( asSource )
    {
        NSInteger effectiveCost = spell.manaCost.integerValue;
        if ( spell.isChanneled )
            effectiveCost = effectiveCost / spell.channelTicks.integerValue;
        self.currentResources = @(source.currentResources.integerValue - effectiveCost);
        
        // TODO this isn't really general, conceivably something could have a "stacked" emphasis effect, but i can't think of one
        spell.isEmphasized = NO;
        spell.emphasisStopDate = nil;
    }
    
    return addedModifiers;
}

- (void)handleIncomingDamageEvent:(Event *)damageEvent
{    
    if ( self.hitSoundName )
        [SoundManager playSpellHit:self.hitSoundName volume:HIGH_VOLUME];
    
    BOOL dodged = NO;
    BOOL blocked = NO;
    BOOL parried = NO;
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
                    NSLog(@"%@ damage will consumed %@'s %@",damageEvent.netDamage,self,effect);
                    [consumedEffects addIndex:idx];
                    damageEvent.netAbsorbed = @( damageEvent.netAbsorbed.doubleValue + effect.absorb.doubleValue );
                    damageEvent.netDamage = @( damageEvent.netDamage.doubleValue - effect.absorb.doubleValue );
                }
                else
                {
                    NSNumber *thisAbsorbRemaining = @( effect.absorb.doubleValue - damageEvent.netDamage.doubleValue );
                    NSLog(@"%@'s %@ has %@ absorb remaining after %@ damage",self,effect,thisAbsorbRemaining,damageEvent.netDamage);
                    effect.absorb = thisAbsorbRemaining;
                    damageEvent.netAbsorbed = @( damageEvent.netAbsorbed.doubleValue + damageEvent.netDamage.doubleValue );
                    damageEvent.netDamage = @0;
                }
            }
            else if ( effect.healingOnDamage )
            {
                if ( damageEvent.netDamage.doubleValue >= effect.healingOnDamage.doubleValue )
                {
                    NSLog(@"%@ damage will consume %@'s %@",damageEvent.netDamage,self,effect);
                    damageEvent.netDamage = @( damageEvent.netDamage.doubleValue - effect.healingOnDamage.doubleValue );
                    damageEvent.netHealedOnDamage = effect.healingOnDamage;
                    [consumedEffects addIndex:idx];
                }
                else
                {
                    if ( effect.healingOnDamageIsOneShot )
                    {
                        NSLog(@"%@ damage will consume %@'s ONE-SHOT %@",damageEvent.netDamage,self,effect);
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
    
    NSLog(@"%@ took %@ net damage from %@ (%@%@)",self,damageEvent.netDamage,damageEvent.spell.damage,
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

- (BOOL)handleSpellEnd:(Spell *)spell asSource:(BOOL)asSource otherEntity:(Entity *)otherEntity modifiers:(NSMutableArray *)modifiers
{
    return NO;
}

- (void)addStatusEffect:(Effect *)statusEffect source:(Entity *)source
{    
    if ( ! _statusEffects )
        _statusEffects = [NSMutableArray new];
    
    // TODO this callout should not exist merely to handle an effect which can't have multiple applications to the same target
    if ( ! [statusEffect handleAdditionWithOwner:self] )
    {
        NSLog(@"%@ says no to addition to %@ from %@",statusEffect,self,source);
        return;
    }
    
    statusEffect.startDate = [NSDate date];
    statusEffect.source = source;
    [(NSMutableArray *)_statusEffects addObject:statusEffect];
    NSLog(@"%@ is affected by %@",self,statusEffect);
    
    if ( statusEffect.periodicTick.doubleValue > 0 )
    {
        NSLog(@"%@ will tick every %0.2f seconds",statusEffect,statusEffect.periodicTick.doubleValue);
        [statusEffect handleTickWithOwner:self isInitialTick:YES];
        statusEffect.periodicTickSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.encounter.encounterQueue);
        dispatch_source_set_timer(statusEffect.periodicTickSource, DISPATCH_TIME_NOW, statusEffect.periodicTick.doubleValue * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(statusEffect.periodicTickSource, ^{
            [statusEffect handleTickWithOwner:self isInitialTick:NO];
        });
        dispatch_resume(statusEffect.periodicTickSource);
    }
    
    NSLog(@"%@ will time out in %0.2f seconds",statusEffect,statusEffect.duration);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(statusEffect.duration * NSEC_PER_SEC)), self.encounter.encounterQueue, ^{
        if ( [_statusEffects containsObject:statusEffect] )
        {
            NSLog(@"%@ on %@ has timed out",statusEffect,self);
            [(NSMutableArray *)_statusEffects removeObject:statusEffect];
        }
        else
            NSLog(@"%@ on %@ was removed some other way",statusEffect,self);
    });
}

- (void)consumeStatusEffect:(Effect *)effect absolute:(BOOL)absolute
{
    if ( ! absolute )
    {
        if ( effect.currentStacks.integerValue > 1 )
        {
            NSLog(@"consumed a stack of %@",effect);
            effect.currentStacks = @( effect.currentStacks.integerValue - 1 );
            [effect handleConsumptionWithOwner:self];
            return;
        }
    }
    
    [effect handleRemovalWithOwner:self];
    [(NSMutableArray *)_statusEffects removeObject:effect];
    NSLog(@"removed %@'s %@",self,effect);
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
            NSLog(@"Something seems to have refreshed the emphasis on %@",spell);
    });
}

- (void)handleDeathOfEntity:(Entity *)dyingEntity fromSpell:(Spell *)spell
{
    if ( dyingEntity == self )
    {
        NSLog(@"%@ has died",self);
        self.isDead = YES;
        
        if ( self.deathSoundName )
            [SoundManager playSpellHit:self.deathSoundName volume:HIGH_VOLUME];
        
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
    self.lastHealth = self.health;
    self.encounter = encounter;
}

- (void)beginEncounter:(Encounter *)encounter
{
    //NSLog(@"i, %@ (%@), should begin encounter",self,self.isPlayingPlayer?@"playing player":@"automated player");
    
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
        NSNumber *regeneratedResources = [ItemLevelAndStatsConverter resourceGenerationWithEntity:self timeInterval:[[NSDate date] timeIntervalSinceDate:self.lastResourceGenerationDate]];
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
        case HDPROTPALADIN:
            gcdTriggered = [self doProtPaladinAI];
            classSwitchHandled = YES;
            break;
        default:
            break;
    }
    
    //if ( ! self.lastAutomaticAbilityDate ||
    //    [[NSDate date] timeIntervalSinceDate:self.lastAutomaticAbilityDate] )
    //NSLog(@"%@ is doing automated stuff",self);
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
    //NSLog(@"%@ will act again in %@ seconds",self,nextFireDate);
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
    NSLog(@"%@ is auto dpsing %@ for %@",self,enemy,spell.damage);
    //[encounter doDamage:spell source:self target:enemy modifiers:nil periodic:NO];
    //- (NSNumber *)castSpell:(Spell *)spell withTarget:(Entity *)target inEncounter:(Encounter *)encounter;
    // TODO, should be enumerating possible spells based on priorities and finding the best one
    // TODO, GCD?
    NSString *message = nil;
    if ( ! [self validateSpell:spell asSource:YES otherEntity:enemy message:&message invalidDueToCooldown:NULL] )
    {
        NSLog(@"%@ automatic spell cast failed: %@",self,message);
        return YES;
    }
    else if ( ! [enemy validateSpell:spell asSource:NO otherEntity:self message:&message invalidDueToCooldown:NULL] )
    {
        NSLog(@"%@ automatic spell cast failed: %@",self,message);
        return YES;
    }
    [self castSpell:spell withTarget:enemy];
    
    return spell.triggersGCD;
}

- (BOOL)_doAutomaticHealing
{
    return YES;
    if ( self.castingSpell )
        return YES;
    
    __block Spell *spellToCast = nil;
    [self.encounter.raid.players enumerateObjectsUsingBlock:^(Entity *player, NSUInteger idx, BOOL *stop) {
        if ( player.currentHealth.doubleValue < player.health.doubleValue )
        {
            //NSNumber *averageHealing = [ItemLevelAndStatsConverter automaticHealValueWithEntity:self];
            Spell *spell = [[GenericHealingSpell alloc] initWithCaster:self];
            NSLog(@"%@ is healing %@ for %@",self,player,spell.healing);
            self.target = player;
            //[encounter doHealing:spell source:self target:player modifiers:nil periodic:NO];
            
            NSString *message = nil;
            if ( ! [self validateSpell:spell asSource:YES otherEntity:player message:&message invalidDueToCooldown:NULL] )
            {
                NSLog(@"%@ automatic spell cast failed: %@",self,message);
                return;
            }
            if ( ! [player validateSpell:spell asSource:NO otherEntity:self message:&message invalidDueToCooldown:NULL] )
            {
                NSLog(@"%@ automatic spell cast failed: %@",self,message);
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
    
    return YES;
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
                
                [self.encounter handleSpell:spell source:self target:target periodicTick:YES periodicTickSource:timer isFirstTick:firstTick];
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
                [self.encounter handleSpell:self.castingSpell source:self target:target periodicTick:NO periodicTickSource:NULL isFirstTick:NO];
                self.castingSpell = nil;
                NSLog(@"%@ finished casting %@",self,spell);
            });
        }
    }
    else
    {
        NSLog(@"%@ cast %@ (instant)",self,spell);
        [self.encounter handleSpell:spell source:self target:target periodicTick:NO periodicTickSource:NULL isFirstTick:NO];
    }
    
    return effectiveCastTime;
}

- (void)addAuxResources:(NSNumber *)addedResources
{
    if ( self.currentAuxiliaryResources.integerValue + addedResources.integerValue <= self.maxAuxiliaryResources.integerValue )
    {
        self.currentAuxiliaryResources = @( self.currentAuxiliaryResources.integerValue + addedResources.integerValue );
        NSLog(@"%@ has gained an aux resource (%@)",self,self.currentAuxiliaryResources);
    }
    else
    {
        self.currentAuxiliaryResources = self.maxAuxiliaryResources;
        NSLog(@"%@ is at full aux resources",self);
    }
}

@end
