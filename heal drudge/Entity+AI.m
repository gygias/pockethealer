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

@implementation Entity (AI)

- (AISpellPriority)currentSpellPriorities
{
    __block AISpellPriority priorities = FillerPriotity;
    double healthPercentage = self.currentHealthPercentage.doubleValue;
    double healthDelta = ( self.currentHealth.doubleValue - self.lastHealth.doubleValue ) / self.health.doubleValue;
    if ( healthDelta > 0.33 )
    {
        PHLog(self,@"%@: I've taken a lot of damage since my last update, I'm in fear of dying",self);
        priorities |= CastWhenInFearOfDyingPriority; // TODO "nervous, chance to mistakenly blow large cd?"
    }
    if ( healthPercentage <= 0.33 )
    {
        PHLog(self,@"%@: I'm at %0.0f%% health and am in fear of dying",self,healthPercentage*100);
        priorities |= CastWhenInFearOfDyingPriority;
    }
    if ( healthPercentage < 1.0 )
    {
        PHLog(self,@"%@: I'm at %0.0f%% health so I need healing",self,healthPercentage*100);
        priorities |= CastWhenTankNeedsHealingPriority;
    }
    if ( self.hdClass.isTank )
    {
        __block BOOL stopAll = NO;
        [self.encounter.raid.tankPlayers enumerateObjectsUsingBlock:^(Entity *aTank, NSUInteger idx, BOOL *stop) {
            if ( aTank != self )
            {
                [aTank.statusEffects enumerateObjectsUsingBlock:^(Effect *aEffect, NSUInteger idx, BOOL *stop) {
                    if ( aEffect.source.target == aTank &&
                        aEffect.currentStacks.integerValue >= aEffect.tauntAtStacks.integerValue )
                    {
                        PHLog(self,@"%@: %@'s %@ is at %@ stacks, I should taunt",self,aTank,aEffect,aEffect.currentStacks);
                        priorities |= CastWhenOtherTankNeedsTauntOff;
                        stopAll = YES;
                        *stop = YES;
                    }
                }];
                if ( stopAll )
                    *stop = YES;
            }
        }];
    }
    
    // if ( someWayOfKnowing.heroIncomingOrInProgress )
    //{
    //    PHLog(self,@"%@: Hero is imminent, I should use my buffs",self);
    //    priorities |= CastWhenDamageDoneIncreasedPriority;
    //}
    
    // if ( someWayOfKnowing.largeDamageIncoming )
    //{
    //    PHLog(self,@"%@: I'm about to get hit with something big, I should use my mitigation!",self);
    //    priorities |= CastBeforeLargeHitPriority;
    //}
    
    return priorities;
}

- (BOOL)castHighestPrioritySpell
{
    AISpellPriority currentPriorities = [self currentSpellPriorities];
    
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
            
            if ( ! ( currentPriorities & CastWhenInFearOfOtherPlayerDyingPriority )
                && spell.auxiliaryResourceIdealCost.doubleValue > self.currentAuxiliaryResources.doubleValue )
            {
                //PHLog(self,@"  %@ is waiting to cast %@ because they only have %@/%@ aux resources and no one is imminently dying",self,spell,self.currentAuxiliaryResources,spell.auxiliaryResourceIdealCost);
                return;
            }
        }
        
        if ( spell.aiSpellPriority & currentPriorities )
        {
            if ( spell.aiSpellPriority > highestPrioritySpell.aiSpellPriority )
            {
                //PHLog(self,@"%@'s %@ meets current priorities and is higher priority than %@",self,spell,highestPrioritySpell);
                highestPrioritySpell = spell;
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
    
    // TODO
    Entity *target = self;
    if ( highestPrioritySpell.spellType == DetrimentalSpell )
        target = [self.encounter.enemies randomObject];
    
    if ( highestPrioritySpell )
    {
        if ( [NSStringFromClass([highestPrioritySpell class]) isEqualToString:@"WordOfGlorySpell"] && self.currentAuxiliaryResources.integerValue == 0 )
            [NSException raise:@"WordOfGloryNoHolyPower" format:@"%@ tried to cast %@ with %@/%@",self,highestPrioritySpell,self.currentAuxiliaryResources,self.maxAuxiliaryResources];
        [self castSpell:highestPrioritySpell withTarget:target];
        PHLog(self,@"%@ will%@ trigger gcd",highestPrioritySpell,highestPrioritySpell.triggersGCD?@"":@" NOT");
    }
    else
        PHLog(self,@"%@ couldn't figure out anything to do on this update",self);
    
    return ! highestPrioritySpell || highestPrioritySpell.triggersGCD;
}

@end
