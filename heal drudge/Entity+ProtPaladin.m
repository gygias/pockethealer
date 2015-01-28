//
//  Entity+ProtPaladin.m
//  heal drudge
//
//  Created by david on 1/28/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "Entity+ProtPaladin.h"

#import "Entity+AI.h"

@implementation Entity (ProtPaladin)

- (void)doProtPaladinAI
{
    // TODO this is inefficient, why can't Entities carry an array of spells
    AISpellPriority currentPriorities = [self currentSpellPriorities];
    
    __block Spell *spellToCast = nil;
    [self.spells enumerateObjectsUsingBlock:^(Spell *spell, NSUInteger idx, BOOL *stop) {
        if ( spell.isOnCooldown )
        {
            return;
        }
        
        if ( spell.aiSpellPriority | currentPriorities )
        {
            spellToCast = spell;
            *stop = YES;
            return;
        }
    }];
    
    if ( spellToCast )
        [self castSpell:spellToCast withTarget:self];
    else
        NSLog(@"%@ couldn't figure out anything to do on this update",self);
}

@end
