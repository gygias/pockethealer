//
//  PriestSpell.m
//  heal drudge
//
//  Created by david on 1/27/15.
//  Copyright (c) 2015 Combobulated Software. All rights reserved.
//

#import "PriestSpell.h"

#import "DivineAegisEffect.h"

@implementation PriestSpell

- (void)handleHitWithSource:(Entity *)source target:(Entity *)target modifiers:(NSArray *)modifiers;
{
    // TODO does it matter if DA is applied before or after the rest of "handling hit"?
    [super handleHitWithSource:source target:target modifiers:modifiers];
    
    // apply divine aegis
    if ( [source.hdClass isEqual:[HDClass discPriest]] )
    {
        if ( arc4random() % 5 != 0 ) // TODO crits...
            return;
        
        // TODO does DA also proc off of absorbs?
        NSNumber *effectiveHealing = ( self.isChanneled || self.isPeriodic ) ? self.periodicHeal : self.healing;
        if ( effectiveHealing )
        {
            DivineAegisEffect *da = [PriestSpell _divineAegisEffectForEntity:target];
            NSNumber *effectiveAbsorb = [DivineAegisEffect absorbWithExistingAbsorb:da.absorb healing:effectiveHealing masteryRating:source.masteryRating sourceMaxHealth:source.health];
            if ( ! da )
            {
                da = [DivineAegisEffect new];
                [target addStatusEffect:da source:source];
            } else
                NSLog(@"%@'s existing %@ is going from %@ to %@! ",target,da.absorb,da.absorb,effectiveAbsorb);
            da.absorb = effectiveAbsorb;
        }
    }
}

+ (DivineAegisEffect *)_divineAegisEffectForEntity:(Entity *)entity
{
    __block DivineAegisEffect *theEffect = nil;
    [entity.statusEffects enumerateObjectsUsingBlock:^(Effect *obj, NSUInteger idx, BOOL *stop) {
        if ( [obj isKindOfClass:[DivineAegisEffect class]] )
        {
            theEffect = (DivineAegisEffect *)obj;
            *stop = YES;
        }
    }];
    
    return theEffect;
}

@end
