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

@implementation Entity (ProtPaladin)

- (void)doProtPaladinAI
{
    // TODO this is inefficient, why can't Entities carry an array of spells
    AISpellPriority currentPriorities = [self currentSpellPriorities];
    
    __block Spell *spellToCast = nil;
    [self.spells enumerateObjectsUsingBlock:^(Spell *spell, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@(%@,%@) is wondering if they should cast %@ (%@,%@)",self,self.currentResources,self.currentAuxiliaryResources,spell,spell.manaCost,spell.auxiliaryResourceCost);
        
        if ( spell.isOnCooldown )
        {
            NSLog(@"  %@ is on cooldown",spell);
            return;
        }
        
        if ( spell.manaCost.doubleValue > self.currentResources.doubleValue )
        {
            NSLog(@"  %@ doesn't have enough mana for %@",self,spell);
            return;
        }
        
        if ( spell.auxiliaryResourceCost )
        {
            if ( spell.auxiliaryResourceCost.doubleValue > self.currentAuxiliaryResources.doubleValue )
            {
                NSLog(@"  %@ doesn't have enough aux resource for %@",self,spell);
                return;
            }
            
            if ( ! ( currentPriorities | CastWhenInFearOfOtherPlayerDyingPriority )
                && spell.auxiliaryResourceIdealCost.doubleValue > self.currentAuxiliaryResources.doubleValue )
            {
                NSLog(@"  %@ is waiting to cast %@ because they only have %@/%@ aux resources and no one is imminently dying",self,spell,self.currentAuxiliaryResources,spell.auxiliaryResourceIdealCost);
                return;
            }
        }
        
        if ( spell.aiSpellPriority | currentPriorities )
        {
            spellToCast = spell;
            *stop = YES;
            return;
        }
        else
            NSLog(@"  %@ is not currently a priority",spell);
    }];
    
    // TODO
    Entity *target = self;
    if ( spellToCast.spellType == DetrimentalSpell )
        target = [self.encounter.enemies randomObject];
    
    if ( spellToCast )
        [self castSpell:spellToCast withTarget:target];
    else
        NSLog(@"%@ couldn't figure out anything to do on this update",self);
}

@end
