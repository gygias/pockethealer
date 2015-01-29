//
//  Entity+ProtPaladin.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Entity+ProtPaladin.h"

#import "Entity+AI.h"
#import "NSCollections+Random.h"
#import "Event.h"
#import "Encounter.h"

@implementation Entity (ProtPaladin)

- (BOOL)doProtPaladinAI
{
    AISpellPriority currentPriorities = [self currentSpellPriorities];
    
    __block Spell *highestPrioritySpell = nil;
    [self.spells enumerateObjectsUsingBlock:^(Spell *spell, NSUInteger idx, BOOL *stop) {
        //NSLog(@"%@(%@,%@) is wondering if they should cast %@ (%@,%@)",self,self.currentResources,self.currentAuxiliaryResources,spell,spell.manaCost,spell.auxiliaryResourceCost);
        
        if ( spell.isOnCooldown )
        {
            //NSLog(@"  %@ is on cooldown",spell);
            return;
        }
        
        if ( spell.manaCost.doubleValue > self.currentResources.doubleValue )
        {
            //NSLog(@"  %@ doesn't have enough mana for %@",self,spell);
            return;
        }
        
        if ( spell.auxiliaryResourceCost )
        {
            if ( spell.auxiliaryResourceCost.doubleValue > self.currentAuxiliaryResources.doubleValue )
            {
                //NSLog(@"  %@ doesn't have enough aux resource for %@",self,spell);
                return;
            }
            
            if ( ! ( currentPriorities & CastWhenInFearOfOtherPlayerDyingPriority )
                && spell.auxiliaryResourceIdealCost.doubleValue > self.currentAuxiliaryResources.doubleValue )
            {
                //NSLog(@"  %@ is waiting to cast %@ because they only have %@/%@ aux resources and no one is imminently dying",self,spell,self.currentAuxiliaryResources,spell.auxiliaryResourceIdealCost);
                return;
            }
        }
        
        if ( spell.aiSpellPriority & currentPriorities )
        {
            if ( spell.aiSpellPriority > highestPrioritySpell.aiSpellPriority )
            {
                //NSLog(@"%@'s %@ meets current priorities and is higher priority than %@",self,spell,highestPrioritySpell);
                highestPrioritySpell = spell;
            }
            //else
            //    NSLog(@"%@'s %@ meets current priorities but isn't higher priority than %@",self,spell,highestPrioritySpell);
            
//            if ( [NSStringFromClass([spell class]) isEqualToString:@"LayOnHandsSpell"] )
//            {
//                NSLog(@"SPELL %08x CURRENT %08x",spell.aiSpellPriority,currentPriorities);
//                NSLog(@"i'm casting loh...?");
//            }
            //*stop = YES;
            return;
        }
        //else
            //NSLog(@"  %@ is not currently a priority",spell);
    }];
    
    // TODO
    Entity *target = self;
    if ( highestPrioritySpell.spellType == DetrimentalSpell )
        target = [self.encounter.enemies randomObject];
    
    if ( highestPrioritySpell )
    {
        [self castSpell:highestPrioritySpell withTarget:target];
        NSLog(@"%@ will%@ trigger gcd",highestPrioritySpell,highestPrioritySpell.triggersGCD?@"":@" NOT");
    }
    else
        NSLog(@"%@ couldn't figure out anything to do on this update",self);
    
    return ! highestPrioritySpell || highestPrioritySpell.triggersGCD;
}

- (void)handleProtPallyIncomingDamageEvent:(Event *)damageEvent
{
    if ( damageEvent.spell.school == PhysicalSchool )
    {
        NSNumber *blockChance = self.blockChance;
        NSNumber *parryChance = self.parryRating;
        NSNumber *dodgeRating = self.dodgeChance;
        NSNumber *armor = self.armor;
    }
}

@end
