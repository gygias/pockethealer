//
//  Entity+ProtPaladin.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Logging.h"

#import "Entity+ProtPaladin.h"

#import "Entity+AI.h"
#import "NSCollections+Random.h"
#import "Event.h"
#import "Encounter.h"

#import "AvengersShieldSpell.h"

@implementation Entity (ProtPaladin)

- (BOOL)doProtPaladinAI
{
    AISpellPriority currentPriorities = [self currentSpellPriorities];
    
    __block Spell *highestPrioritySpell = nil;
    [self.spells enumerateObjectsUsingBlock:^(Spell *spell, NSUInteger idx, BOOL *stop) {
        //PHLog(@"%@(%@,%@) is wondering if they should cast %@ (%@,%@)",self,self.currentResources,self.currentAuxiliaryResources,spell,spell.manaCost,spell.auxiliaryResourceCost);
        
        if ( spell.isOnCooldown )
        {
            //PHLog(@"  %@ is on cooldown",spell);
            return;
        }
        
        if ( spell.manaCost.doubleValue > self.currentResources.doubleValue )
        {
            //PHLog(@"  %@ doesn't have enough mana for %@",self,spell);
            return;
        }
        
        if ( spell.auxiliaryResourceCost )
        {
            if ( spell.auxiliaryResourceCost.doubleValue > self.currentAuxiliaryResources.doubleValue )
            {
                //PHLog(@"  %@ doesn't have enough aux resource for %@",self,spell);
                return;
            }
            
            if ( ! ( currentPriorities & CastWhenInFearOfOtherPlayerDyingPriority )
                && spell.auxiliaryResourceIdealCost.doubleValue > self.currentAuxiliaryResources.doubleValue )
            {
                //PHLog(@"  %@ is waiting to cast %@ because they only have %@/%@ aux resources and no one is imminently dying",self,spell,self.currentAuxiliaryResources,spell.auxiliaryResourceIdealCost);
                return;
            }
        }
        
        if ( spell.aiSpellPriority & currentPriorities )
        {
            if ( spell.aiSpellPriority > highestPrioritySpell.aiSpellPriority )
            {
                //PHLog(@"%@'s %@ meets current priorities and is higher priority than %@",self,spell,highestPrioritySpell);
                highestPrioritySpell = spell;
            }
            //else
            //    PHLog(@"%@'s %@ meets current priorities but isn't higher priority than %@",self,spell,highestPrioritySpell);
            
//            if ( [NSStringFromClass([spell class]) isEqualToString:@"LayOnHandsSpell"] )
//            {
//                PHLog(@"SPELL %08x CURRENT %08x",spell.aiSpellPriority,currentPriorities);
//                PHLog(@"i'm casting loh...?");
//            }
            //*stop = YES;
            return;
        }
        //else
            //PHLog(@"  %@ is not currently a priority",spell);
    }];
    
    // TODO
    Entity *target = self;
    if ( highestPrioritySpell.spellType == DetrimentalSpell )
        target = [self.encounter.enemies randomObject];
    
    if ( highestPrioritySpell )
    {
        [self castSpell:highestPrioritySpell withTarget:target];
        PHLog(@"%@ will%@ trigger gcd",highestPrioritySpell,highestPrioritySpell.triggersGCD?@"":@" NOT");
    }
    else
        PHLog(@"%@ couldn't figure out anything to do on this update",self);
    
    return ! highestPrioritySpell || highestPrioritySpell.triggersGCD;
}

- (void)handleProtPallyIncomingDamageEvent:(Event *)damageEvent
{
    if ( damageEvent.spell.school == PhysicalSchool )
    {
        AvengersShieldSpell *asSpell = (AvengersShieldSpell *)[self spellWithClass:[AvengersShieldSpell class]];
        if ( asSpell && asSpell.isOnCooldown )
        {
            // roll for CD reset
            // Grand Crusader: "When you avoid a melee attack you have a 30% chance of refreshing the cooldown on your next Avenger's Shield and causing it to generate 1 Holy Power."
            // TODO i think this is not totally correct, would proc too much, going with block for now
            if ( damageEvent.netBlocked )
            {
                asSpell.nextCooldownDate = nil;
                [self emphasizeSpell:asSpell duration:5]; // TODO how long does the proc glow for?
            }
        }
    }
}

@end
