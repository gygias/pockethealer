//
//  Entity+AI.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PocketHealer.h"

#import "Entity+AI.h"
#import "Encounter.h"
#import "ItemLevelAndStatsConverter.h"

#define NEED_HEALING_THRESHOLD (1.0)
#define FEAR_OF_DYING_THRESHOLD (0.2)
#define FEAR_OF_DYING_DELTA (0.33)
#define URGENT_HEALING_THRESHOLD (0.3)

@implementation Entity (AI)

- (AISpellPriority)currentSpellPriorities:(NSDictionary **)outTargetMap
{
    __block NSMutableDictionary *targetMap = [NSMutableDictionary dictionary];
    __block AISpellPriority priorities = FillerPriority;
    double healthPercentage = self.currentHealthPercentage.doubleValue;
    double healthDelta = ( self.currentHealth.doubleValue - self.lastHealth.doubleValue ) / self.health.doubleValue;
    if ( healthDelta > FEAR_OF_DYING_DELTA )
    {
        PHLog(self,@"%@: I've taken a lot of damage since my last update, I'm in fear of dying",self);
        AISpellPriority thePriority = CastWhenInFearOfSelfDyingPriority;
        priorities |= thePriority; // TODO "nervous, chance to mistakenly blow large cd?"
        [targetMap setObject:self forKey:[NSNumber numberWithInteger:thePriority]];
    }
    if ( healthPercentage <= FEAR_OF_DYING_THRESHOLD )
    {
        PHLog(self,@"%@: I'm at %0.0f%% health and am in fear of dying",self,healthPercentage*100);
        AISpellPriority thePriority = CastWhenInFearOfSelfDyingPriority;
        priorities |= thePriority;
        [targetMap setObject:self forKey:[NSNumber numberWithInteger:thePriority]];
    }
    if ( healthPercentage <= URGENT_HEALING_THRESHOLD )
    {
        PHLog(self,@"%@: I'm at %0.0f%% health and need urgent healing",self,healthPercentage*100);
        AISpellPriority thePriority = CastWhenINeedHealingPriority;
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
    
    [self.encounter.raid.players enumerateObjectsUsingBlock:^(Entity *aPlayer, NSUInteger idx, BOOL *stop) {
        
        if ( aPlayer.isDead )
            return;
        
        if ( aPlayer.currentHealthPercentage.doubleValue < NEED_HEALING_THRESHOLD )
        {
            PHLog(self,@"%@: %@ is at %0.0f%% health and needs healing",self,aPlayer,aPlayer.currentHealthPercentage.doubleValue*100);
            AISpellPriority thePriority = aPlayer.hdClass.isTank ? CastWhenTankNeedsHealingPriority : CastWhenSomeoneNeedsHealingPriority;
            priorities |= thePriority;
            [targetMap setObject:aPlayer forKey:[NSNumber numberWithInteger:thePriority]];
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
                if ( self.hdClass.isTank && aPlayer.hdClass.isTank && aEffect.source.target == aPlayer &&
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
    }];
    
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
        
        AISpellPriority thisSpellMatchedPriority = spell.aiSpellPriority & currentPriorities;
        if ( thisSpellMatchedPriority )
        {
            AISpellPriority highestMatchedPriority = 1 << (AISpellPriority)log2(thisSpellMatchedPriority);
            if ( spell.aiSpellPriority > highestPriority )
            {
                PHLog(self,@"%@'s %@ meets current priorities and is higher priority than %@",self,spell,highestPrioritySpell);                
                if ( self.hdClass.isHealerClass )
                    NSLog(@"??");
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
    
    if ( self.hdClass.isHealerClass )
        NSLog(@"??");
    
    if ( highestPrioritySpell )
    {
        Entity *target = [targetMap objectForKey:[NSNumber numberWithInteger:highestPriority]];
        if ( ! target )
        {
            if ( highestPrioritySpell.spellType == DetrimentalSpell )
                target = [self.encounter.enemies randomObject];
            else if ( self.target.isPlayer )
                target = self.target;
            else
                target = self;
        }
        self.target = target;
    
        if ( self.hdClass.isMeleeDPS && ! target.isEnemy )
            NSLog(@"??");
        
        if ( [NSStringFromClass([highestPrioritySpell class]) isEqualToString:@"WordOfGlorySpell"] && self.currentAuxiliaryResources.integerValue == 0 )
            [NSException raise:@"WordOfGloryNoHolyPower" format:@"%@ tried to cast %@ with %@/%@",self,highestPrioritySpell,self.currentAuxiliaryResources,self.maxAuxiliaryResources];
        
        [self castSpell:highestPrioritySpell withTarget:target];
        PHLog(self,@"%@ will%@ trigger gcd",highestPrioritySpell,highestPrioritySpell.triggersGCD?@"":@" NOT");
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

@end
