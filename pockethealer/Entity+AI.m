//
//  Entity+AI.m
//  pockethealer
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "Entity+AI.h"
#import "Encounter.h"
#import "ItemLevelAndStatsConverter.h"

#define NOT_TOPPED_OFF_THRESHOLD (1.0)
#define NEED_HEALING_THRESHOLD (0.9)
#define FEAR_OF_DYING_THRESHOLD (0.2)
#define FEAR_OF_DYING_DELTA (0.33)
#define URGENT_HEALING_THRESHOLD (0.3)

@implementation Entity (AI)

- (AISpellPriority)currentSpellPriorities:(NSDictionary **)outTargetMap
{
    __block NSMutableDictionary *targetMap = [NSMutableDictionary dictionary];
    __block AISpellPriority priorities = FillerPriority | ChargePriority | ConsumeChargePriority;
    double healthPercentage = self.currentHealthPercentage.doubleValue;
    double healthDelta = ( self.currentHealth.doubleValue - self.lastHealth.doubleValue ) / self.health.doubleValue;
    
    if ( healthPercentage < NOT_TOPPED_OFF_THRESHOLD )
    {
        PHLog(self,@"%@: I'm not topped off",self);
        AISpellPriority thePriority = CastWhenNotToppedOffPriority;
        priorities |= thePriority;
        [targetMap setObject:self forKey:[NSNumber numberWithInteger:thePriority]];
    }
    if ( healthPercentage < NEED_HEALING_THRESHOLD )
    {
        PHLog(self,@"%@: I'm at %0.0f%% health so I need healing",self,healthPercentage*100);
        AISpellPriority thePriority = CastWhenINeedHealingPriority;
        priorities |= thePriority;
        [targetMap setObject:self forKey:[NSNumber numberWithInteger:thePriority]];
    }
    if ( healthPercentage <= URGENT_HEALING_THRESHOLD )
    {
        PHLog(self,@"%@: I'm at %0.0f%% health and need urgent healing",self,healthPercentage*100);
        AISpellPriority thePriority = CastWhenINeedUrgentHealingPriority;
        priorities |= thePriority;
        [targetMap setObject:self forKey:[NSNumber numberWithInteger:thePriority]];
    }
    if ( healthDelta > FEAR_OF_DYING_DELTA || healthPercentage <= FEAR_OF_DYING_THRESHOLD )
    {
        PHLog(self,@"%@: I'm at %0.0f%% health and am in fear of dying",self,healthPercentage*100);
        AISpellPriority thePriority = CastWhenInFearOfSelfDyingPriority;
        priorities |= thePriority; // TODO "nervous, chance to mistakenly blow large cd?"
        [targetMap setObject:self forKey:[NSNumber numberWithInteger:thePriority]];
    }
    
    if ( self.largePhysicalHitIncoming )
        priorities |= CastBeforeLargePhysicalHitPriority;
    if ( self.largeMagicHitIncoming )
        priorities |= CastBeforeLargeMagicHitPriority;
    if ( self.largePhysicalAOEIncoming )
        priorities |= CastBeforeLargePhysicalAOEPriority;
    if ( self.largeMagicAOEIncoming )
        priorities |= CastBeforeLargeMagicAOEPriority;
    
    __block NSUInteger nDamagedPartyMembers = 0;
    NSArray *partyMembers = nil;
    if ( [self.hdClass isEqual:[HDClass discPriest]] || [self.hdClass isEqual:[HDClass holyPriest]] )
        partyMembers = [self.encounter.raid partyForEntity:self includingEntity:NO];
    
    [self.encounter.raid.players enumerateObjectsUsingBlock:^(Entity *aPlayer, NSUInteger idx, BOOL *stop) {
        
        if ( aPlayer.isDead )
            return;
        if ( aPlayer == self )
            return;
        
        if ( aPlayer.currentHealthPercentage.doubleValue < NOT_TOPPED_OFF_THRESHOLD )
        {
            PHLog(self,@"%@: %@ is not topped off",self,aPlayer);
            AISpellPriority thePriority = aPlayer.hdClass.isTank ? CastWhenTankNotToppedOffPriority : CastWhenSomeoneNotToppedOffPriority;
            priorities |= thePriority;
            [targetMap setObject:aPlayer forKey:[NSNumber numberWithInteger:thePriority]];
        }
        if ( aPlayer.currentHealthPercentage.doubleValue < NEED_HEALING_THRESHOLD )
        {
            PHLog(self,@"%@: %@ is at %0.0f%% health and needs healing",self,aPlayer,aPlayer.currentHealthPercentage.doubleValue*100);
            AISpellPriority thePriority = aPlayer.hdClass.isTank ? CastWhenTankNeedsHealingPriority : CastWhenSomeoneNeedsHealingPriority;
            priorities |= thePriority;
            [targetMap setObject:aPlayer forKey:[NSNumber numberWithInteger:thePriority]];
            
            // currently, 'party needs healing' based off 90%ish
            if ( partyMembers && [partyMembers containsObject:aPlayer] )
                nDamagedPartyMembers++;
        }
        if ( aPlayer.currentHealthPercentage.doubleValue < URGENT_HEALING_THRESHOLD )
        {
            PHLog(self,@"%@: %@ is at %0.0f%% health and needs urgent healing",self,aPlayer,aPlayer.currentHealthPercentage.doubleValue*100);
            AISpellPriority thePriority = aPlayer.hdClass.isTank ? CastWhenTankNeedsUrgentHealingPriority : CastWhenSomeoneNeedsUrgentHealingPriority;
            priorities |= thePriority;
            [targetMap setObject:aPlayer forKey:[NSNumber numberWithInteger:thePriority]];
        }
        if ( aPlayer.currentHealthPercentage.doubleValue < FEAR_OF_DYING_THRESHOLD )
        {
            PHLog(self,@"%@: %@ is at %0.0f%% health and needs urgent healing",self,aPlayer,aPlayer.currentHealthPercentage.doubleValue*100);
            AISpellPriority thePriority = aPlayer.hdClass.isTank ? CastWhenInFearOfTankDyingPriority : CastWhenInFearOfDPSDyingPriority;
            priorities |= thePriority;
            [targetMap setObject:aPlayer forKey:[NSNumber numberWithInteger:thePriority]];
        }
        
        if ( aPlayer != self )
        {
            [aPlayer.statusEffects enumerateObjectsUsingBlock:^(Effect *aEffect, NSUInteger idx, BOOL *stop) {
                if ( self.hdClass.isTank && aPlayer.hdClass.isTank && aEffect.source.target == aPlayer
                    && ( aEffect.tauntAtStacks.integerValue > 0 ) &&
                    aEffect.currentStacks.integerValue >= aEffect.tauntAtStacks.integerValue )
                {
                    PHLog(self,@"%@: %@'s %@ is at %@ stacks, I should taunt",self,aPlayer,aEffect,aEffect.currentStacks);
                    AISpellPriority thePriority = CastWhenOtherTankNeedsTauntOff;
                    priorities |= thePriority;
                    [targetMap setObject:aEffect.source forKey:[NSNumber numberWithInteger:thePriority]];
                    *stop = YES;
                }
            }];
        }
        
        if ( aPlayer.largePhysicalHitIncoming )
        {
            AISpellPriority thePriority = aPlayer.hdClass.isTank ?
                                            CastBeforeTankTakesLargePhysicalHit : CastBeforeSomeoneTakesLargePhysicalHit;
            priorities |= thePriority;
            [targetMap setObject:aPlayer forKey:@(thePriority)];
        }
        if ( aPlayer.largeMagicHitIncoming )
        {
            AISpellPriority thePriority = aPlayer.hdClass.isTank ?
                                            CastBeforeTankTakesLargeMagicHit : CastBeforeSomeoneTakesLargeMagicHit;
            priorities |= thePriority;
            [targetMap setObject:aPlayer forKey:@(thePriority)];
        }
    }];
    
    if ( nDamagedPartyMembers >= 3 )
    {
        AISpellPriority thePriority = CastWhenPartyNeedsHealing;
        priorities |= thePriority;
        [targetMap setObject:self forKey:@(thePriority)];
    }
    
    //if ( someWayOfKnowing.heroIncomingOrInProgress )
    //{
    //    PHLog(self,@"%@: Hero is imminent, I should use my buffs",self);
    //    priorities |= CastWhenDamageDoneIncreasedPriority;
    //}
    
    //if ( someWayOfKnowing.largeDamageIncoming )
    //{
    //    PHLog(self,@"%@: I'm about to get hit with something big, I should use my mitigation!",self);
    //    priorities |= CastBeforeLargeHitPriority;
    //}
    
    if ( outTargetMap )
        *outTargetMap = targetMap;
    
    return priorities;
}

- (BOOL)castHighestPrioritySpell
{
    NSDictionary *targetMap = nil;
    AISpellPriority currentPriorities = [self currentSpellPriorities:&targetMap];
    
    __block AISpellPriority highestPriority = NoPriority;
    __block Spell *highestPrioritySpell = nil;
    [self.spells enumerateObjectsUsingBlock:^(Spell *spell, NSUInteger idx, BOOL *stop) {
        //PHLog(self,@"%@(%@,%@) is wondering if they should cast %@ (%@,%@)",self,self.currentResources,self.currentAuxiliaryResources,spell,spell.manaCost,spell.auxiliaryResourceCost);
        
        if ( spell.isOnCooldown )
        {
            //PHLog(self,@"  %@ is on cooldown",spell);
            return;
        }
        
        if ( spell.manaCost.doubleValue > self.currentResources.doubleValue )
        {
            //PHLog(self,@"  %@ doesn't have enough mana for %@",self,spell);
            return;
        }
        
        if ( spell.auxiliaryResourceCost )
        {
            if ( spell.auxiliaryResourceCost.doubleValue > self.currentAuxiliaryResources.doubleValue )
            {
                //PHLog(self,@"  %@ doesn't have enough aux resource for %@",self,spell);
                return;
            }
            
            if ( ! ( currentPriorities & CastWhenInFearOfAnyoneDyingPriority )
                && spell.auxiliaryResourceIdealCost.doubleValue > self.currentAuxiliaryResources.doubleValue )
            {
                //PHLog(self,@"  %@ is waiting to cast %@ because they only have %@/%@ aux resources and no one is imminently dying",self,spell,self.currentAuxiliaryResources,spell.auxiliaryResourceIdealCost);
                return;
            }
        }
        
//        if ( [NSStringFromClass([spell class]) isEqual:@"PainSuppressionSpell"] && ( currentPriorities & CastBeforeAnyoneTakesLargeHit ) )
//            NSLog(@"yo");
//        if ( [NSStringFromClass([spell class]) isEqual:@"SmiteSpell"] )
//            NSLog(@"yo");
        
        AISpellPriority thisSpellMatchedPriority = spell.aiSpellPriority & currentPriorities;
        if ( thisSpellMatchedPriority )
        {
            AISpellPriority highestMatchedPriority = 1 << (AISpellPriority)log2(thisSpellMatchedPriority);
            
            if ( ( spell.cooldownType == CooldownTypeMajor )
                && self.lastMajorCooldownUsedDate && [[NSDate date] timeIntervalSinceDateMinusPauseTime:self.lastMajorCooldownUsedDate] < AI_MAJOR_COOLDOWN_COOLDOWN )
            {
                PHLog(self,@"%@ is currently a priority spell, but it's only been %0.2fs since my last major CD",spell,[[NSDate date] timeIntervalSinceDateMinusPauseTime:self.lastMajorCooldownUsedDate]);
                return;
            }
            if ( ( spell.cooldownType == CooldownTypeMinor )
                && self.lastMinorCooldownUsedDate && [[NSDate date] timeIntervalSinceDateMinusPauseTime:self.lastMinorCooldownUsedDate] < AI_MINOR_COOLDOWN_COOLDOWN )
            {
                PHLog(self,@"%@ is currently a priority spell, but it's only been %0.2fs since my last minor CD",spell,[[NSDate date] timeIntervalSinceDateMinusPauseTime:self.lastMajorCooldownUsedDate]);
                return;
            }
            
            Entity *target = [self _whoWouldICastThisOnWithSpell:spell highPriorityBit:highestMatchedPriority map:targetMap];
            if ( ! [self validateSpell:spell asSource:YES otherEntity:target message:NULL invalidDueToCooldown:NULL] )
                return;
            if ( self != target && ! [target validateSpell:spell asSource:NO otherEntity:self message:NULL invalidDueToCooldown:NULL] )
                return;
            
            if ( highestMatchedPriority > highestPriority )
            {
                PHLog(self,@"%@'s %@ meets current priorities and is higher priority than %@",self,spell,highestPrioritySpell);
                highestPrioritySpell = spell;
                highestPriority = highestMatchedPriority;
            }
            //else
            //    PHLog(self,@"%@'s %@ meets current priorities but isn't higher priority than %@",self,spell,highestPrioritySpell);
            
            //            if ( [NSStringFromClass([spell class]) isEqualToString:@"LayOnHandsSpell"] )
            //            {
            //                PHLog(self,@"SPELL %08x CURRENT %08x",spell.aiSpellPriority,currentPriorities);
            //                PHLog(self,@"i'm casting loh...?");
            //            }
            //*stop = YES;
            return;
        }
        //else
        //PHLog(self,@"  %@ is not currently a priority",spell);
    }];
    
    if ( highestPrioritySpell )
    {
        Entity *target = [self _whoWouldICastThisOnWithSpell:highestPrioritySpell highPriorityBit:highestPriority map:targetMap];
        
        if ( ! [self validateSpell:highestPrioritySpell asSource:YES otherEntity:target message:NULL invalidDueToCooldown:NULL] )
            [NSException raise:@"AISourceBugException" format:@"%@->%@ %@ didn't validate, and shouldn't have above",highestPrioritySpell.caster,target,highestPrioritySpell];
        if ( self != target && ! [target validateSpell:highestPrioritySpell asSource:NO otherEntity:self message:NULL invalidDueToCooldown:NULL] )
            [NSException raise:@"AITargetBugException" format:@"%@->%@ %@ didn't validate, and shouldn't have above",highestPrioritySpell.caster,target,highestPrioritySpell];
        
        self.target = target;
        
        if ( [NSStringFromClass([highestPrioritySpell class]) isEqualToString:@"WordOfGlorySpell"] && self.currentAuxiliaryResources.integerValue == 0 )
            [NSException raise:@"WordOfGloryNoHolyPower" format:@"%@ tried to cast %@ with %@/%@",self,highestPrioritySpell,self.currentAuxiliaryResources,self.maxAuxiliaryResources];
        
        [self castSpell:highestPrioritySpell withTarget:target];
        PHLog(self,@"%@ will%@ trigger gcd",highestPrioritySpell,highestPrioritySpell.triggersGCD?@"":@" NOT");
        
        if ( highestPrioritySpell.cooldownType == CooldownTypeMajor )
            self.lastMajorCooldownUsedDate = [NSDate date];
        else if ( highestPrioritySpell.cooldownType == CooldownTypeMinor )
            self.lastMinorCooldownUsedDate = [NSDate date];
    }
    else
    {
        PHLog(self,@"%@ couldn't figure out anything to do on this update",self);
        
        NSTimeInterval effectiveGCD = [ItemLevelAndStatsConverter globalCooldownWithEntity:self hasteBuffPercentage:0].doubleValue;;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(effectiveGCD * NSEC_PER_SEC)), self.encounter.encounterQueue, ^{
            [self _doAutomaticStuff];
        });
    }
    
    return ! highestPrioritySpell || highestPrioritySpell.triggersGCD;
}

- (Entity *)_whoWouldICastThisOnWithSpell:(Spell *)spell highPriorityBit:(AISpellPriority)highPriorityBit map:(NSDictionary *)targetMap
{
    Entity *target = [targetMap objectForKey:[NSNumber numberWithInteger:highPriorityBit]];
    if ( ! target )
    {
        if ( spell.spellType == DetrimentalSpell )
            target = [self.encounter.enemies randomObject];
        else if ( spell.aiSpellPriority & PrecastOnMainTankPriority )
            target = [self.encounter currentMainTank];
        else if ( self.target.isPlayer )
            target = self.target;
        else
            target = self;
    }
    
    return target;
}

@end
